test_that("validate_config accepts a config matching its schema", {
  schema <- list(seed = "count", critical_value = "probability")

  expect_silent(
    validate_config(list(seed = 42, critical_value = 0.975), schema, "test_config")
  )
})


test_that("validate_config reports a missing key and names the config", {
  schema <- list(seed = "count", critical_value = "probability")

  expect_error(
    validate_config(list(seed = 42), schema, "simulation_config.yml"),
    "simulation_config.yml.*critical_value"
  )
})


test_that("validate_config reports a probability outside the unit interval", {
  schema <- list(critical_value = "probability")

  expect_error(
    validate_config(list(critical_value = 1.5), schema, "test_config"),
    "critical_value"
  )
})


test_that("validate_config reports a count that is not a positive whole number", {
  schema <- list(n_replicates = "count")

  expect_error(
    validate_config(list(n_replicates = 0), schema, "test_config"),
    "n_replicates"
  )
  expect_error(
    validate_config(list(n_replicates = 10.5), schema, "test_config"),
    "n_replicates"
  )
})


test_that("validate_config reports a flag that is not a single logical", {
  schema <- list(delete_old_results = "flag")

  expect_error(
    validate_config(list(delete_old_results = "TRUE"), schema, "test_config"),
    "delete_old_results"
  )
})


test_that("validate_config accepts YAML list-of-scalars as a numeric vector", {
  schema <- list(sample_size_factors = "numeric_vector")

  expect_silent(
    validate_config(list(sample_size_factors = list(1, 2, 4)), schema, "test_config")
  )
})


test_that("validate_config rejects a numeric vector containing a string", {
  schema <- list(sample_size_factors = "numeric_vector")

  expect_error(
    validate_config(list(sample_size_factors = list(1, "two")), schema, "test_config"),
    "sample_size_factors"
  )
})


test_that("validate_config reports every offending key at once", {
  schema <- list(seed = "count", critical_value = "probability")

  message <- tryCatch(
    validate_config(list(seed = -1, critical_value = 2), schema, "test_config"),
    error = function(e) conditionMessage(e)
  )

  expect_match(message, "seed")
  expect_match(message, "critical_value")
})


test_that("validate_config ignores keys the schema does not describe", {
  schema <- list(seed = "count")

  expect_silent(
    validate_config(list(seed = 42, undocumented_extra = "anything"), schema, "test_config")
  )
})


test_that("validate_config accepts a config omitting a key marked optional", {
  schema <- list(seed = "count", parallelization = "flag?")

  expect_silent(validate_config(list(seed = 42), schema, "test_config"))
})


test_that("validate_config still type checks an optional key that is present", {
  schema <- list(parallelization = "flag?")

  expect_error(
    validate_config(list(parallelization = "yes"), schema, "test_config"),
    "parallelization"
  )
})


test_that("validate_config accepts zero for a non-negative count", {
  schema <- list(ndrift = "nonnegative_count")

  expect_silent(validate_config(list(ndrift = 0), schema, "test_config"))
})


test_that("validate_config rejects a negative non-negative count", {
  schema <- list(ndrift = "nonnegative_count")

  expect_error(validate_config(list(ndrift = -1), schema, "test_config"), "ndrift")
})
