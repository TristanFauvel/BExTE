# Exact operating characteristics by enumerating the trial outcomes.
#
# A binary-endpoint trial reaches the analysis only through its two responder
# counts, so instead of averaging an operating characteristic over random
# replicates it can be summed over every pair of counts, weighted by the pair's
# binomial probability - see BinaryTargetData$enumerate_support(). The sums are
# exact up to the tail mass the enumeration leaves out, so they carry no Monte
# Carlo error, and every drift is computed from the same analyses.


#' Whether a case study's operating characteristics are enumerated
#'
#' @description `scenarios_config$exact_enumeration`, when present, lists the
#'   case studies whose operating characteristics are computed exactly by
#'   enumerating the trial outcomes rather than by simulating replicates. Only
#'   binary endpoints analysed from their responder counts can be enumerated:
#'   the binomial likelihood, or the normal one without the sampling
#'   approximation.
#'
#' @param scenarios_config The scenarios configuration.
#' @param case_study The case study name.
#' @return `TRUE` or `FALSE`.
#' @keywords internal
case_study_exact_enumeration <- function(scenarios_config, case_study) {
  case_study %in% unlist(scenarios_config$exact_enumeration)
}


#' Check that a case study can be enumerated
#'
#' @param case_study_config The case study configuration.
#' @param case_study The case study name, for the error message.
#' @return No return value, called for side effects.
#' @keywords internal
check_exact_enumeration_supported <- function(case_study_config, case_study) {
  enumerable <- identical(case_study_config$endpoint, "binary") && (
    identical(case_study_config$summary_measure_likelihood, "binomial") || (
      identical(case_study_config$summary_measure_likelihood, "normal") &&
        isFALSE(case_study_config$sampling_approximation)
    )
  )
  if (!enumerable) {
    stop(
      "exact_enumeration lists ", case_study, ", but only a binary endpoint ",
      "analysed from its responder counts can be enumerated: the binomial ",
      "likelihood, or the normal one with sampling_approximation: FALSE."
    )
  }
  invisible(NULL)
}


#' Quantiles of a weighted sample
#'
#' @description The smallest value whose cumulative weight reaches each
#'   probability: the inverse of the weighted empirical distribution function,
#'   which is `stats::quantile(type = 1)` when the weights are equal. `NA`
#'   values are dropped with their weight, and the rest renormalised.
#'
#' @param x Numeric vector.
#' @param weights Nonnegative weights, the same length as `x`.
#' @param probs Probabilities.
#' @return A numeric vector of quantiles, one per probability.
#' @keywords internal
weighted_quantile <- function(x, weights, probs) {
  if (length(x) != length(weights)) {
    stop("x has ", length(x), " values but there are ", length(weights), " weights.")
  }
  kept <- !is.na(x)
  x <- x[kept]
  weights <- weights[kept]
  if (length(x) == 0 || sum(weights) <= 0) {
    return(rep(NA_real_, length(probs)))
  }
  order_x <- order(x)
  x <- x[order_x]
  cumulative <- cumsum(weights[order_x]) / sum(weights)
  # A cumulative weight that reaches a probability up to rounding counts as
  # reaching it, so equal weights reproduce the type 1 quantile exactly.
  positions <- vapply(probs, function(p) {
    which(cumulative >= p - 1e-12)[1]
  }, integer(1))
  x[positions]
}


#' The interval columns of an exactly computed result
#'
#' @description An enumerated operating characteristic has no Monte Carlo
#'   error, so each of its `conf_int_<metric>_lower`/`_upper` pairs (and each
#'   `conf_int_lower_<parameter>`/`conf_int_upper_<parameter>` pair of the
#'   posterior parameters) collapses onto the point estimate, and its Monte
#'   Carlo standard error is zero. Plots already hide error bars of zero width.
#'
#' @param result The list `estimate_frequentist_operating_characteristics()`
#'   returns.
#' @return The same list with its intervals collapsed.
#' @keywords internal
collapse_monte_carlo_intervals <- function(result) {
  for (name in names(result)) {
    metric <- sub("^conf_int_(.*)_(lower|upper)$", "\\1", name)
    if (metric != name && !is.null(result[[metric]])) {
      result[[name]] <- result[[metric]]
    }
  }
  if (!is.null(result$mcse_success_proba)) {
    result$mcse_success_proba <- 0
  }
  parameters <- result$posterior_parameters
  for (name in names(parameters)) {
    parameter <- sub("^conf_int_(lower|upper)_", "", name)
    if (parameter != name && !is.null(parameters[[parameter]])) {
      parameters[[name]] <- parameters[[parameter]]
    }
  }
  result$posterior_parameters <- parameters
  result
}
