# Test for the hellinger_distance function
test_that("hellinger_distance computes the correct Hellinger distance", {
  expect_equal(hellinger_distance(0, 1, 0, 1), 0)
  expect_equal(hellinger_distance(0, 1, 1, 1), 0.343, tolerance = 1e-3)
  expect_equal(hellinger_distance(0, 1, 0, 2), 0.325, tolerance = 1e-3)
})

# Test for the compute_drift_range function
test_that("compute_drift_range computes the correct drift range", {
  simulation_config <- list(ndrift = 10)
  case_study_config <- list(
    theta_0 = 0,
    source = list(treatment_effect = 1, standard_error = 0.5),
    target = list(treatment_effect = 2, standard_error = 1),
    summary_measure_likelihood = "normal"
  )

  # Symmetric about zero, bounded by the drift at which the Hellinger distance
  # between source and target reaches 0.9.
  expected_drift_range <- seq(-2.78, 2.78, length.out = 10)

  expect_equal(
    compute_drift_range(simulation_config, case_study_config),
    expected_drift_range,
    tolerance = 1e-2
  )
})

# The null drift lies above zero when the null hypothesis is on the right, and
# the range must still reach it.
test_that("compute_drift_range covers the null drift on either side of zero", {
  simulation_config <- list(ndrift = 30)
  case_study_config <- list(
    theta_0 = 0,
    source = list(treatment_effect = -0.393, standard_error = 0.081),
    target = list(standard_error = 0.2668287130568081),
    summary_measure_likelihood = "normal"
  )

  drift_range <- compute_drift_range(simulation_config, case_study_config)

  expect_equal(range(drift_range), c(-0.652, 0.652), tolerance = 1e-3)
  expect_gte(max(drift_range), 0.393)

  # A null farther out than the Hellinger bound widens only that side.
  case_study_config$source$treatment_effect <- -2
  drift_range <- compute_drift_range(simulation_config, case_study_config)
  expect_equal(max(drift_range), 2)
  expect_lt(min(drift_range), 0)
  expect_lt(abs(min(drift_range)), 2)
})
