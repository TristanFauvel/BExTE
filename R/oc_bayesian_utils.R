check_probability_value <- function(p) {
  if (length(p) == 0) {
    return(NA)
  }

  if (is.na(p)) {
    return(NA)
  }

  if (p < 0) {
    warning("Invalid value for the probability, should be between 0 and 1. Rounding the value to 0.")
    futile.logger::flog.warn("Invalid value for the probability, should be between 0 and 1. Rounding the value to 0.")
    p <- 0
  }

  if (p > 1) {
    warning("Invalid value for the probability, should be between 0 and 1. Rounding the value to 1.")
    futile.logger::flog.warn("Invalid value for the probability, should be between 0 and 1. Rounding the value to 1.")
    p <- 1
  }
  return(p)
}

#' Mask the values that lie in the null or in the alternative space
#'
#' @param values Numeric vector (treatment effects or design prior samples).
#' @param theta_0 The value of theta_0.
#' @param null_space The null space (either "left" or "right").
#' @param region Either "null" or "alternative".
#'
#' @return A logical vector with the length of `values`.
#'
#' @keywords internal
#' @export
space_mask <- function(values, theta_0, null_space, region = c("null", "alternative")) {
  region <- match.arg(region)

  if (null_space == "left") {
    in_null_space <- values <= theta_0
  } else if (null_space == "right") {
    in_null_space <- values >= theta_0
  } else {
    stop("Null space must be either 'left' or 'right'.")
  }

  if (region == "null") return(in_null_space) else return(!in_null_space)
}

#' Preposterior probability of success over one region, by Monte Carlo
#'
#' @description Averages the conditional probability of success over the design
#' prior samples that lie in the null space (false positive) or in the
#' alternative space (true positive).
#'
#' @param conditional_proba_success The conditional probability of success.
#' @param design_prior_samples The design prior samples.
#' @param theta_0 The value of theta_0.
#' @param null_space The null space (either "left" or "right").
#' @param region Either "null" or "alternative".
#'
#' @return A single probability.
#'
#' @keywords internal
preposterior_proba_MC <- function(conditional_proba_success,
                                  design_prior_samples,
                                  theta_0,
                                  null_space,
                                  region = c("null", "alternative")) {
  if (length(conditional_proba_success) != length(design_prior_samples)) {
    stop("`conditional_proba_success` and `design_prior_samples` must have the same length.")
  }

  samples_in_region <- space_mask(design_prior_samples, theta_0, null_space, region)

  p <- mean(conditional_proba_success * samples_in_region)

  p <- sapply(p, check_probability_value)

  assert_single_number(p)
  return(p)
}

#' Calculate the probability of false positive
#'
#' @description This function calculates the probability of false positive based on the conditional probability of success,
#' design prior samples, theta_0, and null space.
#'
#' @param conditional_proba_success The conditional probability of success.
#' @param design_prior_samples The design prior samples.
#' @param theta_0 The value of theta_0.
#' @param null_space The null space (either "left" or "right").
#'
#' @return The probability of false positive.
#'
#'
#' @keywords internal
preposterior_proba_FP_MC <- function(conditional_proba_success,
                                     design_prior_samples,
                                     theta_0,
                                     null_space) {
  return(preposterior_proba_MC(conditional_proba_success, design_prior_samples, theta_0, null_space, region = "null"))
}

#' Calculate the probability of true positive
#'
#' @description This function calculates the probability of true positive based on the conditional probability of success,
#' design prior samples, theta_0, and null space.
#'
#' @param conditional_proba_success The conditional probability of success.
#' @param design_prior_samples The design prior samples.
#' @param theta_0 The value of theta_0.
#' @param null_space The null space (either "left" or "right").
#'
#' @return The probability of true positive.
#'
#'
#' @keywords internal
preposterior_proba_TP_MC <- function(conditional_proba_success,
                                     design_prior_samples,
                                     theta_0,
                                     null_space) {
  return(preposterior_proba_MC(conditional_proba_success, design_prior_samples, theta_0, null_space, region = "alternative"))
}

#' Calculate the average type 1 error
#'
#' @description This function calculates the average type 1 error based on the preposterior probability of false positive
#' and the prior probability of no benefit.
#'
#' @param prepost_proba_FP The preposterior probability of false positive.
#' @param prior_proba_no_benefit The prior probability of no benefit.
#'
#' @return The average type 1 error.
#'
#'
#' @keywords internal
#' @export
average_tie <- function(prepost_proba_FP,
                        prior_proba_no_benefit) {
  if (is.na(prepost_proba_FP) || is.na(prior_proba_no_benefit)) {
    return(NA)
  }

  assert_single_number(prepost_proba_FP)
  assert_single_number(prior_proba_no_benefit)

  p <- prepost_proba_FP / prior_proba_no_benefit
  p <- sapply(p, check_probability_value)

  assert_single_number(p)
  return(p)
}

#' Calculate the average power
#'
#' @description This function calculates the average power based on the preposterior probability of true positive
#' and the prior probability of no benefit.
#'
#' @param prepost_proba_TP The preposterior probability of true positive.
#' @param prior_proba_no_benefit The prior probability of no benefit.
#'
#' @return The average power.
#'
#'
#' @keywords internal
#' @export
average_power <- function(prepost_proba_TP,
                          prior_proba_no_benefit) {
  if (is.na(prepost_proba_TP) || is.na(prior_proba_no_benefit)) {
    return(NA)
  }

  assert_single_number(prepost_proba_TP)
  assert_single_number(prior_proba_no_benefit)

  p <- prepost_proba_TP / (1 - prior_proba_no_benefit)
  p <- sapply(p, check_probability_value)

  assert_single_number(p)
  return(p)
}

#' Probability of study success over the replicates actually analysed
#'
#' @description `simulation_for_given_treatment_effect()` drops replicates
#'   whose summary measure is not estimable before analysing them, and marks
#'   those whose fit failed. Its vectorised path then returns one decision per
#'   analysed replicate, and its replicate loop returns one per simulated
#'   replicate with the unanalysed slots left at zero. Averaging the decisions
#'   as returned therefore either fails to fit a row sized for every replicate
#'   or counts the unanalysed ones as failures. Only the successful fits are
#'   averaged here, as the frequentist operating characteristics do.
#'
#' @param results The list returned by `simulation_for_given_treatment_effect()`
#'   with `test_decision` and `fit_success` requested.
#' @return The proportion of successful fits that led to study success, or
#'   `NA` when none succeeded.
#' @keywords internal
analysed_success_probability <- function(results) {
  decisions <- results$test_decisions
  fit_success <- results$fit_success
  if (is.null(fit_success)) {
    stop("fit_success must be requested to tell analysed replicates apart.", call. = FALSE)
  }
  if (length(decisions) != length(fit_success)) {
    stop(length(decisions), " decisions for ", length(fit_success), " fit statuses.", call. = FALSE)
  }
  analysed <- fit_success == "Success"
  if (!any(analysed)) {
    return(NA_real_)
  }
  return(mean(decisions[analysed]))
}


#' Calculate the upper bound probability of false positive
#'
#' @description This function calculates the upper bound probability of false positive based on the model, prior probability of no benefit,
#' source data, theta_0, target sample size per arm, case study configuration, number of replicates, confidence level,
#' null space, and critical value.
#'
#' @param model The model.
#' @param prior_proba_no_benefit The prior probability of no benefit.
#' @param source_data The source data.
#' @param theta_0 The value of theta_0.
#' @param target_sample_size_control Sample size of the control arm in the target study.
#' @param target_sample_size_treatment Sample size of the treatment arm in the target study.
#' @param case_study_config The case study configuration.
#' @param target_to_source_std_ratio Ratio between target and source sampling standard deviations.
#' @param dropout_probability Probability of loss to follow-up over the maximum follow-up
#'   time. Only used for the time-to-event endpoint.
#' @param event_time_distribution Distribution of the event times, either "exponential" or
#'   "weibull". Only used for the time-to-event endpoint.
#' @param treatment_delay Time before the treatment effect starts, in years.
#'   Only used for the time-to-event endpoint.
#' @param n_replicates The number of replicates.
#' @param confidence_level The confidence level.
#' @param null_space The null space (either "left" or "right").
#' @param critical_value The critical value.
#' @param case_study Case study name.
#' @param method Method name.
#' @param n_samples_quantiles_estimation Number of samples used to estimate distribution quantiles.
#'
#' @return The upper bound probability of false positive, defined as \eqn{Pr(Study success|\theta_T = \theta_0) \times Pr(\theta_T \leq \theta_0)}
#'
#' @keywords internal
upper_bound_proba_FP_MC <- function(model,
                                    prior_proba_no_benefit,
                                    source_data,
                                    theta_0,
                                    target_sample_size_control,
                                    target_sample_size_treatment,
                                    case_study_config,
                                    target_to_source_std_ratio,
                                    dropout_probability = 0,
                                    event_time_distribution = "exponential",
                                    treatment_delay = 0,
                                    n_replicates,
                                    confidence_level,
                                    null_space,
                                    critical_value,
                                    case_study,
                                    method,
                                    n_samples_quantiles_estimation) {
  # We need to estimate Pr(Study success|\theta_T = \theta_0)
  treatment_drift <- theta_0 - source_data$treatment_effect_estimate

  target_data <- TargetDataFactory$new()
  target_data <- target_data$create(
    source_data = source_data,
    case_study_config = case_study_config,
    target_sample_size_control = target_sample_size_control,
    target_sample_size_treatment = target_sample_size_treatment,
    treatment_drift = treatment_drift,
    control_drift = 0,
    summary_measure_likelihood = source_data$summary_measure_likelihood,
    target_to_source_std_ratio = target_to_source_std_ratio,
    dropout_probability = dropout_probability,
    event_time_distribution = event_time_distribution,
    treatment_delay = treatment_delay
  )

  results <- model$simulation_for_given_treatment_effect(
    target_data = target_data,
    n_replicates = n_replicates,
    critical_value = critical_value,
    theta_0 = theta_0,
    confidence_level = confidence_level,
    null_space = null_space,
    case_study = case_study,
    method = method,
    n_samples_quantiles_estimation = n_samples_quantiles_estimation,
    to_return = c("test_decision", "fit_success")
  )

  p <- prior_proba_no_benefit * analysed_success_probability(results)

  p <- sapply(p, check_probability_value)
  assert_single_number(p)
  return(p)
}


# The goal here is to perform numerical integration based on a predefined range of values for the treatment effect. This range of values should be the same for all design priors (but not all methods) methods. Since we integrate the conditional power over different design priors and different bounds, the range should

#' Upper bound on the probability of a false positive
#'
#' @param prior_proba_no_benefit Design-prior probability of the null space.
#' @param treatment_effect_values Grid of true treatment effects.
#' @param conditional_proba_success Probability of success at each grid value.
#' @param theta_0 Boundary of the null hypothesis. It must be on the grid.
#' @return `prior_proba_no_benefit` times the probability of success at
#'   `theta_0`, or `NA`.
#' @keywords internal
#' @export
upper_bound_proba_FP <- function(prior_proba_no_benefit,
                                 treatment_effect_values,
                                 conditional_proba_success, theta_0) {
  if (is.na(prior_proba_no_benefit)) {
    return(NA)
  }

  assert_single_number(prior_proba_no_benefit)

  p <- prior_proba_no_benefit * conditional_proba_success[treatment_effect_values == theta_0]

  p <- sapply(p, check_probability_value)

  if (is.list(p)) {
    return(NA)
  }

  if (length(p)>1){
    stop("Length of p is >1.")
  }

  if (is.na(p)){
    return(p)
    #stop("p is NA.")
  }

  assert_single_number(p)
  return(p)
}

#' Contribution of the design-prior mass that lies outside the simulated
#' treatment-effect grid.
#'
#' The grid is derived from the sampling distributions of the data, not from the
#' design prior (see `compute_drift_range()`), so a design prior can place a
#' large share of its mass outside it. Integrating the numerator over the grid
#' alone, while normalising by the hypothesis-space mass obtained from the design
#' prior CDF, understates the operating characteristics -- badly so for wide
#' priors such as the unit-information one.
#'
#' Beyond the grid the rejection rate sits at its limit: 0 far inside the null
#' space and 1 far inside the alternative space. The tail integral therefore
#' collapses to the tail mass times that limit, and needs no extra simulation.
#'
#' @param design_prior_cdf CDF of the design prior.
#' @param edge_value Outer value of the grid on this side.
#' @param side `"lower"` or `"upper"`.
#' @param limit Probability of success far beyond the grid: 0 or 1.
#' @param edge_proba_success Probability of success at `edge_value`, used to
#'   warn when the grid is too narrow.
#' @param space_label `"null"` or `"alternative"`, for the warning.
#' @return The tail mass times `limit`.
#' @keywords internal
#' @export
design_prior_tail_contribution <- function(design_prior_cdf,
                                           edge_value,
                                           side,
                                           limit,
                                           edge_proba_success,
                                           space_label) {
  tail_mass <- if (side == "lower") {
    design_prior_cdf(edge_value)
  } else {
    1 - design_prior_cdf(edge_value)
  }

  if (length(tail_mass) != 1L || !is.finite(tail_mass)) {
    return(0)
  }

  tail_mass <- min(max(tail_mass, 0), 1)

  # The extrapolation is only trustworthy once the grid reaches the flat part of
  # the rejection rate. Say so when it does not, rather than quietly reporting a
  # tail contribution the simulation does not support.
  if (tail_mass > 0.01 && abs(edge_proba_success - limit) > 0.05) {
    msg <- sprintf(
      paste0(
        "The treatment-effect grid does not extend far enough into the %s space: ",
        "the conditional probability of success is %.3g at its outer edge (%.3g), ",
        "but %.1f%% of the design prior mass lies beyond it and is extrapolated as %g."
      ),
      space_label,
      edge_proba_success,
      edge_value,
      100 * tail_mass,
      limit
    )
    warning(msg)
    futile.logger::flog.warn(msg)
  }

  return(tail_mass * limit)
}

#' Prior probability of success of a trial
#'
#' @description Integrates the probability of success over the design prior,
#'   on the grid of true treatment effects, plus the design-prior mass beyond
#'   the grid (see [design_prior_tail_contribution()]).
#'
#' @param conditional_proba_success Probability of success at each grid value.
#' @param treatment_effect_values Grid of true treatment effects.
#' @param design_prior_pdf Design-prior density at each grid value.
#' @param design_prior_cdf CDF of the design prior.
#' @param null_space `"left"` or `"right"`.
#' @return A probability, or `NA` when the grid has fewer than 2 values.
#' @keywords internal
#' @export
prior_proba_success <- function(conditional_proba_success,
                                treatment_effect_values,
                                design_prior_pdf,
                                design_prior_cdf,
                                null_space) {
  if (null_space == "left") {
    lower_tail_limit <- 0
    upper_tail_limit <- 1
  } else if (null_space == "right") {
    lower_tail_limit <- 1
    upper_tail_limit <- 0
  } else {
    stop("Null space must be either 'left' or 'right'.")
  }

  if (length(conditional_proba_success) < 2) {
    return(NA)
  }

  p <- Bolstad2::sintegral(
    x = treatment_effect_values,
    fx = design_prior_pdf * conditional_proba_success,
    n.pts = length(treatment_effect_values)
  )$int

  lower_edge <- which.min(treatment_effect_values)
  upper_edge <- which.max(treatment_effect_values)

  p <- p + design_prior_tail_contribution(
    design_prior_cdf = design_prior_cdf,
    edge_value = treatment_effect_values[lower_edge],
    side = "lower",
    limit = lower_tail_limit,
    edge_proba_success = conditional_proba_success[lower_edge],
    space_label = if (null_space == "left") "null" else "alternative"
  ) + design_prior_tail_contribution(
    design_prior_cdf = design_prior_cdf,
    edge_value = treatment_effect_values[upper_edge],
    side = "upper",
    limit = upper_tail_limit,
    edge_proba_success = conditional_proba_success[upper_edge],
    space_label = if (null_space == "left") "alternative" else "null"
  )

  p <- sapply(p, check_probability_value)
  assert_single_number(p)
  return(p)
}
