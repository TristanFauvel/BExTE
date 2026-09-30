# The vectorised root finder, the row sort and the ELIR shortcuts behind the
# Egidi mixture and the robust mixture prior's fast paths.

test_that("sorting rows matches a per-row sort, missing values last", {
  m <- matrix(c(3, 1, NA, 2,
                5, NA, 4, 0,
                NA, NA, NA, NA,
                -1, -1, 7, 2), nrow = 4, byrow = TRUE)

  expect_identical(sort_rows(m), t(apply(m, 1, sort, na.last = TRUE)))
})


test_that("the bracketed root finder solves every row to tolerance", {
  targets <- c(0.2, 2, -5)
  f <- function(x, i) x^3 - targets[i]
  found <- vectorised_bracketed_root(
    f, lower = rep(-3, 3), upper = rep(3, 3),
    f_lower = f(-3, 1:3), f_upper = f(3, 1:3)
  )

  expect_equal(found$root, sign(targets) * abs(targets)^(1 / 3), tolerance = 1e-12)
  # The ends keep opposite signs, so the root is never lost.
  expect_true(all(found$f_lower <= 0 & found$f_upper >= 0))
})


test_that("an infinite end is handled by bisecting until it is replaced", {
  f <- function(x, i) -log(x) - 1
  found <- vectorised_bracketed_root(
    f, lower = 0, upper = 5, f_lower = Inf, f_upper = f(5, 1)
  )

  expect_equal(found$root, exp(-1), tolerance = 1e-12)
})


test_that("a root at an end of the bracket is returned exactly", {
  f <- function(x, i) x - 1
  at_upper <- vectorised_bracketed_root(f, 0, 1, f_lower = -1, f_upper = 0)
  at_lower <- vectorised_bracketed_root(f, 1, 2, f_lower = 0, f_upper = 1)

  expect_identical(c(at_upper$lower, at_upper$upper), c(1, 1))
  expect_identical(c(at_lower$lower, at_lower$upper), c(1, 1))
})


test_that("rows reduced to one component get the closed-form ELIR", {
  n <- 200
  weights <- cbind(rep(c(1, 0.4), each = n / 2), rep(c(0, 0.6), each = n / 2))
  means <- cbind(rep(0.5, n), rep(0, n))
  sds <- cbind(rep(0.15, n), seq(2, 4, length.out = n))
  sigma <- seq(1, 2, length.out = n)

  ess <- normal_mixture_elir_ess(weights, means, sds, sigma)

  single <- seq_len(n / 2)
  expect_equal(ess[single], sigma[single]^2 / 0.15^2, tolerance = 1e-14)
  expect_equal(ess, normal_mixture_elir_quadrature(weights, means, sds, sigma),
               tolerance = 1e-12)
})


test_that("a prior varying through one standard deviation is interpolated", {
  withr::local_seed(3)
  n <- 3000
  vague_sd <- exp(stats::runif(n, log(0.5), log(8)))
  weights <- cbind(rep(0.3, n), rep(0.7, n))
  means <- cbind(rep(0.4, n), rep(0, n))
  sds <- cbind(rep(0.12, n), vague_sd)
  sigma <- stats::runif(n, 1, 2)

  expect_equal(
    normal_mixture_elir_ess(weights, means, sds, sigma),
    normal_mixture_elir_quadrature(weights, means, sds, sigma),
    tolerance = 1e-9
  )

  # Few distinct values are integrated directly rather than interpolated.
  sds[, 2] <- rep(c(1, 2, 3), length.out = n)
  expect_equal(
    normal_mixture_elir_ess(weights, means, sds, sigma),
    normal_mixture_elir_quadrature(weights, means, sds, sigma),
    tolerance = 1e-14
  )
})


test_that("interpolation adds nodes until it reaches its tolerance", {
  evaluations <- 0
  f <- function(x) {
    evaluations <<- evaluations + length(x)
    1 / (1 + 25 * log(x)^2)
  }
  x <- exp(seq(-1, 1, length.out = 5000))

  expect_equal(interpolate_smooth_function(f, x), 1 / (1 + 25 * log(x)^2),
               tolerance = 1e-9)
  # A Runge function needs more than the 33 starting nodes, but far fewer
  # evaluations than points.
  expect_gt(evaluations, 66)
  expect_lt(evaluations, 1000)
})


test_that("the conflict p-value finds every turning point without a grid", {
  ## Random two-component predictives, including well separated and very
  ## unequal ones, where the density has one mode or two. The turning points
  ## are bracketed in closed form, so none can be missed however narrow the
  ## components; the dense reference shares none of that machinery. Its own
  ## step-function error reaches 2e-5 on these scales - one case agrees with it
  ## to 4e-7 only at ten times the nodes - so, as in the dense test of
  ## test-egidi-conflict-pvalue.R, a missed turning point, which moves the
  ## p-value by a component's whole mass, is what the bound is set to catch.
  withr::local_seed(11)
  for (case in 1:25) {
    mu_p <- stats::rnorm(1)
    mu_q <- mu_p + stats::runif(1, 0.2, 6)
    sigma_p <- exp(stats::runif(1, log(0.05), log(1)))
    sigma_q <- exp(stats::runif(1, log(0.05), log(3)))
    psi <- stats::runif(1, 0.05, 0.95)
    t_obs <- stats::runif(1, mu_p - 1, mu_q + 1)
    expect_equal(
      egidi_normal_conflict_pvalue(t_obs, psi, mu_p, sigma_p, mu_q, sigma_q),
      egidi_reference_conflict_pvalue(t_obs, psi, mu_p, sigma_p, mu_q, sigma_q),
      tolerance = 1e-4,
      info = paste("case", case)
    )
  }
})
