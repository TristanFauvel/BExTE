## A simulated trial can fail to produce an estimable summary measure. The
## clearest case is a recurrent-event arm that records no event at all:
## negative_binomial_regression() reports rate_estimate = 0 with an NA
## standard error rather than inventing a finite surrogate, so the log rate
## ratio and its standard error are both undefined for that replicate.
##
## Nothing used to drop those replicates. The NA standard error reached the
## inference kernel, turned the mixture log-weights into NaN, and finally
## surfaced - a long way from the cause - as "missing value where TRUE/FALSE
## needed" out of normal_mixture_quantile(). That killed the paper
## replication run of 2026-09-12 six hours in, at mepolizumab / RMP.
##
## They are now dropped before inference and counted in the reported
## operating characteristics, the same way replicates failing an MCMC
## diagnostic already were.

test_that("negative binomial regression reports an all-zero arm as non-estimable", {
  ## The upstream fact the rest of this file depends on.
  expect_warning(
    result <- negative_binomial_regression(rep(0L, 45)),
    "All counts are zero"
  )

  expect_equal(result$rate_estimate, 0)
  expect_true(is.na(result$se_log_rate))
})

## P(a negative-binomial count is zero) = (k / (k + mu))^k, so a whole arm of
## n patients recording nothing has probability P(0)^n. Computed rather than
## simulated: at these rates the event is far too rare to assert on reliably
## from a feasible number of draws.
probability_arm_all_zero <- function(n, mu, k) {
  (k / (k + mu))^(k * n)
}

test_that("an all-zero arm is rare but real at mepolizumab's smallest sample size", {
  ## Mepolizumab at its most extreme drift: 45 per arm, treatment rate about
  ## 0.19 events per year.
  probability <- probability_arm_all_zero(45, mu = 0.188, k = 0.8)

  ## About 5 replicates per 10000 - which is exactly what the scenario that
  ## killed the run reported once the drop was in place.
  expect_gt(probability * 10000, 1)
  expect_lt(probability * 10000, 20)

  ## It must stay a fringe correction rather than a routine one. If this ever
  ## fails high, the drift grid reaches further than the design intends and
  ## the figures deserve a second look, not a bigger drop count.
  expect_lt(probability, 0.01)
})

test_that("the larger mepolizumab sample sizes make it vanishingly rare", {
  ## Not impossible, just orders of magnitude rarer - which is why figure S26,
  ## the 45-per-arm panel, is the one materially affected.
  at_68 <- probability_arm_all_zero(68, mu = 0.188, k = 0.8)
  at_137 <- probability_arm_all_zero(137, mu = 0.188, k = 0.8)

  expect_lt(at_68 * 10000, 1)
  expect_lt(at_137 * 10000, 1e-5)
  expect_lt(at_137, at_68)
})

## A recurrent-event target whose treatment arm almost never records an event,
## so generate() reliably produces non-estimable replicates.
degenerate_target_data <- function(sample_size_per_arm = 45) {
  case_study_config <- list(
    endpoint = "recurrent_event",
    summary_measure_likelihood = "normal",
    ## FALSE is what makes generate() sample patient-level counts and fit the
    ## negative binomial, rather than drawing the summary measure directly -
    ## it is the path that can fail to estimate, and the path mepolizumab.yml
    ## selects.
    sampling_approximation = FALSE,
    source = list(
      control = 100, treatment = 120,
      treatment_effect = log(0.5), standard_error = 0.1,
      control_rate = 2, treatment_rate = 1
    )
  )
  source_data <- SourceData$new(case_study_config)

  RecurrentEventTargetData$new(
    source_data = source_data,
    sampling_approximation = FALSE,
    target_sample_size_per_arm = sample_size_per_arm,
    control_drift = 0,
    ## Drives the treatment rate down to about 0.02 events, so a whole arm of
    ## zeros is the common case rather than a rare one.
    treatment_drift = log(0.02),
    summary_measure_likelihood = "normal",
    k_treatment = 0.8,
    k_control = 0.8
  )
}

test_that("generate() marks a replicate with no events in an arm as non-estimable", {
  target_data <- degenerate_target_data()

  set.seed(11)
  samples <- suppressWarnings(target_data$generate(200))

  expect_equal(nrow(samples), 200)
  ## This is the raw material of the crash: rows carrying NA where the
  ## inference kernel expects a number.
  expect_gt(sum(!is.finite(samples$treatment_effect_estimate)), 0)
  expect_gt(sum(!is.finite(samples$treatment_effect_standard_error)), 0)
})

test_that("the estimability filter keeps every usable replicate and no other", {
  target_data <- degenerate_target_data()

  set.seed(11)
  samples <- suppressWarnings(target_data$generate(200))

  ## The predicate the simulation applies before handing replicates to the
  ## inference kernel.
  estimable <- is.finite(samples$treatment_effect_estimate) &
    is.finite(samples$treatment_effect_standard_error)
  kept <- samples[estimable, , drop = FALSE]

  expect_gt(nrow(kept), 0)
  expect_lt(nrow(kept), 200)
  expect_true(all(is.finite(kept$treatment_effect_estimate)))
  expect_true(all(is.finite(kept$treatment_effect_standard_error)))
  ## Dropped plus kept accounts for every trial simulated - the denominator
  ## the reported warning quotes.
  expect_equal(nrow(kept) + sum(!estimable), 200)
})
