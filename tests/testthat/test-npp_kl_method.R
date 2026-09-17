## Gaussian_NPP_KL is Gaussian_NPP with the Beta prior on the power parameter
## calibrated from the design instead of read off the configuration grid.
## Everything downstream of the prior is inherited, so what has to be pinned is
## the wiring: that the prior is fixed once per scenario and not per replicate,
## that it is the prior the calibration actually returned, and that a model
## which has not been calibrated refuses to analyse anything rather than falling
## back on the placeholder its parent needed at construction.

npp_kl_case_study_config <- function(null_space = "left") {
  list(
    name = "unit_test", endpoint = "continuous",
    summary_measure_likelihood = "normal", sampling_approximation = TRUE,
    theta_0 = 0, null_space = null_space,
    source = list(control = 562, treatment = 563,
                  treatment_effect = 0.481, standard_error = 0.1208)
  )
}

npp_kl_method_parameters <- function(...) {
  parameters <- list(
    initial_prior = list("noninformative"),
    lambda_kl = list(0.5),
    c_target = list(10),
    d_mtd_rule = list("source_to_null"),
    d_mtd_multiplier = list(1)
  )
  ## Plain replacement, not modifyList(): each value here is an unnamed
  ## length-one list, and modifyList() recurses into two lists rather than
  ## replacing one with the other, so an override would be dropped in silence.
  overrides <- list(...)
  parameters[names(overrides)] <- overrides
  parameters
}

npp_kl_model <- function(method_parameters = npp_kl_method_parameters(),
                         null_space = "left") {
  case_study_config <- npp_kl_case_study_config(null_space)
  source_data <- SourceData$new(case_study_config)
  model <- Model$new()$create(
    case_study_config = case_study_config, method = "NPP_KL",
    method_parameters = method_parameters, source_data = source_data
  )
  list(model = model, source_data = source_data,
       case_study_config = case_study_config)
}

npp_kl_target_data <- function(fixture, target_sample_size_per_arm = 100L) {
  TargetDataFactory$new()$create(
    source_data = fixture$source_data,
    case_study_config = fixture$case_study_config,
    target_sample_size_per_arm = target_sample_size_per_arm,
    control_drift = 0,
    treatment_drift = 0,
    summary_measure_likelihood = "normal",
    target_to_source_std_ratio = 1
  )
}

npp_kl_simulate <- function(model, target_data, n_replicates = 50L, seed = 1L) {
  set.seed(seed)
  model$simulation_for_given_treatment_effect(
    target_data = target_data,
    n_replicates = n_replicates,
    critical_value = 0.975,
    theta_0 = 0,
    confidence_level = 0.95,
    null_space = "left",
    case_study = "unit_test",
    method = "NPP_KL",
    to_return = c("credible_interval", "test_decision", "posterior_mean",
                  "posterior_median", "posterior_parameters"),
    n_samples_quantiles_estimation = 1000
  )
}

test_that("the method is dispatched and starts out uncalibrated", {
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()

  expect_s3_class(fixture$model, "Gaussian_NPP_KL")
  expect_s3_class(fixture$model, "Gaussian_NPP")
  expect_equal(fixture$model$method, "NPP_KL")

  ## The parent needed a mean and a standard deviation to construct at all, so a
  ## placeholder Beta(1, 1) was passed to it. Nothing must be left behind that
  ## would let an uncalibrated model quietly analyse under that placeholder.
  expect_null(fixture$model$p)
  expect_null(fixture$model$q)
})

test_that("an uncalibrated model refuses to analyse", {
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)

  expect_error(
    npp_kl_simulate(fixture$model, target_data),
    "calibrate_for_design"
  )
})

test_that("calibrating the design fixes the prior the calibration returned", {
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)

  calibration <- fixture$model$calibrate_for_design(target_data)

  expect_equal(fixture$model$p, calibration$alpha_gamma)
  expect_equal(fixture$model$q, calibration$beta_gamma)

  moments <- npp_kl_beta_moments(calibration$alpha_gamma, calibration$beta_gamma)
  expect_equal(fixture$model$power_parameter_mean, moments$mean)
  expect_equal(fixture$model$power_parameter_std, moments$sd)

  ## The expected target standard error is the design's, not a replicate's.
  expect_equal(
    calibration$se_target_expected,
    target_data$standard_deviation / sqrt(target_data$sample_size_per_arm)
  )
})

test_that("the prior does not change with the replicates it analyses", {
  ## The point of calibrating from the design is that the same prior analyses
  ## every replicate of a scenario, however the target estimates come out. Two
  ## different sets of replicates of the same design therefore report identical
  ## shape parameters.
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)
  fixture$model$calibrate_for_design(target_data)

  first <- npp_kl_simulate(fixture$model, target_data, seed = 1L)
  second <- npp_kl_simulate(fixture$model, target_data, seed = 99L)

  expect_false(isTRUE(all.equal(first$posterior_means, second$posterior_means)))

  for (results in list(first, second)) {
    expect_equal(length(unique(results$posterior_parameters$alpha_gamma)), 1)
    expect_equal(length(unique(results$posterior_parameters$beta_gamma)), 1)
  }
  expect_equal(
    unique(first$posterior_parameters$alpha_gamma),
    unique(second$posterior_parameters$alpha_gamma)
  )
  expect_equal(
    unique(first$posterior_parameters$beta_gamma),
    unique(second$posterior_parameters$beta_gamma)
  )
})

test_that("a different target sample size is a different calibration", {
  npp_kl_calibration_cache_reset()

  small <- npp_kl_model()
  small$model$calibrate_for_design(npp_kl_target_data(small, 25L))

  large <- npp_kl_model()
  large$model$calibrate_for_design(npp_kl_target_data(large, 400L))

  expect_false(isTRUE(all.equal(small$model$p, large$model$p)))
  expect_equal(npp_kl_calibration_cache_size(), 2)
})

test_that("the calibrated prior reproduces the ordinary NPP set to the same shapes", {
  ## The method is the normalised power prior with a different prior, nothing
  ## else, so setting Gaussian_NPP to the calibrated shapes has to give the same
  ## posterior replicate by replicate. Gaussian_NPP takes a mean and a standard
  ## deviation rather than shapes, and converts them back, which is the round
  ## trip this also checks.
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)
  calibration <- fixture$model$calibrate_for_design(target_data)

  moments <- npp_kl_beta_moments(calibration$alpha_gamma, calibration$beta_gamma)
  reference <- Model$new()$create(
    case_study_config = fixture$case_study_config, method = "NPP",
    method_parameters = list(
      initial_prior = list("noninformative"),
      power_parameter_mean = list(moments$mean),
      power_parameter_std = list(moments$sd)
    ),
    source_data = fixture$source_data
  )

  expect_equal(reference$p, calibration$alpha_gamma)
  expect_equal(reference$q, calibration$beta_gamma)

  calibrated_results <- npp_kl_simulate(fixture$model, target_data)
  reference_results <- npp_kl_simulate(reference, target_data)

  expect_equal(calibrated_results$test_decisions, reference_results$test_decisions)
  expect_equal(calibrated_results$posterior_means, reference_results$posterior_means)
  expect_equal(calibrated_results$posterior_medians, reference_results$posterior_medians)
  expect_equal(calibrated_results$credible_intervals, reference_results$credible_intervals)
  expect_equal(
    calibrated_results$posterior_parameters$power_parameter_mean,
    reference_results$posterior_parameters$power_parameter_mean
  )
})

test_that("the reported columns describe both the calibration and the posterior", {
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)
  calibration <- fixture$model$calibrate_for_design(target_data)

  results <- npp_kl_simulate(fixture$model, target_data)
  reported <- results$posterior_parameters

  expect_setequal(
    colnames(reported),
    c("power_parameter_mean", "power_parameter_std", "alpha_gamma",
      "beta_gamma", "prior_gamma_mean", "prior_gamma_sd", "d_mtd",
      "se_target_expected", "kl_objective_value", "calibration_converged")
  )

  ## Every column has to survive being averaged over the replicates, which is
  ## what the reporting layer does with them; a character column would not.
  expect_true(all(vapply(reported, is.numeric, logical(1))))

  expect_equal(unique(reported$d_mtd), calibration$d_mtd)
  expect_equal(unique(reported$calibration_converged), 1)
  expect_equal(
    unique(reported$prior_gamma_mean),
    calibration$alpha_gamma / (calibration$alpha_gamma + calibration$beta_gamma)
  )
})

test_that("borrowing falls away as the target moves towards the null", {
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)
  fixture$model$calibrate_for_design(target_data)

  theta_source <- fixture$source_data$treatment_effect_estimate
  standard_error <- target_data$standard_deviation /
    sqrt(target_data$sample_size_per_arm)

  ## One deterministic replicate per target estimate, so the comparison is of
  ## the method rather than of the sampling noise.
  borrowed <- vapply(c(0, 0.5, 1), function(fraction) {
    sample <- data.frame(
      treatment_effect_estimate = theta_source * (1 - fraction),
      treatment_effect_standard_error = standard_error
    )
    fixture$model$vectorised_replicate_inference(
      target_data = target_data, samples = sample,
      to_return = c("posterior_parameters", "posterior_mean"),
      critical_value = 0.975, theta_0 = 0,
      confidence_level = 0.95, null_space = "left"
    )$posterior_parameters$power_parameter_mean
  }, numeric(1))

  expect_true(all(diff(borrowed) < 0))
})

test_that("the benefit direction follows the case study's null space", {
  npp_kl_calibration_cache_reset()

  left <- npp_kl_model(null_space = "left")
  right <- npp_kl_model(null_space = "right")

  expect_equal(left$model$calibration_settings$benefit_sign, 1)
  expect_equal(right$model$calibration_settings$benefit_sign, -1)

  ## An explicit sign in the method parameters still wins, for a case study
  ## whose null space does not describe the direction of benefit.
  overridden <- npp_kl_model(
    npp_kl_method_parameters(benefit_sign = list(-1)), null_space = "left"
  )
  expect_equal(overridden$model$calibration_settings$benefit_sign, -1)
})

test_that("an unimplemented discrepancy rule is refused at construction", {
  expect_error(
    npp_kl_model(npp_kl_method_parameters(d_mtd_rule = list("half_way"))),
    "d_mtd_rule"
  )
})

test_that("the configured criterion reaches the calibration", {
  npp_kl_calibration_cache_reset()

  fixture <- npp_kl_model(npp_kl_method_parameters(
    lambda_kl = list(1), c_target = list(5), d_mtd_multiplier = list(0.5)
  ))
  calibration <- fixture$model$calibrate_for_design(npp_kl_target_data(fixture))

  expect_equal(calibration$lambda_kl, 1)
  expect_equal(calibration$c_target, 5)
  expect_equal(calibration$d_mtd_multiplier, 0.5)
  expect_equal(
    calibration$d_mtd,
    0.5 * abs(fixture$source_data$treatment_effect_estimate)
  )
})

test_that("the quadrature mixture holds up at the bounds of the shape parameters", {
  ## npp_prior_mixture() builds a Gauss-Jacobi rule from the shapes directly, so
  ## the extremes the calibration is allowed to return have to be usable there
  ## as well as inside the calibration's own quadrature.
  fixture <- npp_kl_model()
  bounds <- NPP_KL_DEFAULT_BOUNDS

  for (shapes in list(bounds, rev(bounds), c(bounds[1], bounds[1]),
                      c(bounds[2], bounds[2]))) {
    fixture$model$p <- shapes[1]
    fixture$model$q <- shapes[2]
    mixture <- npp_prior_mixture(fixture$model)

    label <- paste(shapes, collapse = ", ")
    expect_equal(sum(mixture$weights), 1, info = label)
    expect_true(all(is.finite(mixture$sds)), info = label)
    expect_true(all(mixture$power_parameter > 0 & mixture$power_parameter < 1),
                info = label)
  }
})

test_that("repeated scalar inference does not accumulate reported columns", {
  ## The scalar path analyses one replicate at a time on the same object, so
  ## the calibration columns have to be overwritten rather than appended.
  ## Appending grew the list by eight duplicate names per replicate, and the
  ## replicate loop turns that list into a data frame row before rbind-ing it.
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()
  target_data <- npp_kl_target_data(fixture)
  fixture$model$calibrate_for_design(target_data)

  observed <- ObservedTargetData$new(
    treatment_effect_estimate = 0.4,
    treatment_effect_standard_error = target_data$standard_deviation /
      sqrt(target_data$sample_size_per_arm),
    target_sample_size_per_arm = target_data$sample_size_per_arm,
    summary_measure_likelihood = "normal"
  )

  fixture$model$inference(observed)
  after_one <- names(fixture$model$posterior_parameters)

  for (estimate in c(0.3, 0.2, 0.1)) {
    observed$sample$treatment_effect_estimate <- estimate
    fixture$model$inference(observed)
  }

  expect_equal(names(fixture$model$posterior_parameters), after_one)
  expect_false(anyDuplicated(names(fixture$model$posterior_parameters)) > 0)
  expect_equal(nrow(data.frame(fixture$model$posterior_parameters)), 1)
})

test_that("reaching for the prior before calibration names the cause", {
  ## The design priors and the effective sample sizes read the prior rather than
  ## running inference, so they bypass the guard on inference() entirely. An
  ## uncalibrated model used to reach rbeta() with NULL shape parameters and
  ## fail as "invalid arguments", from a call stack that named neither the
  ## method nor the calibration. compute_bayesian_ocs() rebuilds the model from
  ## the results file, so this is a path a real run takes.
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_model()

  expect_error(fixture$model$sample_prior(10), "calibrate_for_design")
  expect_error(fixture$model$prior_pdf(0.2), "calibrate_for_design")

  fixture$model$calibrate_for_design(npp_kl_target_data(fixture))

  set.seed(1)
  samples <- fixture$model$sample_prior(100)
  expect_length(samples, 100)
  expect_true(all(is.finite(samples)))
  expect_true(is.finite(fixture$model$prior_pdf(0.2)))
})
