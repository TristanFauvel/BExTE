## The KL calibration chooses the Beta prior on the discounting parameter from
## the design rather than from the configuration grid, by minimising a criterion
## over two hypothetical target estimates. Two things make that delicate. The
## criterion integrates log densities against a Beta measure whose shape
## parameters reach 0.05, so both endpoints are singular and the quadrature has
## to absorb them exactly rather than sample through them; and the objective is
## not convex, so the answer depends on where the search starts. These tests pin
## the quadrature against the moments it must reproduce, and the search against
## the properties the criterion is supposed to give it.

npp_kl_fixture <- function(se_target_expected = 0.284) {
  ## Belimumab's source study, the same numbers the other power prior tests use.
  list(
    theta_source = 0.481,
    se_source = 0.1208,
    se_target_expected = se_target_expected,
    theta_null = 0,
    benefit_sign = 1
  )
}

npp_kl_calibrate <- function(fixture, ...) {
  do.call(calibrate_npp_kl, c(fixture, list(...)))
}

expected_gamma <- function(x, fixture, alpha_gamma, beta_gamma, n_nodes = 200L) {
  rule <- npp_kl_beta_quadrature(alpha_gamma, beta_gamma, n_nodes)
  posterior <- npp_kl_posterior_masses(
    x = x,
    theta_source = fixture$theta_source,
    se_source = fixture$se_source,
    se_target_expected = fixture$se_target_expected,
    alpha_gamma = alpha_gamma,
    beta_gamma = beta_gamma,
    rule = rule
  )
  sum(posterior$masses * posterior$nodes)
}

test_that("the Beta quadrature reproduces the measure it discretises", {
  ## The weights are the Beta measure itself, so they sum to one and their first
  ## moment is the Beta mean. Both are exact for Gauss-Jacobi, whatever the
  ## shapes, which is the property that lets the endpoint singularities be
  ## ignored. The shapes below include both bounds of the configured range and
  ## the sub-one shapes that make the density unbounded.
  shapes <- list(
    c(1, 1), c(0.05, 0.05), c(2, 0.5), c(0.5, 2),
    c(100, 100), c(0.05, 100), c(100, 0.05), c(3.4, 0.77)
  )

  for (shape in shapes) {
    rule <- npp_kl_beta_quadrature(shape[1], shape[2], 80L)
    weights <- exp(rule$log_weights)
    label <- paste(shape, collapse = ", ")

    expect_equal(sum(weights), 1, info = label)
    expect_equal(sum(weights * rule$nodes), shape[1] / sum(shape), info = label)
    expect_true(all(rule$nodes > 0 & rule$nodes < 1), info = label)
  }
})

test_that("each hypothetical posterior of the discounting parameter is normalised", {
  fixture <- npp_kl_fixture()
  rule <- npp_kl_beta_quadrature(1, 1, 80L)

  for (x in c(fixture$theta_source, fixture$theta_source - 0.481, 0, 1)) {
    posterior <- npp_kl_posterior_masses(
      x = x,
      theta_source = fixture$theta_source,
      se_source = fixture$se_source,
      se_target_expected = fixture$se_target_expected,
      alpha_gamma = 1,
      beta_gamma = 1,
      rule = rule
    )

    expect_equal(sum(posterior$masses), 1, info = format(x))
    expect_true(all(is.finite(posterior$log_density)), info = format(x))
  }
})

test_that("the calibrated shape parameters are finite, positive and within bounds", {
  npp_kl_calibration_cache_reset()
  calibration <- npp_kl_calibrate(npp_kl_fixture())

  expect_true(is.finite(calibration$alpha_gamma))
  expect_true(is.finite(calibration$beta_gamma))
  expect_gt(calibration$alpha_gamma, 0)
  expect_gt(calibration$beta_gamma, 0)
  expect_gte(calibration$alpha_gamma, NPP_KL_DEFAULT_BOUNDS[1])
  expect_lte(calibration$alpha_gamma, NPP_KL_DEFAULT_BOUNDS[2])
  expect_gte(calibration$beta_gamma, NPP_KL_DEFAULT_BOUNDS[1])
  expect_lte(calibration$beta_gamma, NPP_KL_DEFAULT_BOUNDS[2])
  expect_true(calibration$optimizer_converged)
})

test_that("the calibration is deterministic", {
  ## No random number is drawn anywhere in the search, so two calibrations of
  ## the same design agree exactly rather than to a tolerance. The cache is
  ## emptied between them so that the second is a fresh solve, not a lookup.
  fixture <- npp_kl_fixture()

  npp_kl_calibration_cache_reset()
  first <- npp_kl_calibrate(fixture)
  npp_kl_calibration_cache_reset()
  second <- npp_kl_calibrate(fixture)

  expect_identical(first$alpha_gamma, second$alpha_gamma)
  expect_identical(first$beta_gamma, second$beta_gamma)
  expect_identical(first$objective_value, second$objective_value)
  expect_identical(first$calibration_id, second$calibration_id)
})

test_that("the calibrated objective is no worse than the uniform prior's", {
  ## Beta(1, 1) is one of the starting values and L-BFGS-B never returns a point
  ## worse than the one it started from, so this cannot fail without the search
  ## having rejected its own answer.
  fixture <- npp_kl_fixture()
  npp_kl_calibration_cache_reset()
  calibration <- npp_kl_calibrate(fixture)

  uniform_objective <- npp_kl_objective(
    eta = c(0, 0),
    theta_target_compatible = calibration$theta_target_compatible,
    theta_target_mtd = calibration$theta_target_mtd,
    theta_source = fixture$theta_source,
    se_source = fixture$se_source,
    se_target_expected = fixture$se_target_expected,
    lambda_kl = calibration$lambda_kl,
    c_target = calibration$c_target
  )

  expect_lte(calibration$objective_value, uniform_objective + 1e-8)
})

test_that("the calibrated prior borrows more under compatibility than at the MTD", {
  fixture <- npp_kl_fixture()
  npp_kl_calibration_cache_reset()
  calibration <- npp_kl_calibrate(fixture)

  compatible <- expected_gamma(
    calibration$theta_target_compatible, fixture,
    calibration$alpha_gamma, calibration$beta_gamma
  )
  at_mtd <- expected_gamma(
    calibration$theta_target_mtd, fixture,
    calibration$alpha_gamma, calibration$beta_gamma
  )

  expect_gt(compatible, at_mtd)
})

test_that("only the compatible term leaves the criterion at its own reference", {
  ## With all the weight on compatibility the criterion is minimised by making
  ## the posterior of the discounting parameter equal Beta(c, 1). The source
  ## estimate is precise relative to the target here, so the likelihood barely
  ## moves the prior and the answer is Beta(c, 1) itself. This is the strongest
  ## available check that the divergence is computed in the direction written
  ## down, and against the reference intended.
  fixture <- npp_kl_fixture()
  npp_kl_calibration_cache_reset()
  calibration <- npp_kl_calibrate(fixture, lambda_kl = 1, c_target = 10)

  ## Not exact: the hypothetical likelihood still tilts the posterior slightly,
  ## so the prior that makes the posterior Beta(10, 1) is a little away from it.
  expect_equal(calibration$alpha_gamma, 10, tolerance = 0.05)
  expect_equal(calibration$beta_gamma, 1, tolerance = 0.05)
})

test_that("changing the expected target standard error is a new calibration", {
  npp_kl_calibration_cache_reset()

  precise <- npp_kl_calibrate(npp_kl_fixture(se_target_expected = 0.1))
  imprecise <- npp_kl_calibrate(npp_kl_fixture(se_target_expected = 0.5))

  expect_false(identical(precise$calibration_id, imprecise$calibration_id))
  expect_false(isTRUE(all.equal(precise$alpha_gamma, imprecise$alpha_gamma)))
  expect_equal(npp_kl_calibration_cache_size(), 2)

  ## A less precise target cannot tell the two hypothetical scenarios apart, so
  ## neither KL term can be satisfied and the criterion settles on a compromise
  ## nearer the middle of the unit interval.
  precise_mean <- npp_kl_beta_moments(precise$alpha_gamma, precise$beta_gamma)$mean
  imprecise_mean <- npp_kl_beta_moments(imprecise$alpha_gamma, imprecise$beta_gamma)$mean
  expect_lt(abs(imprecise_mean - 0.5), abs(precise_mean - 0.5))
})

test_that("a design already calibrated is reused rather than solved again", {
  npp_kl_calibration_cache_reset()
  expect_equal(npp_kl_calibration_cache_size(), 0)

  first <- npp_kl_calibrate(npp_kl_fixture())
  expect_equal(npp_kl_calibration_cache_size(), 1)

  second <- npp_kl_calibrate(npp_kl_fixture())
  expect_equal(npp_kl_calibration_cache_size(), 1)
  expect_identical(first, second)
})

test_that("an explicit maximum tolerable discrepancy overrides the rule", {
  npp_kl_calibration_cache_reset()
  fixture <- npp_kl_fixture()

  by_rule <- npp_kl_calibrate(fixture)
  expect_equal(by_rule$d_mtd, abs(fixture$theta_source - fixture$theta_null))

  halved <- npp_kl_calibrate(fixture, d_mtd_multiplier = 0.5)
  expect_equal(halved$d_mtd, 0.5 * abs(fixture$theta_source - fixture$theta_null))

  explicit <- npp_kl_calibrate(fixture, d_mtd = 0.2, d_mtd_multiplier = 0.5)
  expect_equal(explicit$d_mtd, 0.2)
  expect_equal(explicit$theta_target_mtd, fixture$theta_source - 0.2)
})

test_that("the benefit direction places the MTD on the side of the null", {
  npp_kl_calibration_cache_reset()

  larger_is_better <- calibrate_npp_kl(
    theta_source = 0.481, se_source = 0.1208, se_target_expected = 0.284,
    theta_null = 0, benefit_sign = benefit_sign_from_null_space("left")
  )
  smaller_is_better <- calibrate_npp_kl(
    theta_source = -0.4155, se_source = 0.081, se_target_expected = 0.2668,
    theta_null = 0, benefit_sign = benefit_sign_from_null_space("right")
  )

  ## Both MTD points sit at the null boundary: that is what the default rule
  ## means. Getting the sign wrong would put them at 2 * theta_source instead.
  expect_equal(larger_is_better$theta_target_mtd, 0)
  expect_equal(smaller_is_better$theta_target_mtd, 0)

  expect_equal(benefit_sign_from_null_space("left"), 1)
  expect_equal(benefit_sign_from_null_space("right"), -1)
  expect_error(benefit_sign_from_null_space("neither"), "null_space")
})

test_that("an input that makes the criterion undefined is named in the error", {
  fixture <- npp_kl_fixture()

  expect_error(npp_kl_calibrate(fixture, se_source = 0), "se_source")
  expect_error(
    modifyList(fixture, list(se_source = -1)) |>
      (\(f) do.call(calibrate_npp_kl, f))(),
    "se_source"
  )
  expect_error(npp_kl_calibrate(fixture, se_target_expected = 0),
               "se_target_expected")
  expect_error(npp_kl_calibrate(fixture, d_mtd = 0), "d_mtd")
  expect_error(npp_kl_calibrate(fixture, d_mtd = -0.5), "d_mtd")
  expect_error(npp_kl_calibrate(fixture, c_target = 1), "c_target")
  expect_error(npp_kl_calibrate(fixture, c_target = 0.5), "c_target")
  expect_error(npp_kl_calibrate(fixture, lambda_kl = -0.1), "lambda_kl")
  expect_error(npp_kl_calibrate(fixture, lambda_kl = 1.5), "lambda_kl")
  expect_error(npp_kl_calibrate(fixture, d_mtd_multiplier = 0), "d_mtd_multiplier")
  expect_error(
    calibrate_npp_kl(
      theta_source = 0.481, se_source = 0.1208, se_target_expected = 0.284,
      theta_null = 0, benefit_sign = 0
    ),
    "benefit_sign"
  )
  expect_error(
    npp_kl_calibrate(fixture, beta_parameter_bounds = c(2, 1)),
    "beta_parameter_bounds"
  )
})

test_that("a starting value the optimiser cannot use is passed over", {
  ## The search keeps the best converged answer, so one broken start must not
  ## decide the outcome. The first start is made to fail here; the remaining
  ## four still have to produce the same answer as an unbroken search.
  fixture <- npp_kl_fixture()

  npp_kl_calibration_cache_reset()
  unbroken <- npp_kl_calibrate(fixture)

  ## Held before the binding is replaced, so that the stand-in can defer to the
  ## real search for the starts it is not breaking without calling itself.
  real_optimise_from <- npp_kl_optimise_from

  calls <- 0
  failing_first <- function(start, objective, beta_parameter_bounds) {
    calls <<- calls + 1
    if (calls == 1) {
      stop("the optimiser could not evaluate this start")
    }
    real_optimise_from(start, objective, beta_parameter_bounds)
  }

  npp_kl_calibration_cache_reset()
  recovered <- testthat::with_mocked_bindings(
    npp_kl_calibrate(fixture),
    npp_kl_optimise_from = failing_first,
    .package = "BExTE"
  )

  expect_true(recovered$optimizer_converged)
  expect_equal(recovered$alpha_gamma, unbroken$alpha_gamma)
  expect_equal(recovered$beta_gamma, unbroken$beta_gamma)
})

test_that("a calibration that fails from every start is an error, not a guess", {
  fixture <- npp_kl_fixture()

  npp_kl_calibration_cache_reset()
  expect_error(
    testthat::with_mocked_bindings(
      npp_kl_calibrate(fixture),
      npp_kl_optimise_from = function(start, objective, beta_parameter_bounds) {
        list(
          alpha_gamma = NA_real_, beta_gamma = NA_real_,
          objective_value = Inf, converged = FALSE,
          message = "deliberately broken"
        )
      },
      .package = "BExTE"
    ),
    "failed from every one of the 5 starting values"
  )
})
