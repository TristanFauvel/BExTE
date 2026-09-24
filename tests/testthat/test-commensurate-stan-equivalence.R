# The commensurate power prior is the one model on the vectorised fast path
# whose scalar path is a Stan fit rather than a closed form. It therefore
# cannot be compared replicate by replicate to machine precision, the way
# test-vectorised_kernel_equivalence.R and test-vectorised_npp.R compare the
# others: the scalar path is exact only up to Monte Carlo error.
#
# What can be pinned is that Monte Carlo error is the only thing between them.
# On fixed data the largest absolute gap falls off like the square root of the
# chain length, with no floor:
#
#   iterations per chain    1000      4000     16000     64000
#   posterior mean       3.7e-03   7.1e-04   9.0e-04   5.3e-04
#   posterior median     2.2e-03   1.4e-03   1.2e-03   2.5e-04
#   credible interval    1.3e-02   5.2e-03   3.1e-03   2.1e-03
#   power parameter      9.9e-03   3.0e-03   3.0e-03   1.2e-03
#   tau                  1.7e-02   7.3e-03   3.4e-03   3.4e-03
#
# The bounds below are set several times the 4000-iteration column, which is
# what this test samples, so they fail on a systematic difference rather than
# on an unlucky seed.
#
# Sampling means compiling and running the Stan program, so the test is skipped
# wherever CmdStan is unavailable, as it is in CI.

# commensurate_equivalence_config() and commensurate_equivalence_mcmc_config()
# live in helper-commensurate.R, so that the gamma == 1 model's equivalence
# test compares the two paths on exactly the same case study.

test_that("the commensurate fast path agrees with the Stan fit it replaces", {
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

  # A half-normal tau, so that every reported moment exists on both paths. The
  # families whose moments diverge are covered separately below.
  model <- Model$new()$create(
    case_study_config = case_study_config,
    method = "commensurate_power_prior",
    method_parameters = list(
      initial_prior = list("noninformative"),
      heterogeneity_prior = list(family = "half_normal", std_dev = 1)
    ),
    source_data = source_data,
    mcmc_config = mcmc_config
  )

  scalar_class <- R6::R6Class(
    "ScalarOnlyCommensurate",
    inherit = GaussianCommensuratePowerPrior,
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
      method = "commensurate_power_prior",
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
    largest_gap(function(x) x$posterior_parameters$power_parameter_mean), 1.5e-2
  )
  expect_lt(
    largest_gap(function(x) x$posterior_parameters$power_parameter_std), 1.5e-2
  )
  expect_lt(
    largest_gap(function(x) x$posterior_parameters$heterogeneity_parameter_mean),
    3e-2
  )
  expect_lt(
    largest_gap(function(x) x$posterior_parameters$heterogeneity_parameter_std),
    3e-2
  )

  # The decision compares the lower interval bound against theta_0, so a
  # replicate whose bound sits within Monte Carlo error of it can legitimately
  # fall either way. Compare only the replicates that are not on the fence.
  decided <- abs(vectorised$credible_intervals[, 1]) > 2e-2
  expect_true(any(decided))
  expect_equal(vectorised$test_decisions[decided], scalar$test_decisions[decided])
})


test_that("both paths report a tau moment that does not exist as infinite", {
  skip_if_not(
    !inherits(try(cmdstanr::cmdstan_path(), silent = TRUE), "try-error"),
    "CmdStan is not installed"
  )

  case_study_config <- commensurate_equivalence_config()
  mcmc_config <- commensurate_equivalence_mcmc_config(chain_length = 2000L)
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

  model <- Model$new()$create(
    case_study_config = case_study_config,
    method = "commensurate_power_prior",
    method_parameters = list(
      initial_prior = list("noninformative"),
      heterogeneity_prior = list(family = "inverse_gamma", alpha = 1 / 3, beta = 1)
    ),
    source_data = source_data,
    mcmc_config = mcmc_config
  )

  scalar_class <- R6::R6Class(
    "ScalarOnlyCommensurate",
    inherit = GaussianCommensuratePowerPrior,
    public = list(vectorised_replicate_inference = function(...) NULL)
  )
  reference <- scalar_class$new(prior = model$prior, mcmc_config = mcmc_config)
  reference$prior <- model$prior
  reference$draws_dir <- model$draws_dir

  to_return <- c("posterior_mean", "posterior_parameters")
  run <- function(fitted) {
    set.seed(11)
    fitted$simulation_for_given_treatment_effect(
      target_data = target_data,
      n_replicates = 3,
      critical_value = 0.975,
      theta_0 = 0,
      confidence_level = 0.95,
      null_space = "left",
      case_study = "unit_test",
      method = "commensurate_power_prior",
      to_return = to_return,
      n_samples_quantiles_estimation = 100
    )
  }

  vectorised <- run(model)
  scalar <- run(reference)

  # The treatment effect and the power parameter are unaffected by the tau
  # tail, so they still agree.
  expect_lt(max(abs(vectorised$posterior_means - scalar$posterior_means)), 5e-3)
  expect_lt(
    max(abs(vectorised$posterior_parameters$power_parameter_mean -
              scalar$posterior_parameters$power_parameter_mean)),
    2e-2
  )

  # E[tau] does not exist under an InvGamma(1/3, 1) prior on tau^2, and the
  # target marginal likelihood tends to a positive constant as tau grows, so
  # the posterior does not restore it. The sampler's draws would still give a
  # finite mean, a property of the run rather than of the posterior, so both
  # paths report the moment as infinite instead.
  expect_true(all(is.infinite(
    vectorised$posterior_parameters$heterogeneity_parameter_mean
  )))
  expect_true(all(is.infinite(
    scalar$posterior_parameters$heterogeneity_parameter_mean
  )))
})
