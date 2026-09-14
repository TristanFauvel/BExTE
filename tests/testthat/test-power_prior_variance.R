## The power parameter an empirical-Bayes power prior estimates is
## exp((k / (1 - p)) * log(1 - p)). For p in a narrow band - around 0.927 to
## 0.929 when k = 20 - that underflows to a *denormal* (5e-311, say) rather
## than to 0, and source_standard_error^2 divided by a denormal overflows to
## Inf. An infinite prior variance makes the mixture component's marginal
## variance Inf, its log-weight -Inf, and the log-weight minus its own row
## maximum NaN, which finally surfaces a long way downstream as
## "missing value where TRUE/FALSE needed" from normal_mixture_quantile().
##
## That is what killed the paper replication runs of 2026-09-11 partway
## through botox / p_value_based_PP, twice, with no error reaching the log.

test_that("a power parameter of exactly zero means the vague prior", {
  ## The case the original `power_parameter != 0` guard was written for.
  expect_equal(power_prior_variance(0.1, 0), 1000)
})

test_that("an ordinary power parameter gives source variance over it", {
  expect_equal(power_prior_variance(0.1, 0.5), 0.02)
  expect_equal(power_prior_variance(0.1, 1), 0.01)

  ## Small but not small enough to overflow: left exactly as it was, so no
  ## currently-working scenario shifts.
  expect_equal(power_prior_variance(0.1, 1e-10), 1e8)
})

test_that("a denormal power parameter means the vague prior, not Inf", {
  ## The actual values from the crash: botox, shape parameter k = 20,
  ## source standard error 0.1.
  denormal <- exp((20 / (1 - 0.928)) * log(1 - 0.928))
  expect_gt(denormal, 0)
  expect_lt(denormal, 1e-300)
  expect_false(is.finite(0.1^2 / denormal))

  expect_equal(power_prior_variance(0.1, denormal), 1000)
})

test_that("the vague prior is substituted elementwise, across replicates", {
  ## The vectorised path hands in one power parameter per replicate, and in
  ## the crash only 12 replicates out of 10000 were affected - the other
  ## 9988 must keep their own variances.
  power_parameters <- c(1, 0.5, 0, exp((20 / (1 - 0.928)) * log(1 - 0.928)))

  expect_equal(
    power_prior_variance(0.1, power_parameters),
    c(0.01, 0.02, 1000, 1000)
  )
})

test_that("an NA power parameter is an error rather than a silent vague prior", {
  ## The scalar path already stopped on NA; substituting the vague prior for
  ## it would turn a genuine failure into a plausible-looking result.
  expect_error(power_prior_variance(0.1, NA_real_), "NA")
  expect_error(power_prior_variance(0.1, c(0.5, NA_real_)), "NA")
})
