# Every method of a scenario reaches the generation of its replicates with the
# same random number generator state, so generate_replicates() stores the
# replicates once and lets the other methods read them back. These tests pin
# that reuse is exact - the same replicates and the same generator state
# afterwards as generating them again - and that nothing is reused where the
# replicates would differ.

generation_cache_target_data <- function(treatment_drift = 0.1) {
  config <- yaml::read_yaml(system.file("conf/case_studies/mepolizumab.yml", package = "BExTE"))
  source_data <- SourceData$new(config, 1)
  TargetDataFactory$new()$create(
    source_data = source_data, case_study_config = config, target_sample_size_per_arm = 30L,
    control_drift = 0, treatment_drift = treatment_drift, summary_measure_likelihood = "normal",
    target_to_source_std_ratio = 1, dropout_probability = 0,
    event_time_distribution = "exponential", treatment_delay = 0
  )
}

# Generation followed by one further draw, to catch a generator state that is
# not restored exactly.
generated_then_next_draw <- function(generate) {
  set.seed(20260930)
  samples <- generate()
  list(samples = samples, next_draw = stats::runif(3))
}


test_that("without a cache directory, generation is unchanged", {
  target_data <- generation_cache_target_data()

  direct <- generated_then_next_draw(function() target_data$generate(50L))
  wrapped <- generated_then_next_draw(function() generate_replicates(target_data, 50L))

  expect_identical(wrapped, direct)
})


test_that("reused replicates and the generator state after them are those of a fresh generation", {
  cache_dir <- withr::local_tempdir()
  target_data <- generation_cache_target_data()

  direct <- generated_then_next_draw(function() target_data$generate(50L))
  stored <- generated_then_next_draw(function() {
    generate_replicates(target_data, 50L, cache_dir = cache_dir, min_seconds = 0)
  })
  reused <- generated_then_next_draw(function() {
    generate_replicates(target_data, 50L, cache_dir = cache_dir, min_seconds = 0)
  })

  expect_length(list.files(cache_dir, pattern = "\\.rds$"), 1)
  expect_identical(stored, direct)
  expect_identical(reused, direct)
})


test_that("a different generator state or design is not served from the cache", {
  cache_dir <- withr::local_tempdir()
  target_data <- generation_cache_target_data()

  set.seed(1)
  generate_replicates(target_data, 50L, cache_dir = cache_dir, min_seconds = 0)
  set.seed(2)
  other_seed <- generate_replicates(target_data, 50L, cache_dir = cache_dir, min_seconds = 0)
  set.seed(1)
  other_drift <- generate_replicates(generation_cache_target_data(treatment_drift = 0.2), 50L,
                                     cache_dir = cache_dir, min_seconds = 0)
  set.seed(1)
  other_count <- generate_replicates(target_data, 40L, cache_dir = cache_dir, min_seconds = 0)

  expect_length(list.files(cache_dir, pattern = "\\.rds$"), 4)
  set.seed(2)
  expect_identical(other_seed, target_data$generate(50L))
  set.seed(1)
  expect_identical(other_drift, generation_cache_target_data(treatment_drift = 0.2)$generate(50L))
})


test_that("fast generation is not stored", {
  cache_dir <- withr::local_tempdir()
  target_data <- generation_cache_target_data()

  set.seed(1)
  generate_replicates(target_data, 50L, cache_dir = cache_dir, min_seconds = Inf)

  expect_length(list.files(cache_dir), 0)
})


test_that("an unreadable stored file falls back to generating", {
  cache_dir <- withr::local_tempdir()
  target_data <- generation_cache_target_data()
  set.seed(1)
  key <- generation_cache_key(target_data, 50L)
  writeLines("not an rds file", file.path(cache_dir, paste0(key, ".rds")))

  set.seed(1)
  recovered <- generate_replicates(target_data, 50L, cache_dir = cache_dir, min_seconds = 0)

  set.seed(1)
  expect_identical(recovered, target_data$generate(50L))
})


test_that("a simulation gives the same results whether its replicates are shared or not", {
  config <- yaml::read_yaml(system.file("conf/case_studies/mepolizumab.yml", package = "BExTE"))
  source_data <- SourceData$new(config, 1)
  simulate <- function(method, parameters, cache_dir) {
    set.seed(42)
    model <- Model$new()$create(case_study_config = config, method = method,
                                method_parameters = parameters, source_data = source_data)
    target_data <- generation_cache_target_data()
    model$calibrate_for_design(target_data)
    model$simulation_for_given_treatment_effect(
      target_data = target_data, n_replicates = 60L, critical_value = 0.975,
      theta_0 = config$theta_0, confidence_level = 0.95, null_space = config$null_space,
      case_study = "mepolizumab", method = method,
      to_return = c("test_decision", "posterior_mean", "credible_interval", "posterior_parameters"),
      n_samples_quantiles_estimation = 1000,
      simulation_config = list(n_samples_mixture_approx = 1000, generation_cache_dir = cache_dir)
    )
  }
  cache_dir <- withr::local_tempdir()
  # These replicates generate faster than the storage threshold, so store them
  # regardless: what is under test is the reuse, not the threshold.
  original <- generate_replicates
  local_mocked_bindings(
    generate_replicates = function(target_data, n_replicates, cache_dir = NULL, min_seconds = 0.25) {
      original(target_data, n_replicates, cache_dir = cache_dir, min_seconds = 0)
    }
  )

  separate <- list(initial_prior = list("noninformative"))
  power_prior <- list(power_parameter = list(0.5), initial_prior = list("noninformative"))

  unshared <- simulate("conditional_power_prior", power_prior, cache_dir = NULL)
  simulate("separate", separate, cache_dir = cache_dir)
  shared <- simulate("conditional_power_prior", power_prior, cache_dir = cache_dir)

  expect_length(list.files(cache_dir, pattern = "\\.rds$"), 1)
  expect_identical(shared, unshared)
})
