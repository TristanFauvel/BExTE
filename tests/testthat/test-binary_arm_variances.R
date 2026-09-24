# The standard error of a difference in proportions divides each arm's
# Bernoulli variance by that arm's own sample size. The target arms are equal
# in every configuration today, which hid a swap of the two denominators; the
# arms are made unequal here so that the swap would show.

binary_target_with_unequal_arms <- function() {
  case_study_config <- list(
    endpoint = "binary",
    summary_measure_likelihood = "binomial",
    source = list(
      control = 100,
      treatment = 100,
      responses = list(control = 10, treatment = 60)
    )
  )
  source_data <- SourceData$new(case_study_config)

  target_data <- BinaryTargetData$new(
    source_data = source_data,
    sampling_approximation = FALSE,
    target_sample_size_per_arm = 100,
    control_drift = 0,
    treatment_drift = 0,
    summary_measure_likelihood = "binomial"
  )
  target_data$sample_size_control <- 50
  target_data$sample_size_treatment <- 200
  target_data
}

test_that("generate() divides each arm's variance by that arm's sample size", {
  target_data <- binary_target_with_unequal_arms()

  set.seed(3)
  samples <- target_data$generate(20)

  treatment <- samples$sample_treatment_rate
  control <- samples$sample_control_rate
  expect_equal(
    samples$treatment_effect_standard_error,
    sqrt(treatment * (1 - treatment) / 200 + control * (1 - control) / 50)
  )
})
