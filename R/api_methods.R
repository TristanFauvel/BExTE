#' Print, summarise and plot BExTE objects
#'
#' @description Methods for the objects that [source_data()],
#'   [target_data()], the [borrowing_priors] builders, [posterior()],
#'   [decision()], [design_prior()], [oc_frequentist()], [oc_bayesian()] and
#'   [tipping_point()] return.
#'
#' @param x,object A BExTE object.
#' @param probs Probabilities of the posterior quantiles.
#' @param level Level of the credible interval in the summary.
#' @param xlim Range of treatment effects to plot. By default, the posterior
#'   mean plus or minus 4 posterior standard deviations.
#' @param metric The column of the frequentist OCs to plot against the true
#'   effect.
#' @param digits Number of significant digits to print.
#' @param ... Not used.
#'
#' @return `print()` returns `x` invisibly. `summary()` of a posterior returns
#'   a one-row data frame of class `summary.bexte_posterior`. `plot()` returns
#'   a ggplot. `quantile()` returns a named numeric vector.
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' tgt <- target_data(n_control = 39, n_treatment = 53,
#'                    responses_control = 17, responses_treatment = 28)
#' post <- posterior(rmp(src, weight = 0.5), tgt)
#' print(post)
#' summary(post, level = 0.9)
#' quantile(post, c(0.05, 0.5, 0.95))
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE)) plot(post)
#' }
#' @name bexte_methods
#' @importFrom stats quantile
#' @importFrom rlang .data
NULL


effect_scale <- function(config) {
  if (config$endpoint == "continuous") {
    return("mean difference")
  }
  if (config$summary_measure_likelihood == "binomial") return("risk difference") else return("log odds ratio")
}

api_format_num <- function(x, digits = 3) {
  return(formatC(x, digits = digits, format = "g", flag = "#"))
}

#' @rdname bexte_methods
#' @export
print.bexte_source <- function(x, ...) {
  config <- x$config
  data <- x$data
  cat("<bexte_source> ", config$name, ": ", config$endpoint, " endpoint, ",
      effect_scale(config), "\n", sep = "")
  cat("  Arms: ", data$sample_size_control, " control, ", data$sample_size_treatment,
      " treatment\n", sep = "")
  cat("  Effect estimate: ", api_format_num(data$treatment_effect_estimate),
      " (SE ", api_format_num(data$standard_error), ")\n", sep = "")
  cat("  Null hypothesis: theta ", if (config$null_space == "left") "<=" else ">=",
      " ", config$theta_0, "\n", sep = "")
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
print.bexte_target <- function(x, ...) {
  cat("<bexte_target> ", x$endpoint, " endpoint\n", sep = "")
  cat("  Arms: ", x$n_control, " control, ", x$n_treatment, " treatment\n", sep = "")
  if (x$endpoint == "binary") {
    cat("  Responders: ", x$responses_control, " control, ", x$responses_treatment,
        " treatment\n", sep = "")
  } else {
    cat("  Effect estimate: ", api_format_num(x$estimate), " (SE ", api_format_num(x$se), ")\n",
        sep = "")
  }
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
print.bexte_prior <- function(x, ...) {
  cat("<bexte_prior> ", x$label, "\n", sep = "")
  cat("  Source: ", x$source$config$name, " (", effect_scale(x$source$config), ")\n",
      sep = "")
  parameters <- x$method_parameters[names(x$method_parameters) != "initial_prior"]
  for (name in names(parameters)) {
    value <- parameters[[name]]
    if (is.list(value)) {
      value <- paste(names(value), vapply(value, format, character(1), digits = 3),
                     sep = " = ", collapse = ", ")
    }
    cat("  ", name, ": ", format(value), "\n", sep = "")
  }
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
summary.bexte_posterior <- function(object, level = 0.95, ...) {
  check_unit_interval(level, "level", open = TRUE)
  model <- object$model
  # Not every model's credible_interval() takes any level, but every one
  # has a posterior CDF.
  interval <- quantile(object, probs = c((1 - level) / 2, (1 + level) / 2))
  out <- data.frame(
    method = object$prior$label,
    mean = unname(model$post_mean),
    sd = unname(sqrt(model$post_var)),
    median = unname(scalar_or(model$post_median, NA_real_)),
    lower = unname(interval[1]),
    upper = unname(interval[2]),
    level = level,
    row.names = NULL
  )
  class(out) <- c("summary.bexte_posterior", "data.frame")
  return(out)
}

scalar_or <- function(x, default) if (length(x) == 1) x else default

#' @rdname bexte_methods
#' @export
print.summary.bexte_posterior <- function(x, ...) {
  print(structure(x, class = "data.frame"), row.names = FALSE, digits = 4)
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
print.bexte_posterior <- function(x, ...) {
  s <- summary(x)
  config <- x$prior$source$config
  cat("<bexte_posterior> ", x$prior$label, "\n", sep = "")
  cat("  Treatment effect (", effect_scale(config), "): mean ", api_format_num(s$mean),
      ", sd ", api_format_num(s$sd), "\n", sep = "")
  cat("  95% credible interval: [", api_format_num(s$lower), ", ", api_format_num(s$upper), "]\n",
      sep = "")
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
quantile.bexte_posterior <- function(x, probs = c(0.025, 0.5, 0.975), ...) {
  if (!is.numeric(probs) || any(probs <= 0 | probs >= 1)) {
    stop("`probs` should lie in (0, 1).", call. = FALSE)
  }
  model <- x$model
  values <- HDInterval::inverseCDF(probs, function(q) model$posterior_cdf(q))
  return(stats::setNames(values, paste0(format(100 * probs, trim = TRUE), "%")))
}

#' @rdname bexte_methods
#' @export
plot.bexte_posterior <- function(x, xlim = NULL, ...) {
  model <- x$model
  if (is.null(xlim)) {
    xlim <- model$post_mean + c(-4, 4) * sqrt(model$post_var)
  }
  return(model$plot_pdfs(xmin = xlim[1], xmax = xlim[2], resolution = 200) +
    ggplot2::labs(subtitle = x$prior$label,
                  x = paste0("Treatment effect (", effect_scale(x$prior$source$config), ")")))
}

#' @rdname bexte_methods
#' @export
as.data.frame.bexte_posterior <- function(x, ...) {
  return(as.data.frame(structure(summary(x), class = "data.frame")))
}

#' @rdname bexte_methods
#' @export
print.bexte_decision <- function(x, ...) {
  theta_0 <- attr(x, "theta_0")
  null_space <- attr(x, "null_space")
  critical_value <- attr(x, "critical_value")
  if (is.null(theta_0) || is.null(null_space)) {
    cat("<bexte_decision> success if P(theta outside the null hypothesis | data) > ", critical_value, "\n",
        "  The null hypothesis comes from the source data of the prior.\n", sep = "")
  } else {
    cat("<bexte_decision> success if P(theta ", if (null_space == "left") ">" else "<", " ",
        theta_0, " | data) > ", critical_value, "\n", sep = "")
  }
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
print.bexte_design_prior <- function(x, ...) {
  cat("<bexte_design_prior> ", x$type, "\n", sep = "")
  return(invisible(x))
}

print_oc_header <- function(x, kind) {
  hypothesis <- attr(x, "hypothesis")
  cat("<", class(x)[1], "> ", kind, " operating characteristics of ",
      attr(x, "method"), "\n", sep = "")
  return(cat("  Success: P(theta ", if (hypothesis$null_space == "left") ">" else "<", " ",
      hypothesis$theta_0, " | data) > ", hypothesis$critical_value, "\n", sep = ""))
}

#' @rdname bexte_methods
#' @export
print.bexte_oc_frequentist <- function(x, ...) {
  print_oc_header(x, "Frequentist")
  cat("  ", attr(x, "n_rep"), " simulated trials per true effect\n\n", sep = "")
  print(summary(x), row.names = FALSE, digits = 3)
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
summary.bexte_oc_frequentist <- function(object, ...) {
  columns <- c("drift", "true_effect", "null_true", "n_control", "n_treatment", "success_proba",
               "conf_int_success_proba_lower", "conf_int_success_proba_upper",
               "bias", "mse", "coverage")
  out <- as.data.frame(object)[, columns]
  names(out)[names(out) == "conf_int_success_proba_lower"] <- "success_lower"
  names(out)[names(out) == "conf_int_success_proba_upper"] <- "success_upper"
  # At a true effect inside the null hypothesis, a success is a type I error.
  out$metric <- ifelse(out$null_true, "type I error", "power")
  return(out)
}

#' @rdname bexte_methods
#' @export
as.data.frame.bexte_oc_frequentist <- function(x, ...) {
  attributes(x)[c("method", "hypothesis", "n_rep")] <- NULL
  class(x) <- "data.frame"
  return(x)
}

#' @rdname bexte_methods
#' @export
plot.bexte_oc_frequentist <- function(x, metric = "success_proba", ...) {
  check_plot_packages()
  data <- as.data.frame(x)
  if (!metric %in% names(data)) {
    stop("`metric` should be a column of the operating characteristics.", call. = FALSE)
  }
  hypothesis <- attr(x, "hypothesis")
  return(ggplot2::ggplot(data, ggplot2::aes(x = .data$true_effect, y = .data[[metric]])) +
    ggplot2::geom_vline(xintercept = hypothesis$theta_0, linetype = "dashed", colour = "grey50") +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::labs(
      title = paste("Frequentist operating characteristics:", attr(x, "method")),
      subtitle = "Dashed line: boundary of the null hypothesis",
      x = "True treatment effect",
      y = if (metric == "success_proba") "Probability of success" else metric
    ) +
    ggplot2::theme_minimal())
}

#' @rdname bexte_methods
#' @export
print.bexte_oc_bayesian <- function(x, ...) {
  print_oc_header(x, "Bayesian")
  cat("  Design prior: ", x$design_prior, "; ", attr(x, "n_draws"), " draws, ",
      attr(x, "n_rep"), " trials each\n\n", sep = "")
  print(summary(x), row.names = FALSE, digits = 3)
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
summary.bexte_oc_bayesian <- function(object, ...) {
  columns <- c("n_control", "n_treatment", "prior_proba_success", "prior_proba_no_benefit",
               "prepost_proba_TP", "prepost_proba_FP", "average_power", "average_tie",
               "upper_bound_proba_FP")
  return(as.data.frame(object)[, intersect(columns, names(object)), drop = FALSE])
}

#' @rdname bexte_methods
#' @export
as.data.frame.bexte_oc_bayesian <- function(x, ...) {
  attributes(x)[c("method", "hypothesis", "n_rep", "n_draws")] <- NULL
  class(x) <- "data.frame"
  return(x)
}

#' @rdname bexte_methods
#' @export
print.bexte_tipping_point <- function(x, digits = 4, ...) {
  parameter <- attr(x, "parameter")
  cat("<bexte_tipping_point> ", attr(x, "method"), ": tipping points in `", parameter,
      "` (", attr(x, "location"), ")\n", sep = "")
  cat("  Grid: ", nrow(x), " values from ", format(min(x$value), digits = digits), " to ",
      format(max(x$value), digits = digits), "\n", sep = "")
  tipping_points <- attr(x, "tipping_points")
  if (length(tipping_points) == 0) {
    cat("  No tipping point in the grid: the decision is the same at every value.\n")
    return(invisible(x))
  }
  cat("  Tipping points: ", paste(format(tipping_points, digits = digits), collapse = ", "),
      "\n", sep = "")
  return(invisible(x))
}

#' @rdname bexte_methods
#' @export
plot.bexte_tipping_point <- function(x, ...) {
  check_plot_packages()
  parameter <- attr(x, "parameter")
  data <- as.data.frame(x)
  data$decision <- ifelse(data$success, "success", "no success")
  if (all(is.na(data$success_proba))) {
    # MCMC models give only the decision.
    data$success_proba <- as.numeric(data$success)
    y_label <- "Success (1) or not (0)"
    threshold <- NULL
  } else {
    y_label <- "Posterior probability of success"
    threshold <- if (parameter == "critical_value") {
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey50")
    } else {
      ggplot2::geom_hline(yintercept = attr(x, "critical_value"), linetype = "dashed",
                          colour = "grey50")
    }
  }
  return(ggplot2::ggplot(data, ggplot2::aes(x = .data$value, y = .data$success_proba)) +
    threshold +
    ggplot2::geom_vline(xintercept = attr(x, "tipping_points"), colour = "firebrick") +
    ggplot2::geom_vline(xintercept = attr(x, "observed"), linetype = "dotted") +
    ggplot2::geom_line() +
    ggplot2::geom_point(ggplot2::aes(shape = .data$decision)) +
    ggplot2::labs(
      title = paste("Tipping-point analysis:", attr(x, "method")),
      subtitle = paste("Red: tipping points. Dotted: observed value.",
                       if (!is.null(threshold)) "Dashed: critical value."),
      x = parameter,
      y = y_label,
      shape = "Decision"
    ) +
    ggplot2::theme_minimal())
}

#' @rdname bexte_methods
#' @export
as.data.frame.bexte_tipping_point <- function(x, ...) {
  attributes(x)[c("parameter", "location", "observed", "observed_proba", "observed_success",
                  "tipping_points", "critical_value", "method")] <- NULL
  class(x) <- "data.frame"
  return(x)
}
