# The interval score answers a reviewer's objection that an interval's width
# means nothing without its coverage, so it is only useful if it actually
# reaches the results frame alongside `precision` and `coverage`. These tests
# pin the aggregation step: that the scenario-level value is the mean of the
# per-replicate scores, that it carries a Monte Carlo interval like every other
# aggregated metric, and that it is charged against the same truth `coverage`
# uses.

canned_results_model <- function(results) {
  R6::R6Class(
    "IntervalScoreCannedResultsTestModel",
    inherit = Model,
    public = list(
      simulation_for_given_treatment_effect = function(...) results
    )
  )$new()
}

three_replicates <- list(
  fit_success = rep("Success", 3),
  test_decisions = c(1, 1, 0),
  posterior_means = c(1, 2, 3),
  posterior_medians = c(1, 2, 3),
  # Rows: one interval that misses low, one that covers, one that misses high.
  credible_intervals = matrix(
    c(-3, -1, 1, 3, 5, 7),
    ncol = 2, byrow = TRUE
  ),
  posterior_parameters = NULL,
  ess_moments = c(10, 20, 30),
  ess_precisions = c(5, 10, 15),
  ess_elir = c(1, 2, 3),
  rhat = c(1.00, 1.01, 1.02),
  mcmc_ess = c(500, 600, 700),
  n_divergences = c(0, 1, 2)
)

run_ocs <- function(results, treatment_effect = 2) {
  canned_results_model(results)$estimate_frequentist_operating_characteristics(
    theta_0 = 0,
    target_data = list(treatment_effect = treatment_effect),
    n_replicates = length(results$fit_success),
    critical_value = 0.975,
    confidence_level = 0.95,
    null_space = "left",
    n_samples_quantiles_estimation = 100,
    case_study = "unit_test",
    method = "separate"
  )
}


test_that("the aggregate is the mean of the per-replicate interval scores", {
  result <- run_ocs(three_replicates)

  expected <- interval_score(
    three_replicates$credible_intervals[, 1],
    three_replicates$credible_intervals[, 2],
    2,
    0.95
  )

  expect_equal(result$interval_score, mean(expected))
  # Spelled out: widths of 2 throughout, missed by 3 low and by 3 high.
  expect_equal(result$interval_score, mean(c(2 + 40 * 3, 2, 2 + 40 * 3)))
})


test_that("the aggregate carries a Monte Carlo interval containing it", {
  result <- run_ocs(three_replicates)

  expect_false(is.null(result$conf_int_interval_score_lower))
  expect_false(is.null(result$conf_int_interval_score_upper))
  expect_lte(result$conf_int_interval_score_lower, result$interval_score)
  expect_gte(result$conf_int_interval_score_upper, result$interval_score)
})


test_that("it is scored against the same true effect as the coverage", {
  # Moving the truth inside every interval must make the coverage perfect and
  # drop the score to the mean width - the two metrics cannot disagree about
  # which value they are measuring against.
  covering <- three_replicates
  covering$credible_intervals <- matrix(
    c(1, 3, 0, 4, 1.5, 2.5),
    ncol = 2, byrow = TRUE
  )

  result <- run_ocs(covering, treatment_effect = 2)

  expect_equal(result$coverage, 1)
  expect_equal(result$interval_score, mean(c(2, 4, 1)))
  # With perfect coverage the score is exactly twice the reported half width.
  expect_equal(result$interval_score, 2 * result$precision)
})


test_that("a narrower but misplaced interval scores worse despite better precision", {
  # This is the ranking the reviewer asked for, at the scenario level.
  wide_and_covering <- three_replicates
  wide_and_covering$credible_intervals <- matrix(
    c(-2, 6, -2, 6, -2, 6),
    ncol = 2, byrow = TRUE
  )

  narrow_and_biased <- three_replicates
  narrow_and_biased$credible_intervals <- matrix(
    c(-0.2, 0.2, -0.2, 0.2, -0.2, 0.2),
    ncol = 2, byrow = TRUE
  )

  wide <- run_ocs(wide_and_covering)
  narrow <- run_ocs(narrow_and_biased)

  expect_lt(narrow$precision, wide$precision)
  expect_lt(narrow$coverage, wide$coverage)
  expect_gt(narrow$interval_score, wide$interval_score)
})


test_that("the printable summary reports the score next to the precision", {
  result <- run_ocs(three_replicates)
  table <- format_simulation_output_table(result)

  expect_true("Interval Score" %in% table$Metric)
  expect_equal(
    as.numeric(table$Value[table$Metric == "Interval Score"]),
    result$interval_score,
    tolerance = 1e-3
  )
})
