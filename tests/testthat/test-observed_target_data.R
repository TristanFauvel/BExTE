observed_belimumab <- function() {
  config <- yaml::yaml.load_file(
    system.file("conf/case_studies/belimumab.yml", package = "BExTE")
  )
  target_data <- ObservedTargetData$new(
    treatment_effect_estimate = config$target$treatment_effect,
    treatment_effect_standard_error = config$target$standard_error,
    target_sample_size_per_arm = as.integer(config$target$total / 2),
    summary_measure_likelihood = config$summary_measure_likelihood
  )
  list(config = config, target_data = target_data)
}


test_that("observed target data carries the per-patient standard deviation", {
  observed <- observed_belimumab()$target_data

  # The scale the simulated samples report: the standard error of the
  # estimate times the square root of the sample size per arm.
  expect_equal(
    observed$sample$standard_deviation,
    observed$sample$treatment_effect_standard_error * sqrt(observed$sample_size_per_arm)
  )
})


test_that("the frequentist tests run on observed target data", {
  observed <- observed_belimumab()
  source_data <- ObservedSourceData$new(observed$config)

  for (method in c("test_then_pool_difference", "test_then_pool_equivalence")) {
    model <- Model$new()$create(
      case_study_config = observed$config,
      method = method,
      method_parameters = list(
        initial_prior = "noninformative",
        equivalence_margin = 0.1,
        significance_level = 0.05
      ),
      source_data = source_data
    )
    expect_no_error(model$inference(target_data = observed$target_data))
  }

  model <- Model$new()$create(
    case_study_config = observed$config,
    method = "p_value_based_PP",
    method_parameters = list(
      initial_prior = "noninformative",
      shape_parameter = 0.5,
      equivalence_margin = 0.1
    ),
    source_data = source_data
  )
  model$inference(target_data = observed$target_data)
  expect_true(is.finite(model$posterior_parameters$power_parameter))
})
