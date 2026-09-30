# The PDCCPP computes every replicate at once, with its calibration
# interpolated across the replicates' target sampling variances rather than
# searched for replicate by replicate. These tests pin the interpolation, the
# agreement with the per-replicate path, and the accuracy of the power parameter
# against the calibration searched to a tight tolerance.

# The per-replicate path, reached by declining the vectorised one.
PDCCPPPerReplicate <- R6::R6Class(
  "PDCCPPPerReplicate",
  inherit = PDCCPP,
  public = list(vectorised_power_parameter = function(target_data, samples) NULL)
)

pdccpp_botox <- function(tolerance = 1e-4, per_replicate = FALSE) {
  config <- yaml::read_yaml(system.file("conf/case_studies/botox.yml", package = "BExTE"))
  source_data <- SourceData$new(config, NA)
  parameters <- list(
    initial_prior = list("noninformative"), desired_tie = list(0.065),
    significance_level = list(0.05), tolerance = list(tolerance), n_iter = list(1e6)
  )
  model <- Model$new()$create(
    case_study_config = config, method = "PDCCPP",
    method_parameters = parameters, source_data = source_data
  )
  if (per_replicate) {
    prior <- model$prior
    model <- PDCCPPPerReplicate$new(prior = prior, theta_0 = config$theta_0,
                                    null_space = config$null_space)
    model$prior <- prior
  }
  target_data <- TargetDataFactory$new()$create(
    source_data = source_data, case_study_config = config, target_sample_size_per_arm = 58L,
    control_drift = 0, treatment_drift = -source_data$treatment_effect_estimate / 2,
    summary_measure_likelihood = "normal", target_to_source_std_ratio = 1,
    dropout_probability = 0, event_time_distribution = "exponential", treatment_delay = 0
  )
  list(model = model, target_data = target_data, config = config)
}

pdccpp_simulation <- function(setup, n_replicates = 300L) {
  set.seed(20260930)
  setup$model$simulation_for_given_treatment_effect(
    target_data = setup$target_data, n_replicates = n_replicates, critical_value = 0.975,
    theta_0 = setup$config$theta_0, confidence_level = 0.95, null_space = setup$config$null_space,
    case_study = "botox", method = "PDCCPP",
    to_return = c("test_decision", "posterior_mean", "credible_interval", "posterior_parameters"),
    n_samples_quantiles_estimation = 1000,
    simulation_config = list(n_samples_mixture_approx = 1000)
  )
}


test_that("log_grid_interpolation is exact for a function linear in log x", {
  f <- function(x) 3 * log(x) - 2
  x <- c(0.5, 0.7, 1.3, 2, 4)

  expect_equal(log_grid_interpolation(f, x, n_nodes = 5L), f(x), tolerance = 1e-12)
})


test_that("log_grid_interpolation evaluates once when every value is equal", {
  calls <- 0
  f <- function(x) {
    calls <<- calls + 1
    x^2
  }

  expect_equal(log_grid_interpolation(f, rep(1.5, 4)), rep(2.25, 4))
  expect_equal(calls, 1)
})


test_that("log_grid_interpolation rejects values it cannot take the log of", {
  expect_error(log_grid_interpolation(identity, c(1, 0)), "positive")
  expect_error(log_grid_interpolation(identity, c(1, Inf)), "positive")
})


test_that("the PDCCPP takes the vectorised path", {
  setup <- pdccpp_botox()
  set.seed(1)
  samples <- setup$target_data$generate(20L)

  expect_length(setup$model$vectorised_power_parameter(setup$target_data, samples), 20L)
})


test_that("the vectorised PDCCPP agrees with the per-replicate path", {
  vectorised <- pdccpp_simulation(pdccpp_botox())
  per_replicate <- pdccpp_simulation(pdccpp_botox(per_replicate = TRUE))

  expect_identical(vectorised$test_decisions, per_replicate$test_decisions)
  expect_equal(vectorised$posterior_means, per_replicate$posterior_means, tolerance = 1e-3)
  expect_equal(vectorised$credible_intervals, per_replicate$credible_intervals, tolerance = 1e-2)
  expect_equal(
    vectorised$posterior_parameters$power_parameter,
    per_replicate$posterior_parameters$power_parameter,
    tolerance = 1e-2
  )
})


test_that("the vectorised power parameter is closer to the exact calibration than a per-replicate search", {
  # Near the borrowing cut-off the power parameter is very sensitive to the
  # calibration, so a search stopped at the configured 1e-4 moves it by up to
  # about 5e-3. The vectorised path searches its few nodes to 1e-9.
  exact <- pdccpp_simulation(pdccpp_botox(tolerance = 1e-9, per_replicate = TRUE))
  per_replicate <- pdccpp_simulation(pdccpp_botox(per_replicate = TRUE))
  vectorised <- pdccpp_simulation(pdccpp_botox())

  error <- function(result) {
    abs(result$posterior_parameters$power_parameter - exact$posterior_parameters$power_parameter)
  }

  expect_lte(mean(error(vectorised)), mean(error(per_replicate)))
  expect_lt(max(error(vectorised)), 2e-3)
})
