#' Frequentist operating characteristics
#'
#' @description Simulates target trials at fixed true treatment effects, and
#'   analyses each with the prior and the decision rule. For each true effect,
#'   it reports the probability of success, with bias, mean squared error and
#'   coverage of the posterior. At a true effect inside the null hypothesis the
#'   probability of success is the type I error rate; outside it, it is the
#'   power.
#'
#'   The true effect is the source effect plus `drift`. A drift of 0 means
#'   the two studies agree.
#'
#' @param prior A borrowing prior, from one of the [borrowing_priors]
#'   builders.
#' @param decision A decision rule, from [decision()]. Its null hypothesis is
#'   also the one the methods that adapt to it use.
#' @param n_per_arm Target sample size per arm.
#' @param drift Differences between the true target effect and the source
#'   effect, on the treatment effect scale. One row of results per value.
#' @param n_rep Number of simulated trials per drift value.
#' @param control_drift Difference between the target and source control
#'   rates (binary endpoint).
#' @param target_to_source_std_ratio Ratio of the target to the source
#'   sampling standard deviation (continuous endpoint).
#' @param confidence_level Level of the credible intervals whose coverage is
#'   reported.
#' @param mcmc_config Optional MCMC settings, as in [posterior()].
#'
#' @return An object of class `bexte_oc_frequentist`: a data frame with one
#'   row per drift value. The main columns are `drift`, `true_effect`,
#'   `null_true` (whether the true effect lies in the null hypothesis),
#'   `success_proba` with its Monte Carlo interval, `bias`, `mse` and
#'   `coverage`.
#'
#' @details The simulation uses R's random number generator. Call
#'   [set.seed()] first to get the same results again.
#'
#' @seealso [oc_bayesian()] to average over a design prior instead of fixing
#'   the true effect.
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' set.seed(1)
#' oc <- oc_frequentist(rmp(src, weight = 0.5), decision(0.975), n_per_arm = 46,
#'                      drift = c(-0.48, 0), n_rep = 100)
#' oc
#' @export
oc_frequentist <- function(prior,
                           decision,
                           n_per_arm,
                           drift = 0,
                           n_rep = 1000,
                           control_drift = 0,
                           target_to_source_std_ratio = 1,
                           confidence_level = 0.95,
                           mcmc_config = NULL) {
  setup <- api_check_oc_args(prior, decision, n_per_arm, n_rep)
  if (!is.numeric(drift) || length(drift) == 0 || anyNA(drift)) {
    stop("`drift` should be a numeric vector with no missing values.", call. = FALSE)
  }
  check_unit_interval(confidence_level, "confidence_level", open = TRUE)
  simulation_config <- api_simulation_config(
    critical_value = setup$critical_value,
    confidence_level = confidence_level
  )

  rows <- lapply(drift, function(treatment_drift) {
    # The pipeline creates and calibrates the model per scenario, since the
    # calibration of some methods depends on the design.
    model <- api_create_model(prior, mcmc_config, config = setup$config)
    target <- api_design_target(
      setup$source, n_per_arm,
      drift = treatment_drift,
      control_drift = control_drift,
      target_to_source_std_ratio = target_to_source_std_ratio
    )
    model$calibrate_for_design(target)
    result <- model$estimate_frequentist_operating_characteristics(
      theta_0 = setup$theta_0,
      target_data = target,
      n_replicates = n_rep,
      critical_value = setup$critical_value,
      confidence_level = confidence_level,
      null_space = setup$null_space,
      n_samples_quantiles_estimation = simulation_config$n_samples_quantiles_estimation,
      case_study = setup$config$name,
      method = prior$method,
      simulation_config = simulation_config
    )
    true_effect <- target$treatment_effect
    scalars <- Filter(function(x) is.atomic(x) && length(x) == 1, result)
    data.frame(
      drift = treatment_drift,
      true_effect = true_effect,
      null_true = api_in_null(true_effect, setup$theta_0, setup$null_space),
      n_per_arm = n_per_arm,
      lapply(scalars, unname),
      check.names = FALSE
    )
  })

  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  attr(out, "method") <- prior$label
  attr(out, "hypothesis") <- setup[c("theta_0", "null_space", "critical_value")]
  attr(out, "n_rep") <- n_rep
  class(out) <- c("bexte_oc_frequentist", "data.frame")
  out
}


#' Design prior
#'
#' @description The distribution of the true target effect that
#'   [oc_bayesian()] draws from.
#'
#' @param type `"source_posterior"` uses the posterior of the source study.
#'   `"unit_information"` widens it to the information of one patient per
#'   arm. `"analysis_prior"` uses the borrowing prior itself (not available
#'   for empirical Bayes methods, whose prior depends on the target data).
#'
#' @return An object of class `bexte_design_prior`.
#'
#' @examples
#' design_prior("source_posterior")
#' @export
design_prior <- function(type = c("source_posterior", "unit_information", "analysis_prior")) {
  structure(list(type = match.arg(type)), class = "bexte_design_prior")
}


#' Bayesian operating characteristics
#'
#' @description Draws true target effects from a design prior, simulates
#'   target trials at each, and analyses them with the prior and the decision
#'   rule. It reports the probability of success averaged over the design
#'   prior, and splits it into true and false positives:
#'
#'   - `prior_proba_success`: the probability that the trial succeeds;
#'   - `prior_proba_no_benefit`: the design-prior probability of the null
#'     hypothesis;
#'   - `prepost_proba_TP`, `prepost_proba_FP`: the probabilities that the
#'     trial succeeds and the treatment works, or does not;
#'   - `average_power`, `average_tie`: the probability of success given that
#'     the treatment works, or does not;
#'   - `upper_bound_proba_FP`: an upper bound on `prepost_proba_FP`.
#'
#' @inheritParams oc_frequentist
#' @param design_prior A design prior, from [design_prior()].
#' @param n_rep Number of simulated trials per draw from the design prior.
#' @param n_draws Number of draws from the design prior.
#'
#' @return An object of class `bexte_oc_bayesian`: a one-row data frame.
#'
#' @details The simulation uses R's random number generator. Call
#'   [set.seed()] first to get the same results again.
#'
#' @seealso [oc_frequentist()] to fix the true effect instead.
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' set.seed(1)
#' oc_bayesian(rmp(src, weight = 0.5), decision(0.975), design_prior("source_posterior"),
#'             n_per_arm = 46, n_rep = 20, n_draws = 20)
#' @export
oc_bayesian <- function(prior,
                        decision,
                        design_prior,
                        n_per_arm,
                        n_rep = 100,
                        n_draws = 200,
                        target_to_source_std_ratio = 1,
                        confidence_level = 0.95,
                        mcmc_config = NULL) {
  setup <- api_check_oc_args(prior, decision, n_per_arm, n_rep)
  if (!inherits(design_prior, "bexte_design_prior")) {
    stop("`design_prior` should come from design_prior().", call. = FALSE)
  }
  check_positive(n_draws, "n_draws")
  check_unit_interval(confidence_level, "confidence_level", open = TRUE)
  if (is.null(mcmc_config)) {
    mcmc_config <- api_default_config("full/mcmc_config.yml")
  }
  simulation_config <- api_simulation_config(
    critical_value = setup$critical_value,
    confidence_level = confidence_level,
    n_samples_design_prior = n_draws
  )

  model <- api_create_model(prior, mcmc_config, config = setup$config)
  if (design_prior$type == "analysis_prior" && isTRUE(model$empirical_bayes)) {
    stop("The analysis prior of an empirical Bayes method depends on the target data, ",
         "so it cannot be a design prior. Use another `design_prior()` type.", call. = FALSE)
  }
  model$calibrate_for_design(api_design_target(
    setup$source, n_per_arm,
    target_to_source_std_ratio = target_to_source_std_ratio
  ))
  sampler <- DesignPrior$new()$create(
    design_prior_type = switch(design_prior$type,
                               unit_information = "ui_design_prior",
                               design_prior$type),
    model = model,
    source_data = setup$source$data,
    case_study_config = setup$config,
    simulation_config = simulation_config,
    mcmc_config = mcmc_config,
    case_study = setup$config$name,
    target_control_rate = setup$source$data$control_rate
  )
  result <- model$estimate_bayesian_operating_characteristics(
    design_prior = sampler,
    theta_0 = setup$theta_0,
    source_data = setup$source$data,
    n_replicates = n_rep,
    critical_value = setup$critical_value,
    confidence_level = confidence_level,
    null_space = setup$null_space,
    n_samples_design_prior = n_draws,
    target_sample_size_per_arm = n_per_arm,
    case_study_config = setup$config,
    target_to_source_std_ratio = target_to_source_std_ratio,
    simulation_config = simulation_config,
    case_study = setup$config$name,
    method = prior$method,
    n_samples_quantiles_estimation = simulation_config$n_samples_quantiles_estimation
  )

  out <- data.frame(
    design_prior = design_prior$type,
    n_per_arm = n_per_arm,
    lapply(result, function(x) unname(unlist(x))),
    check.names = FALSE
  )
  attr(out, "method") <- prior$label
  attr(out, "hypothesis") <- setup[c("theta_0", "null_space", "critical_value")]
  attr(out, "n_rep") <- n_rep
  attr(out, "n_draws") <- n_draws
  class(out) <- c("bexte_oc_bayesian", "data.frame")
  out
}


#' Check the arguments the OC functions share
#'
#' @description Also puts the decision's null hypothesis into the case-study
#'   configuration, so the methods that adapt to the hypothesis and the
#'   decision rule use the same one.
#'
#' @return A list with the `source`, the `config` to create models from, and
#'   the `theta_0`, `null_space` and `critical_value` of the decision.
#' @keywords internal
#' @noRd
api_check_oc_args <- function(prior, decision, n_per_arm, n_rep) {
  if (!inherits(prior, "bexte_prior")) {
    stop("`prior` should come from a prior builder such as npp() or rmp().", call. = FALSE)
  }
  if (!inherits(decision, "bexte_decision")) {
    stop("`decision` should come from decision().", call. = FALSE)
  }
  check_positive(n_per_arm, "n_per_arm")
  check_positive(n_rep, "n_rep")
  source <- prior$source
  hypothesis <- api_hypothesis(decision, source$config)
  config <- source$config
  config$theta_0 <- hypothesis$theta_0
  config$null_space <- hypothesis$null_space
  list(
    source = source,
    config = config,
    theta_0 = hypothesis$theta_0,
    null_space = hypothesis$null_space,
    critical_value = attr(decision, "critical_value")
  )
}


#' Whether a true effect lies in the null hypothesis
#' @keywords internal
#' @noRd
api_in_null <- function(effect, theta_0, null_space) {
  if (null_space == "left") effect <= theta_0 else effect >= theta_0
}
