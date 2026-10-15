#' Tipping-point analysis
#'
#' @description Tests how robust a decision is. The function varies one input
#'   of the analysis over a grid of values, and finds the values at which the
#'   decision of [decision()] changes: the tipping points. The input can be:
#'
#'   - an argument of the prior builder, for example `weight` of [rmp()] or
#'     `a0` of [power_prior()];
#'   - an argument of [target_data()], for example `estimate` or
#'     `responses_treatment`, to shift the observed target effect;
#'   - an argument of [decision()]: `critical_value` or `theta_0`.
#'
#' @param prior A borrowing prior, from one of the [borrowing_priors]
#'   builders.
#' @param target Target data, from [target_data()].
#' @param decision A decision rule, from [decision()].
#' @param parameter Name of the argument to vary. It must be a numeric
#'   argument of exactly one of the prior builder, [target_data()] and
#'   [decision()].
#' @param values Grid of values of `parameter`. Between two adjacent values
#'   where the decision changes, the function finds the tipping point to the
#'   precision `tol`. A tipping point between two values of the grid with
#'   the same decision stays hidden, so use a fine enough grid.
#' @param tol Precision of the tipping points of a continuous parameter.
#' @param mcmc_config Optional MCMC settings, as in [posterior()].
#'
#' @return An object of class `bexte_tipping_point`: a data frame with one
#'   row per value of the grid, and columns `value`, `success_proba` (the
#'   posterior probability that the treatment effect lies outside the null
#'   hypothesis) and `success` (the decision). The attribute
#'   `tipping_points` holds the tipping points. It is empty if the decision
#'   is the same on the whole grid.
#'
#' @details For a continuous parameter, the tipping point is the value at
#'   which `success_proba` equals the critical value, found by
#'   [stats::uniroot()]. For a count (`n_control`, `n_treatment`,
#'   `responses_control` or `responses_treatment`), it is the first count, as
#'   seen from the observed value, at which the decision differs from the
#'   decision at the neighbouring count. A model fitted by MCMC keeps only
#'   the 2.5% and 97.5% posterior quantiles, so `success_proba` is `NA` and
#'   the function finds the tipping point by bisection on the decision.
#'
#'   The curve of `success_proba` need not be monotone, so there can be more
#'   than one tipping point.
#'
#' @seealso [posterior()], [decision()], [update.bexte_prior()].
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' tgt <- target_data(n_control = 39, n_treatment = 53,
#'                    responses_control = 17, responses_treatment = 28)
#'
#' # How much weight on the source study does success need?
#' tp <- tipping_point(rmp(src, weight = 0.5), tgt, decision(0.975),
#'                     parameter = "weight", values = seq(0, 1, by = 0.1))
#' tp
#'
#' # How many treatment responders does success need?
#' tipping_point(rmp(src, weight = 0.5), tgt, decision(0.975),
#'               parameter = "responses_treatment", values = c(0, 53))
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) plot(tp)
#' }
#' @export
tipping_point <- function(prior, target, decision, parameter, values,
                          tol = 1e-6, mcmc_config = NULL) {
  if (!inherits(prior, "bexte_prior")) {
    stop("`prior` should come from a prior builder such as npp() or rmp().", call. = FALSE)
  }
  if (!inherits(target, "bexte_target")) {
    stop("`target` should come from target_data().", call. = FALSE)
  }
  if (!inherits(decision, "bexte_decision")) {
    stop("`decision` should come from decision().", call. = FALSE)
  }
  if (!is.character(parameter) || length(parameter) != 1) {
    stop("`parameter` should be the name of one argument.", call. = FALSE)
  }
  if (!is.numeric(values) || length(values) < 2 || anyNA(values)) {
    stop("`values` should be a numeric vector of at least two values, with no missing values.",
         call. = FALSE)
  }
  check_positive(tol, "tol")

  location <- api_tp_locate(parameter, prior, target, decision)
  observed <- api_tp_observed(parameter, location, prior, target, decision)
  is_count <- parameter %in% API_TP_COUNTS
  values <- sort(unique(values))
  if (is_count && any(values != round(values))) {
    stop("`", parameter, "` is a count, so `values` should hold whole numbers.", call. = FALSE)
  }

  evaluate <- api_tp_evaluator(parameter, location, prior, target, decision, mcmc_config)
  errors <- character()
  grid <- lapply(values, function(x) {
    tryCatch(evaluate(x), error = function(e) {
      errors[[format(x)]] <<- conditionMessage(e)
      list(proba = NA_real_, success = NA)
    })
  })
  if (length(errors) > 0) {
    warning("The analysis failed at ", parameter, " = ",
            paste(names(errors), collapse = ", "), ". First error: ", errors[[1]],
            call. = FALSE)
  }
  success <- vapply(grid, `[[`, logical(1), "success")
  success_proba <- vapply(grid, `[[`, numeric(1), "proba")

  at_observed <- evaluate(observed)
  tipping_points <- numeric()
  for (i in seq_len(length(values) - 1)) {
    if (is.na(success[i]) || is.na(success[i + 1]) || success[i] == success[i + 1]) {
      next
    }
    tipping_points <- c(tipping_points, api_tp_refine(
      evaluate, values[i], values[i + 1], success[i], is_count, observed,
      at_observed$critical_value, tol
    ))
  }

  out <- data.frame(value = values, success_proba = success_proba, success = success)
  attr(out, "parameter") <- parameter
  attr(out, "location") <- location
  attr(out, "observed") <- observed
  attr(out, "observed_proba") <- at_observed$proba
  attr(out, "observed_success") <- at_observed$success
  attr(out, "tipping_points") <- tipping_points
  attr(out, "critical_value") <- at_observed$critical_value
  attr(out, "method") <- prior$label
  class(out) <- c("bexte_tipping_point", "data.frame")
  out
}


API_TP_TARGET <- c("n_control", "n_treatment", "responses_control", "responses_treatment",
                   "estimate", "se")
API_TP_DECISION <- c("critical_value", "theta_0")
API_TP_COUNTS <- c("n_control", "n_treatment", "responses_control", "responses_treatment")

# The `decision` argument of tipping_point() hides decision(), so the
# functions there build rules with this alias.
api_tp_decision <- function(...) decision(...)


#' Find which input of the analysis holds a parameter
#'
#' @return `"prior"`, `"target"` or `"decision"`.
#' @keywords internal
#' @noRd
api_tp_locate <- function(parameter, prior, target, decision) {
  prior_args <- setdiff(names(prior$builder_args), "source")
  target_args <- API_TP_TARGET[!vapply(target[API_TP_TARGET], is.null, logical(1))]
  found <- c(
    prior = parameter %in% prior_args,
    target = parameter %in% target_args,
    decision = parameter %in% API_TP_DECISION
  )
  if (sum(found) == 0) {
    stop("`", parameter, "` is not an argument of the prior builder, of the target data or ",
         "of the decision rule. The choices are: ",
         paste0("`", c(prior_args, target_args, API_TP_DECISION), "`", collapse = ", "), ".",
         call. = FALSE)
  }
  if (sum(found) > 1) {
    stop("`", parameter, "` is an argument of more than one of: ",
         paste(names(found)[found], collapse = ", "), ".", call. = FALSE)
  }
  names(found)[found]
}


#' The value of the parameter in the analysis as given
#' @keywords internal
#' @noRd
api_tp_observed <- function(parameter, location, prior, target, decision) {
  value <- switch(location,
    prior = prior$builder_args[[parameter]],
    target = target[[parameter]],
    decision = if (parameter == "theta_0") {
      api_hypothesis(decision, prior$source$config)$theta_0
    } else {
      attr(decision, parameter)
    }
  )
  if (!is.numeric(value) || length(value) != 1) {
    stop("`", parameter, "` should be a numeric argument, with a single value.", call. = FALSE)
  }
  value
}


#' Build the function that analyses the data at one value of the parameter
#'
#' @return A function of the value. It returns a list with `proba` (the
#'   posterior probability of success), `success` and `critical_value`.
#' @keywords internal
#' @noRd
api_tp_evaluator <- function(parameter, location, prior, target, decision, mcmc_config) {
  decision_args <- list(
    critical_value = attr(decision, "critical_value"),
    theta_0 = attr(decision, "theta_0"),
    null_space = attr(decision, "null_space")
  )
  fixed_posterior <- NULL
  if (location == "decision") {
    # The posterior does not depend on the decision rule, so fit it once.
    fixed_posterior <- posterior(prior, target, mcmc_config)
  }
  function(x) {
    rule <- decision
    post <- fixed_posterior
    if (location == "prior") {
      post <- posterior(do.call(stats::update, stats::setNames(list(prior, x), c("object", parameter))),
                        target, mcmc_config)
    } else if (location == "target") {
      args <- target[API_TP_TARGET]
      args[[parameter]] <- x
      post <- posterior(prior, do.call(target_data, args), mcmc_config)
    } else {
      args <- decision_args
      args[[parameter]] <- x
      rule <- do.call(api_tp_decision, args)
    }
    list(
      proba = api_success_proba(post, api_hypothesis(rule, prior$source$config)),
      success = isTRUE(rule(post)),
      critical_value = attr(rule, "critical_value")
    )
  }
}


#' Find the tipping point between two values with different decisions
#'
#' @param evaluate The function from `api_tp_evaluator()`.
#' @param lower,upper Adjacent values of the grid.
#' @param success_lower Decision at `lower`.
#' @param is_count Whether the parameter is a count.
#' @param observed Value of the parameter in the analysis as given.
#' @param critical_value Critical value of the decision rule.
#' @param tol Precision for a continuous parameter.
#' @return A single number.
#' @keywords internal
#' @noRd
api_tp_refine <- function(evaluate, lower, upper, success_lower, is_count, observed,
                          critical_value, tol) {
  if (is_count) {
    # Bisection on the counts, down to two neighbouring counts.
    while (upper - lower > 1) {
      middle <- floor((lower + upper) / 2)
      if (evaluate(middle)$success == success_lower) lower <- middle else upper <- middle
    }
    # The tipping point is the count of the pair that lies farther from the
    # observed value: the first count, from there, with the other decision.
    return(if (abs(upper - observed) >= abs(lower - observed)) upper else lower)
  }
  proba_lower <- evaluate(lower)$proba
  if (!is.na(proba_lower) && !is.null(critical_value)) {
    margin <- function(x) {
      result <- evaluate(x)
      result$proba - result$critical_value
    }
    return(stats::uniroot(margin, c(lower, upper), tol = tol)$root)
  }
  # MCMC models give only the decision, so bisect on it.
  while (upper - lower > tol) {
    middle <- (lower + upper) / 2
    if (evaluate(middle)$success == success_lower) lower <- middle else upper <- middle
  }
  (lower + upper) / 2
}
