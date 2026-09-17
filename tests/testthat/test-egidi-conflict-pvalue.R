## The Egidi conflict p-value is the probability that the prior predictive puts
## the statistic somewhere at least as improbable as where it landed. It must be
## taken on the density of the complete mixture: averaging the two component
## p-values is a different quantity as soon as the components have different
## centres, which in this study is the ordinary case, since the informative
## component sits at the source estimate and the weak one at theta_0.
##
## The implementation gets there by splitting the line at the turning points of
## the mixture density and then bisecting for the level crossings. Scanning for
## the crossings directly is what it replaced: when the statistic lands near a
## turning point, the region above the level can be orders of magnitude narrower
## than either component and any fixed grid steps straight over it. The first
## test below is that case.

test_that("a degenerate weight gives the single component's tail probability", {
  ## Both ends collapse the mixture to one normal, whatever the centres are.
  ## This is exact, and it is what decides the no-conflict and unresolved cases
  ## without any root-finding, so it has to hold to machine precision.
  expect_equal(
    egidi_normal_conflict_pvalue(1.3, 0, mu_p = 0.4, sigma_p = 0.5,
                                 mu_q = -2, sigma_q = 7),
    2 * pnorm(-abs(1.3 - 0.4) / 0.5),
    tolerance = 1e-14
  )
  expect_equal(
    egidi_normal_conflict_pvalue(1.3, 1, mu_p = 0.4, sigma_p = 0.5,
                                 mu_q = -2, sigma_q = 7),
    2 * pnorm(-abs(1.3 + 2) / 7),
    tolerance = 1e-14
  )
})

test_that("equal centres give the weighted sum of the component tails", {
  ## With a shared centre the mixture predictive is symmetric and decreasing in
  ## the distance from it, so the conflict set is a matching pair of tails and
  ## the p-value is exactly linear in the weight. This is the shortcut the
  ## selection rule inverts in closed form, so it must agree with the general
  ## machinery rather than merely be close to it.
  for (psi in c(0.05, 0.4, 0.95)) {
    tails <- (1 - psi) * 2 * pnorm(-0.9 / 0.5) + psi * 2 * pnorm(-0.9 / 7)
    expect_equal(
      egidi_normal_conflict_pvalue(0.9, psi, mu_p = 0, sigma_p = 0.5,
                                   mu_q = 0, sigma_q = 7),
      tails,
      tolerance = 1e-12
    )
  }
})

test_that("a statistic at a component mean is not treated as the mixture's mode", {
  ## Regression test. With mu_p = 0, sigma_p = 1, mu_q = 3, sigma_q = 5 and
  ## psi = 0.5 the mixture's maximum is at t = 0.0200, not at t = 0, so a
  ## statistic at the informative mean leaves a sliver of density above its
  ## level carrying about 0.93% of the mass. A grid over [mu_p, mu_q] steps over
  ## that sliver and reports a p-value of exactly 1 - no conflict whatsoever -
  ## when the answer is 0.9907.
  pvalue <- egidi_normal_conflict_pvalue(0, 0.5, mu_p = 0, sigma_p = 1,
                                         mu_q = 3, sigma_q = 5)
  expect_lt(pvalue, 1)
  expect_equal(
    pvalue,
    egidi_reference_conflict_pvalue(0, 0.5, 0, 1, 3, 5),
    tolerance = 1e-4
  )
})

test_that("well separated components do not hide their turning points", {
  ## Regression test. At mu = -2 and 2 with sd 0.05 each component underflows to
  ## exactly zero at the other's mean, so a derivative formed by subtraction is
  ## zero across the whole valley and no turning point is visible. The sign of
  ## the derivative is therefore decided by comparing logarithms instead. Before
  ## that, the region above the level was found around one mode only and the
  ## p-value came back as the other component's weight.
  pvalue <- egidi_normal_conflict_pvalue(1.25, 0.85, mu_p = -2, sigma_p = 0.05,
                                         mu_q = 2, sigma_q = 0.05)
  expect_lt(pvalue, 1e-3)
  expect_equal(
    pvalue,
    egidi_reference_conflict_pvalue(1.25, 0.85, -2, 0.05, 2, 0.05),
    tolerance = 1e-6
  )
})

test_that("the deterministic p-value matches dense numerical integration", {
  ## The reference has no root-finding in it at all: it evaluates the indicator
  ## on a dense grid and sums. Its own error is a step-function boundary term of
  ## order the grid spacing, which is what sets the tolerance here.
  settings <- list(
    list(t = 0.5, psi = 0.15, mu_p = 0, sigma_p = 1, mu_q = 0, sigma_q = 10),
    list(t = 2.5, psi = 0.50, mu_p = 0, sigma_p = 1, mu_q = 3, sigma_q = 5),
    list(t = -1.2, psi = 0.85, mu_p = 0, sigma_p = 1, mu_q = 2, sigma_q = 1.2),
    list(t = 0.08, psi = 0.30, mu_p = 0, sigma_p = 0.0355, mu_q = 0, sigma_q = 0.35),
    list(t = -0.75, psi = 0.20, mu_p = 0.481, sigma_p = 0.441, mu_q = 0, sigma_q = 2.909)
  )
  for (setting in settings) {
    expect_equal(
      egidi_normal_conflict_pvalue(setting$t, setting$psi, setting$mu_p,
                                   setting$sigma_p, setting$mu_q, setting$sigma_q),
      egidi_reference_conflict_pvalue(setting$t, setting$psi, setting$mu_p,
                                      setting$sigma_p, setting$mu_q, setting$sigma_q),
      tolerance = 1e-4,
      info = paste("t =", setting$t, "psi =", setting$psi)
    )
  }
})

test_that("the deterministic p-value matches a high-precision simulation", {
  ## The simulation fallback of section 8, used here as a second reference that
  ## shares none of the deterministic route's machinery. Two million draws put
  ## the Monte Carlo standard error near 3e-4, and the bound is several times
  ## that so it fails on a systematic difference rather than an unlucky seed.
  settings <- list(
    list(t = 0.4, psi = 0.2, mu_p = 0, sigma_p = 1, mu_q = 3, sigma_q = 5),
    list(t = 2.0, psi = 0.6, mu_p = 0, sigma_p = 1, mu_q = 2, sigma_q = 1.2),
    list(t = 1.363, psi = 0.5, mu_p = 0.481, sigma_p = 0.441, mu_q = 0, sigma_q = 2.909)
  )
  for (setting in settings) {
    reference <- egidi_reference_monte_carlo(
      setting$t, setting$psi, setting$mu_p, setting$sigma_p,
      setting$mu_q, setting$sigma_q
    )
    expect_equal(
      egidi_normal_conflict_pvalue(setting$t, setting$psi, setting$mu_p,
                                   setting$sigma_p, setting$mu_q, setting$sigma_q),
      reference$pvalue,
      tolerance = 5 * reference$standard_error,
      info = paste("t =", setting$t, "psi =", setting$psi)
    )
  }
})

test_that("the p-value does not depend on which replicates share a call", {
  ## The nodes that bracket the turning points are shared by every replicate in
  ## a call, so their number is decided by the most demanding row. A batch must
  ## still give each row exactly what it would have got alone, or a scenario's
  ## results would depend on how the replicates were grouped.
  set.seed(3)
  n <- 120
  mu_p <- rnorm(n)
  mu_q <- rnorm(n)
  sigma_p <- exp(rnorm(n, 0, 1.5))
  sigma_q <- exp(rnorm(n, 0, 1.5))
  psi <- runif(n, 0.001, 0.999)
  t_obs <- ifelse(runif(n) < 0.5, rnorm(n, mu_p, sigma_p), rnorm(n, mu_q, sigma_q))
  t_obs[1:20] <- mu_p[1:20]

  batched <- egidi_normal_conflict_pvalue(t_obs, psi, mu_p, sigma_p, mu_q, sigma_q)
  individually <- vapply(seq_len(n), function(i) {
    egidi_normal_conflict_pvalue(t_obs[i], psi[i], mu_p[i], sigma_p[i],
                                 mu_q[i], sigma_q[i])
  }, numeric(1))

  expect_equal(batched, individually, tolerance = 1e-12)
  expect_true(all(batched >= 0 & batched <= 1))
})
