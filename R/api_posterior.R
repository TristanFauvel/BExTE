#' Posterior of the target treatment effect
#'
#' @description Updates a borrowing prior with the observed target data.
#'
#' @param prior A borrowing prior, from one of the [borrowing_priors]
#'   builders.
#' @param target Target data, from [target_data()].
#' @param mcmc_config Optional list of MCMC settings, for the models that can
#'   sample.
#'   The default reads the settings shipped in
#'   `system.file("conf/full/mcmc_config.yml", package = "BExTE")`, which use
#'   quadrature, not Stan.
#'
#' @return An object of class `bexte_posterior`. Use [summary()],
#'   [quantile()], [plot()] and [ess()] on it. Its `model` element is the
#'   underlying R6 model (see [Model]), for advanced use.
#'
#' @seealso [decision()] to test a hypothesis with the posterior.
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' tgt <- target_data(n_control = 39, n_treatment = 53,
#'                    responses_control = 17, responses_treatment = 28)
#' post <- posterior(rmp(src, weight = 0.5), tgt)
#' post
#' summary(post)
#' quantile(post, c(0.025, 0.975))
#' @export
posterior <- function(prior, target, mcmc_config = NULL) {
  if (!inherits(prior, "bexte_prior")) {
    stop("`prior` should come from a prior builder such as npp() or rmp().", call. = FALSE)
  }
  if (!inherits(target, "bexte_target")) {
    stop("`target` should come from target_data().", call. = FALSE)
  }
  model <- api_create_model(prior, mcmc_config)
  target_r6 <- api_target_r6(target, prior$source)
  model$calibrate_for_design(api_design_target(
    prior$source,
    n_control = target_r6$sample_size_control,
    n_treatment = target_r6$sample_size_treatment
  ))
  model$inference(target_r6)

  structure(
    list(model = model, prior = prior, target = target, target_r6 = target_r6),
    class = "bexte_posterior"
  )
}


#' Create the R6 model of a prior specification
#'
#' @param prior A `bexte_prior`.
#' @param mcmc_config A list, or `NULL` for the default.
#' @param config The case-study configuration, by default the source's.
#' @return A `Model` subclass.
#' @keywords internal
#' @noRd
api_create_model <- function(prior, mcmc_config = NULL, config = prior$source$config) {
  if (is.null(mcmc_config)) {
    mcmc_config <- api_default_config("full/mcmc_config.yml")
  }
  Model$new()$create(
    case_study_config = config,
    method = prior$method,
    method_parameters = prior$method_parameters,
    source_data = prior$source$data,
    mcmc_config = mcmc_config
  )
}


#' Read a configuration shipped with the package
#' @keywords internal
#' @noRd
api_default_config <- function(file) {
  yaml::yaml.load_file(system.file("conf", file, package = "BExTE", mustWork = TRUE))
}


#' Simulation settings the API passes to the R6 methods
#' @keywords internal
#' @noRd
api_simulation_config <- function(...) {
  config <- api_default_config("simulation_config.yml")
  utils::modifyList(config, list(...))
}


#' Effective sample size of a prior
#'
#' @description The effective sample size (ESS) of the prior, in target
#'   patients per arm. It tells how many target patients the source
#'   information is worth.
#'
#' @param x A posterior, from [posterior()]. Its prior is evaluated at the
#'   observed target data, which matters for the methods whose prior depends
#'   on those data.
#' @param method `"elir"` for the expected local information ratio
#'   (Neuenschwander et al., 2020), `"moment"` or `"precision"`.
#' @param ... Not used.
#'
#' @return A single number.
#'
#' @details For most methods, the ESS comes from a mixture fitted to random
#'   draws from the prior (or the posterior), so it varies a little from one
#'   call to the next. Call [set.seed()] first to get the same value again.
#'
#' @references Neuenschwander, B., Weber, S., Schmidli, H. and O'Hagan, A.
#'   (2020). Predictively consistent prior effective sample sizes.
#'   Biometrics, 76(2), 578-587.
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' tgt <- target_data(n_control = 39, n_treatment = 53,
#'                    responses_control = 17, responses_treatment = 28)
#' post <- posterior(rmp(src, weight = 0.5), tgt)
#' ess(post)
#' ess(post, method = "moment")
#' @export
ess <- function(x, ...) {
  UseMethod("ess")
}

#' @rdname ess
#' @export
ess.bexte_posterior <- function(x, method = c("elir", "moment", "precision"), ...) {
  method <- match.arg(method)
  model <- x$model
  simulation_config <- api_simulation_config()
  if (method == "elir") {
    return(model$prior_elir_ess(x$target_r6, simulation_config))
  }
  # The moment and precision ESS are the posterior's, less the target
  # sample size, as the simulation reports them.
  model$posterior_ess(x$target_r6, simulation_config)[[method]]
}


#' Decision rule
#'
#' @description Defines when a trial succeeds: the posterior probability that
#'   the treatment effect lies outside the null hypothesis must exceed
#'   `critical_value`. The result is a function: call it on a posterior to get
#'   the decision, or pass it to [oc_frequentist()] or [oc_bayesian()].
#'
#' @param critical_value Posterior probability the trial needs to succeed.
#' @param theta_0,null_space The null hypothesis, as in [source_data()].
#'   `NULL` takes them from the source data of the prior.
#'
#' @return A function of class `bexte_decision`. It takes a posterior and
#'   returns `TRUE` (success) or `FALSE`.
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' tgt <- target_data(n_control = 39, n_treatment = 53,
#'                    responses_control = 17, responses_treatment = 28)
#' success <- decision(critical_value = 0.975)
#' success(posterior(rmp(src, weight = 0.5), tgt))
#' @export
decision <- function(critical_value = 0.975, theta_0 = NULL, null_space = NULL) {
  check_unit_interval(critical_value, "critical_value", open = TRUE)
  if (!is.null(theta_0)) {
    assert_single_number(theta_0)
  }
  if (!is.null(null_space)) {
    null_space <- match.arg(null_space, c("left", "right"))
  }
  rule <- function(posterior) {
    if (!inherits(posterior, "bexte_posterior")) {
      stop("A decision rule takes a posterior, from posterior().", call. = FALSE)
    }
    hypothesis <- api_hypothesis(rule, posterior$prior$source$config)
    model <- posterior$model
    if (isTRUE(model$mcmc)) {
      # The MCMC route compares a credible bound, so it needs the posterior
      # probability as a confidence level.
      return(model$test_decision(critical_value, hypothesis$theta_0, hypothesis$null_space,
                                 confidence_level = 2 * critical_value - 1))
    }
    model$test_decision(critical_value, hypothesis$theta_0, hypothesis$null_space,
                        confidence_level = NULL)
  }
  attr(rule, "critical_value") <- critical_value
  attr(rule, "theta_0") <- theta_0
  attr(rule, "null_space") <- null_space
  class(rule) <- c("bexte_decision", "function")
  rule
}


#' Posterior probability that the treatment effect lies outside the null
#'
#' @param posterior A `bexte_posterior`.
#' @param hypothesis A list with `theta_0` and `null_space`.
#' @return A single number, or `NA` for a model fitted by MCMC, which keeps
#'   only the 2.5% and 97.5% posterior quantiles.
#' @keywords internal
#' @noRd
api_success_proba <- function(posterior, hypothesis) {
  model <- posterior$model
  if (isTRUE(model$mcmc)) {
    return(NA_real_)
  }
  cdf <- unname(model$posterior_cdf(hypothesis$theta_0))
  if (hypothesis$null_space == "left") 1 - cdf else cdf
}


#' The null hypothesis of a decision rule
#'
#' @param rule A `bexte_decision`.
#' @param config The case-study configuration that fills unset values.
#' @return A list with `theta_0` and `null_space`.
#' @keywords internal
#' @noRd
api_hypothesis <- function(rule, config) {
  theta_0 <- attr(rule, "theta_0")
  null_space <- attr(rule, "null_space")
  list(
    theta_0 = if (is.null(theta_0)) config$theta_0 else theta_0,
    null_space = if (is.null(null_space)) config$null_space else null_space
  )
}
