#' Compute the Hellinger distance between two normal distributions.
#'
#' @param mu1 Mean of the first normal distribution.
#' @param sigma1 Standard deviation of the first normal distribution.
#' @param mu2 Mean of the second normal distribution.
#' @param sigma2 Standard deviation of the second normal distribution.
#'
#' @return The Hellinger distance between the two normal distributions.
#'
hellinger_distance <- function(mu1, sigma1, mu2, sigma2) {
  return(sqrt(1 - sqrt(2 * sigma1 * sigma2 / (sigma1 ^ 2 + sigma2 ^ 2)) * exp(-0.25 * (mu1 - mu2) ^
                                                                         2 / (sigma1 ^ 2 + sigma2 ^ 2))))
}

#' Compute the drift range for a given simulation and case study configuration.
#'
#' @param scenarios_config Configuration for the simulation.
#' @param case_study_config Configuration for the case study.
#'
#' @return A vector representing the drift range.
#' @keywords internal
#' @export
compute_drift_range <- function(scenarios_config, case_study_config) {
  theta_0 <- case_study_config$theta_0
  source_treatment_effect <- case_study_config$source$treatment_effect

  if (case_study_config$summary_measure_likelihood == "normal") {
    sigma1 <- case_study_config$source$standard_error
    sigma2 <- case_study_config$target$standard_error


    max_drift <- abs(source_treatment_effect) * 10
    target_hellinger <- function(mu_diff) {
      return(hellinger_distance(0, sigma1, mu_diff, sigma2) - 0.9)
    }
    solver_result <- stats::uniroot(target_hellinger, c(0, max_drift))
    upper_bound <- solver_result$root
    lower_bound <- -upper_bound

    # The range must also contain every drift between the source estimate and
    # the null, [theta_0 - source_treatment_effect, 0]. That interval lies on
    # either side of zero depending on the direction of the null hypothesis
    # (it is positive for teriflunomide and mepolizumab), so widen whichever
    # bound it crosses.
    null_drift <- theta_0 - source_treatment_effect
    lower_bound <- min(lower_bound, null_drift)
    upper_bound <- max(upper_bound, null_drift)
  } else if (case_study_config$summary_measure_likelihood == "binomial") {
    source_control_rate <- case_study_config$source$responses$control / case_study_config$source$control
    source_treatment_rate <- case_study_config$source$responses$treatment / case_study_config$source$treatment
    source_treatment_effect <- source_treatment_rate - source_control_rate
    lower_bound <- max(-1 - source_treatment_effect, -source_treatment_rate)
    upper_bound <- min(1 - source_treatment_effect, 1 - source_treatment_rate)
  } else {
    stop("Not implemented for other treatment effect distributions")
  }
  drift_range <- seq(lower_bound, upper_bound, length.out = scenarios_config$ndrift)
  return(drift_range)
}
