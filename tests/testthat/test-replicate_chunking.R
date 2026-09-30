# Vectorised analyses run on chunks of replicates to bound their memory. Every
# replicate is analysed on its own, so the chunking must not change any result.

chunking_samples <- function(n = 25) {
  set.seed(3)
  data.frame(
    treatment_effect_estimate = stats::rnorm(n, 0.2, 0.15),
    treatment_effect_standard_error = stats::runif(n, 0.08, 0.12),
    standard_deviation = stats::runif(n, 0.8, 1.2)
  )
}

chunking_analysis <- function(samples) {
  mixture <- list(
    weights = c(0.3, 0.5, 0.2),
    means = c(0, 0.25, 0.6),
    sds = c(0.5, 0.05, 0.2)
  )
  posterior <- normal_mixture_posterior(
    weights = mixture$weights,
    means = mixture$means,
    sds = mixture$sds,
    estimate = samples$treatment_effect_estimate,
    standard_error = samples$treatment_effect_standard_error
  )
  vectorised_normal_mixture_simulation(
    weights = mixture$weights,
    means = mixture$means,
    sds = mixture$sds,
    samples = samples,
    target_data = list(sample_size_per_arm = 50),
    to_return = c("test_decision", "posterior_mean", "posterior_median",
                  "credible_interval", "posterior_parameters", "ess_moment",
                  "ess_precision", "ess_elir", "fit_success"),
    critical_value = 0.975,
    theta_0 = 0,
    confidence_level = 0.95,
    null_space = "left",
    posterior_parameters = data.frame(
      first_weight = posterior$weights[, 1],
      estimate = samples$treatment_effect_estimate
    ),
    posterior = posterior
  )
}


test_that("chunking the replicates leaves every result unchanged", {
  samples <- chunking_samples(25)

  whole <- analyse_in_replicate_chunks(samples, chunking_analysis, chunk_size = 1000L)
  chunked <- analyse_in_replicate_chunks(samples, chunking_analysis, chunk_size = 7L)

  expect_identical(names(chunked), names(whole))
  for (field in names(whole)) {
    expect_equal(chunked[[field]], whole[[field]], label = field)
  }
  expect_equal(nrow(chunked$credible_intervals), 25)
  expect_equal(nrow(chunked$posterior_parameters), 25)
})


test_that("outputs that were not requested stay NULL across chunks", {
  pieces <- list(
    list(test_decisions = c(1, 0), posterior_means = NULL),
    list(test_decisions = 1, posterior_means = NULL)
  )

  combined <- combine_replicate_results(pieces)

  expect_identical(names(combined), c("test_decisions", "posterior_means"))
  expect_equal(combined$test_decisions, c(1, 0, 1))
  expect_null(combined$posterior_means)
})
