# The gamma == 1 counterpart of test-commensurate-stan-equivalence.R: the plain
# commensurate prior also runs the simulation through a quadrature mixture
# rather than a Stan fit per replicate, so the same agreement has to hold.
#
# Its mixture is one dimensional where the power prior's is two, so the
# quadrature error is smaller here, but the scalar path is still a sampler and
# the bounds are still set several times the Monte Carlo error at this chain
# length. The case study and the sampler settings are shared with that file,
# through helper-commensurate.R.
#
# Sampling means compiling and running the Stan program, so the test is skipped
# wherever CmdStan is unavailable, as it is in CI.

test_that("the commensurate prior fast path agrees with the Stan fit", {
  skip_if_not(
    !inherits(try(cmdstanr::cmdstan_path(), silent = TRUE), "try-error"),
    "CmdStan is not installed"
  )

  case_study_config <- commensurate_equivalence_config()
  mcmc_config <- commensurate_equivalence_mcmc_config()
  source_data <- SourceData$new(case_study_config)
  target_data <- TargetDataFactory$new()$create(
    source_data = source_data,
    case_study_config = case_study_config,
    target_sample_size_per_arm = 60,
    control_drift = 0,
    treatment_drift = 0,
    summary_measure_likelihood = "normal",
    target_to_source_std_ratio = 1
  )

  # A half-normal tau, so that every reported moment exists on both paths.
  model <- Model$new()$create(
    case_study_config = case_study_config,
    method = "commensurate_prior",
    method_parameters = list(
      initial_prior = list("noninformative"),
      heterogeneity_prior = list(family = "half_normal", std_dev = 1)
    ),
    source_data = source_data,
    mcmc_config = mcmc_config
  )

  expect_s3_class(model, "GaussianCommensuratePrior")

  scalar_class <- R6::R6Class(
    "ScalarOnlyCommensuratePrior",
    inherit = GaussianCommensuratePrior,
    public = list(vectorised_replicate_inference = function(...) NULL)
  )
  reference <- scalar_class$new(prior = model$prior, mcmc_config = mcmc_config)
  reference$prior <- model$prior
  reference$draws_dir <- model$draws_dir

  to_return <- c("test_decision", "posterior_mean", "posterior_median",
                 "credible_interval", "posterior_parameters", "fit_success")

  # Without this the comparison below would silently run the scalar path twice
  # and pass for the wrong reason.
  set.seed(1)
  expect_false(is.null(model$vectorised_replicate_inference(
    target_data = target_data,
    samples = target_data$generate(3),
    to_return = to_return,
    critical_value = 0.975,
    theta_0 = 0,
    confidence_level = 0.95,
    null_space = "left"
  )))
  expect_null(reference$vectorised_replicate_inference())

  run <- function(fitted) {
    # The same seed gives both paths the same replicates: the data are drawn up
    # front, before either path consumes any further random numbers.
    set.seed(7)
    fitted$simulation_for_given_treatment_effect(
      target_data = target_data,
      n_replicates = 4,
      critical_value = 0.975,
      theta_0 = 0,
      confidence_level = 0.95,
      null_space = "left",
      case_study = "unit_test",
      method = "commensurate_prior",
      to_return = to_return,
      n_samples_quantiles_estimation = 100
    )
  }

  vectorised <- run(model)
  scalar <- run(reference)

  largest_gap <- function(field) max(abs(field(vectorised) - field(scalar)))

  expect_equal(vectorised$fit_success, scalar$fit_success)
  expect_lt(largest_gap(function(x) x$posterior_means), 5e-3)
  expect_lt(largest_gap(function(x) x$posterior_medians), 5e-3)
  expect_lt(largest_gap(function(x) x$credible_intervals), 2e-2)
  expect_lt(
    largest_gap(function(x) x$posterior_parameters$heterogeneity_parameter_mean),
    3e-2
  )
  expect_lt(
    largest_gap(function(x) x$posterior_parameters$heterogeneity_parameter_std),
    3e-2
  )

  # Neither path has a power parameter to report.
  expect_null(vectorised$posterior_parameters$power_parameter_mean)
  expect_null(scalar$posterior_parameters$power_parameter_mean)

  # The decision compares the lower interval bound against theta_0, so a
  # replicate whose bound sits within Monte Carlo error of it can legitimately
  # fall either way. Compare only the replicates that are not on the fence.
  decided <- abs(vectorised$credible_intervals[, 1]) > 2e-2
  expect_true(any(decided))
  expect_equal(vectorised$test_decisions[decided], scalar$test_decisions[decided])
})


test_that("the Stan fit borrows more than the power prior's does", {
  skip_if_not(
    !inherits(try(cmdstanr::cmdstan_path(), silent = TRUE), "try-error"),
    "CmdStan is not installed"
  )

  # Dropping gamma removes a discount that can only ever widen the prior, so on
  # the same data and the same tau prior the commensurate prior has to sit
  # closer to the source estimate than the commensurate power prior does. This
  # is the substantive difference between the two methods, and it is what the
  # paper compares them for.
  case_study_config <- commensurate_equivalence_config()
  mcmc_config <- commensurate_equivalence_mcmc_config()
  source_data <- SourceData$new(case_study_config)
  target_data <- TargetDataFactory$new()$create(
    source_data = source_data,
    case_study_config = case_study_config,
    target_sample_size_per_arm = 60,
    control_drift = 0,
    treatment_drift = 0,
    summary_measure_likelihood = "normal",
    target_to_source_std_ratio = 1
  )

  method_parameters <- list(
    initial_prior = list("noninformative"),
    heterogeneity_prior = list(family = "half_normal", std_dev = 1)
  )
  fitted <- function(method) {
    Model$new()$create(
      case_study_config = case_study_config,
      method = method,
      method_parameters = method_parameters,
      source_data = source_data,
      mcmc_config = mcmc_config
    )
  }

  run <- function(method) {
    set.seed(7)
    fitted(method)$simulation_for_given_treatment_effect(
      target_data = target_data,
      n_replicates = 4,
      critical_value = 0.975,
      theta_0 = 0,
      confidence_level = 0.95,
      null_space = "left",
      case_study = "unit_test",
      method = method,
      to_return = c("posterior_mean", "credible_interval"),
      n_samples_quantiles_estimation = 100
    )
  }

  commensurate <- run("commensurate_prior")
  power <- run("commensurate_power_prior")

  source_estimate <- source_data$treatment_effect_estimate
  expect_true(all(
    abs(commensurate$posterior_means - source_estimate) <=
      abs(power$posterior_means - source_estimate) + 1e-8
  ))

  # More borrowing also means a tighter interval.
  width <- function(x) x$credible_intervals[, 2] - x$credible_intervals[, 1]
  expect_true(all(width(commensurate) <= width(power) + 1e-8))
})
