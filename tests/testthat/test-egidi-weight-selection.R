## The selection rule is
##   psi_hat = inf{psi in [0, 1] : P_psi(t_obs) >= alpha_PC},
## evaluated separately for every replicate from that replicate's own target
## estimate and standard error, and never from the true drift.
##
## The tests below are the validation cases the method is specified by: the two
## ends, the closed form in between when the components share a centre, and the
## threshold itself. The last two check the things that make the search correct -
## that it looks for the *smallest* crossing, and that the coarse stage it uses
## to find it agrees with a full scan at the reported resolution.

test_that("a statistic at a shared prior centre selects no weak component", {
  ## Both p-values are 1 there, so there is nothing to resolve.
  selection <- egidi_select_weak_weight(
    t_obs = 0, s_target = 0.1, mu_p = 0, tau_p = 0.2, mu_q = 0, tau_q = 2
  )
  expect_equal(selection$pvalue_informative, 1)
  expect_equal(selection$pvalue_weak, 1)
  expect_equal(selection$psi_weak, 0)
  expect_false(selection$initial_conflict)
  expect_false(selection$conflict_unresolved)
})

test_that("no conflict selects no weak component", {
  ## P_p >= alpha_PC means the informative prior already predicts the statistic
  ## well enough, so the rule takes the infimum at zero without searching.
  selection <- egidi_select_weak_weight(
    t_obs = 0.1, s_target = 0.1, mu_p = 0.05, tau_p = 0.2, mu_q = 0, tau_q = 2
  )
  expect_gte(selection$pvalue_informative, 0.05)
  expect_equal(selection$psi_weak, 0)
  expect_false(selection$initial_conflict)
  expect_equal(selection$pvalue_selected, selection$pvalue_informative)
})

test_that("common centres select the analytic weight", {
  ## The mixture predictive is symmetric, so P_psi = (1 - psi) P_p + psi P_q and
  ## the crossing is (alpha - P_p) / (P_q - P_p) exactly.
  alpha_pc <- 0.05
  s_target <- 0.1
  tau_p <- 0.05
  tau_q <- 1.5
  t_obs <- 0.35

  selection <- egidi_select_weak_weight(
    t_obs = t_obs, s_target = s_target, mu_p = 0, tau_p = tau_p,
    mu_q = 0, tau_q = tau_q, alpha_pc = alpha_pc
  )
  informative <- 2 * pnorm(-abs(t_obs) / sqrt(s_target^2 + tau_p^2))
  weak <- 2 * pnorm(-abs(t_obs) / sqrt(s_target^2 + tau_q^2))

  expect_lt(informative, alpha_pc)
  expect_gte(weak, alpha_pc)
  expect_equal(
    selection$psi_weak,
    (alpha_pc - informative) / (weak - informative),
    tolerance = 1e-12
  )
})

test_that("the selected weight is the smallest admissible one", {
  ## Section 5's threshold check, on the unequal centres this study actually
  ## runs: the criterion has to hold at the selected weight and fail just below
  ## it, or the value returned is not an infimum.
  alpha_pc <- 0.05
  s_target <- 0.42
  tau_p <- 0.12
  tau_q <- sqrt(s_target^2 * 92)
  t_obs <- -0.75
  mu_p <- 0.481

  selection <- egidi_select_weak_weight(
    t_obs = t_obs, s_target = s_target, mu_p = mu_p, tau_p = tau_p,
    mu_q = 0, tau_q = tau_q, alpha_pc = alpha_pc, weight_grid_step = 0.001
  )
  sigma_p <- sqrt(s_target^2 + tau_p^2)
  sigma_q <- sqrt(s_target^2 + tau_q^2)
  at <- function(psi) {
    egidi_normal_conflict_pvalue(t_obs, psi, mu_p, sigma_p, 0, sigma_q)
  }

  expect_gt(selection$psi_weak, 0)
  expect_lt(selection$psi_weak, 1)
  expect_gte(at(selection$psi_weak), alpha_pc - 1e-9)
  expect_lt(at(selection$psi_weak - 0.001), alpha_pc)
  expect_equal(selection$pvalue_selected, at(selection$psi_weak), tolerance = 1e-9)
})

test_that("a conflict the weak component cannot resolve is flagged", {
  ## When even full reliance on the weak component leaves the statistic
  ## improbable, the rule returns one - but saying so is the point: reporting it
  ## silently would read as a resolved conflict.
  selection <- egidi_select_weak_weight(
    t_obs = 40, s_target = 0.1, mu_p = 0, tau_p = 0.2, mu_q = 0, tau_q = 2
  )
  expect_lt(selection$pvalue_weak, 0.05)
  expect_equal(selection$psi_weak, 1)
  expect_true(selection$initial_conflict)
  expect_true(selection$conflict_unresolved)
})

test_that("the two-stage scan agrees with a full scan at the reported step", {
  ## The coarse stage exists so that a scenario of ten thousand replicates does
  ## not evaluate a thousand candidate weights each. It is only legitimate if it
  ## finds the same crossing the full scan does, which it does unless one both
  ## starts and ends inside a single coarse step.
  set.seed(20260917)
  n <- 150
  s_target <- runif(n, 0.2, 0.6)
  t_obs <- rnorm(n, -0.5, 0.8)
  tau_p <- 0.12
  mu_p <- 0.481
  tau_q <- sqrt(s_target^2 * 92)

  selection <- egidi_select_weak_weight(
    t_obs = t_obs, s_target = s_target, mu_p = mu_p, tau_p = tau_p,
    mu_q = 0, tau_q = tau_q, alpha_pc = 0.05, weight_grid_step = 0.001
  )

  sigma_p <- sqrt(s_target^2 + tau_p^2)
  sigma_q <- sqrt(s_target^2 + tau_q^2)
  grid <- seq(0, 1, by = 0.001)
  exhaustive <- vapply(seq_len(n), function(i) {
    values <- egidi_normal_conflict_pvalue(t_obs[i], grid, mu_p, sigma_p[i],
                                           0, sigma_q[i])
    crossing <- which(values >= 0.05)[1]
    if (is.na(crossing)) 1 else grid[crossing]
  }, numeric(1))

  searched <- selection$initial_conflict & !selection$conflict_unresolved
  expect_gt(sum(searched), 20)
  ## The full scan reports the grid point; the two-stage scan refines inside the
  ## bracketing step, so they agree to within one step by construction.
  expect_lt(max(abs(selection$psi_weak[searched] - exhaustive[searched])), 0.001)
  expect_equal(selection$psi_weak[!searched], exhaustive[!searched], tolerance = 1e-12)
})

test_that("a smaller conflict threshold never selects a larger weight", {
  ## alpha_PC = 0.01 and 0.10 are the sensitivity values. A laxer threshold asks
  ## more of the prior predictive, so it can only move the infimum up.
  set.seed(11)
  n <- 80
  s_target <- runif(n, 0.2, 0.6)
  t_obs <- rnorm(n, -0.6, 0.9)
  tau_q <- sqrt(s_target^2 * 92)
  weights <- vapply(c(0.01, 0.05, 0.10), function(alpha_pc) {
    egidi_select_weak_weight(
      t_obs = t_obs, s_target = s_target, mu_p = 0.481, tau_p = 0.12,
      mu_q = 0, tau_q = tau_q, alpha_pc = alpha_pc
    )$psi_weak
  }, numeric(n))

  expect_true(all(weights[, 1] <= weights[, 2] + 1e-9))
  expect_true(all(weights[, 2] <= weights[, 3] + 1e-9))
})

test_that("a configuration the simulation cannot honour is rejected", {
  ## The simulation always computes the conflict p-value exactly, so accepting
  ## pvalue_method = "mc" from a configuration would quietly run something other
  ## than what was asked for.
  expect_error(
    egidi_fixture(method_parameters = egidi_method_parameters(pvalue_method = "mc")),
    "must be \"exact\""
  )
  ## The weak component is the RMP's, which is always the empirical Bayes one.
  parameters <- egidi_method_parameters()
  parameters$empirical_bayes <- list(FALSE)
  expect_error(egidi_fixture(method_parameters = parameters), "empirical_bayes must be TRUE")
})
