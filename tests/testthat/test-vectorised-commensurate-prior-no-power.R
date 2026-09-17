# The plain commensurate prior is the commensurate power prior at gamma == 1.
# Fixtures live in helper-commensurate.R; the replicate samples and the fast
# path runner are the ones test-vectorised-commensurate-prior.R defines, so
# the two methods are exercised through identical inputs.

test_that("the quadrature collapses to one component per tau node", {
  for (prior in commensurate_configured_priors()) {
    model <- commensurate_prior_fast_path_model(prior)
    mixture <- commensurate_prior_mixture(model, n_tau = 48L, n_gamma = 24L)

    # Without a power parameter there is nothing to integrate in the second
    # dimension, so n_gamma is ignored rather than multiplying the component
    # count by 24.
    expect_length(mixture$weights, 48L)
    expect_null(mixture$power_parameter)

    expect_equal(sum(mixture$weights), 1, tolerance = 1e-12)
    expect_true(all(mixture$weights > 0))
    expect_true(all(is.finite(mixture$sds)))
    expect_true(all(mixture$sds > 0))
  }
})


test_that("the mixture is the power prior's, with the power parameter at one", {
  prior <- list(family = "half_normal", std_dev = 2)
  free <- commensurate_prior_mixture(
    commensurate_prior_fast_path_model(prior),
    n_tau = 32L
  )
  rule <- commensurate_tau_quadrature(
    commensurate_prior_fast_path_model(prior),
    n_nodes = 32L
  )

  source_standard_error <- 0.12
  expect_equal(free$tau, rule$tau)
  expect_equal(free$sds, sqrt(rule$inverse_tau + source_standard_error^2))
  expect_equal(free$means, rep(0.5, 32L))

  # gamma <= 1 only ever inflates a component's variance, so every component
  # of the power prior's mixture over the same tau rule is at least as wide.
  power <- commensurate_prior_mixture(
    commensurate_fast_path_model(prior),
    n_tau = 32L,
    n_gamma = 8L
  )
  expect_true(all(power$sds >= rep(free$sds, each = 8L) - 1e-12))
})


test_that("the mixture posterior matches direct integration over tau", {
  # An independent calculation of the same posterior: adaptive integration of
  # the analytic conditional posterior against the half-normal prior on tau,
  # rather than the Gauss-Legendre rule the fast path uses.
  std_dev <- 2
  model <- commensurate_prior_fast_path_model(
    list(family = "half_normal", std_dev = std_dev)
  )
  source_mean <- 0.5
  source_standard_error <- 0.12
  estimate <- 0.9
  standard_error <- 0.1

  marginal <- function(tau) {
    prior_variance <- 1 / tau + source_standard_error^2
    extraDistr::dhnorm(tau, sigma = std_dev) *
      stats::dnorm(estimate, source_mean, sqrt(prior_variance + standard_error^2))
  }
  moment <- function(power) {
    stats::integrate(function(tau) {
      prior_variance <- 1 / tau + source_standard_error^2
      posterior_variance <- 1 / (1 / prior_variance + 1 / standard_error^2)
      posterior_mean <- posterior_variance *
        (source_mean / prior_variance + estimate / standard_error^2)
      value <- if (power == 1) {
        posterior_mean
      } else {
        posterior_variance + posterior_mean^2
      }
      marginal(tau) * value
    }, lower = 0, upper = Inf, rel.tol = 1e-10)$value
  }

  normalising <- stats::integrate(marginal, 0, Inf, rel.tol = 1e-10)$value
  expected_mean <- moment(1) / normalising
  expected_sd <- sqrt(moment(2) / normalising - expected_mean^2)

  mixture <- commensurate_prior_mixture(model, n_tau = 192L)
  posterior <- normal_mixture_posterior(
    weights = mixture$weights,
    means = mixture$means,
    sds = mixture$sds,
    estimate = estimate,
    standard_error = standard_error
  )
  summary <- normal_mixture_summary(
    posterior$weights,
    posterior$means,
    posterior$sds
  )

  expect_equal(drop(summary$mean), expected_mean, tolerance = 1e-6)
  expect_equal(drop(summary$sd), expected_sd, tolerance = 1e-6)
})


test_that("posterior summaries are converged at the default node count", {
  for (prior in commensurate_configured_priors()) {
    model <- commensurate_prior_fast_path_model(prior)

    expect_equal(
      commensurate_posterior_summary(model, 48L, 24L),
      commensurate_posterior_summary(model, 192L, 48L),
      tolerance = 5e-4
    )
  }
})


test_that("the ELIR sample size is converged at the default node count", {
  elir <- function(model, n_tau) {
    mixture <- commensurate_prior_mixture(model, n_tau)
    normal_mixture_elir_ess(
      weights = mixture$weights,
      means = mixture$means,
      sds = mixture$sds,
      sigma = 0.1 * sqrt(60)
    )
  }

  for (prior in commensurate_configured_priors()) {
    model <- commensurate_prior_fast_path_model(prior)
    expect_equal(elir(model, 48L), elir(model, 384L), tolerance = 1e-3)
  }
})


test_that("the simulation fast path returns the pipeline contract", {
  model <- commensurate_prior_fast_path_model(
    list(family = "half_normal", std_dev = 2)
  )

  result <- commensurate_fast_path_run(
    model,
    to_return = c(
      "test_decision", "posterior_mean", "posterior_median",
      "credible_interval", "posterior_parameters", "ess_moment",
      "ess_precision", "ess_elir", "fit_success", "mcmc_diagnostics"
    )
  )

  expect_length(result$posterior_means, 3)
  expect_equal(dim(result$credible_intervals), c(3L, 2L))
  expect_equal(nrow(result$posterior_parameters), 3)
  expect_equal(result$fit_success, rep("Success", 3))
  expect_true(all(is.finite(result$ess_elir)))
})


test_that("no power parameter is reported, rather than a column of ones", {
  model <- commensurate_prior_fast_path_model(
    list(family = "half_normal", std_dev = 2)
  )

  parameters <- commensurate_fast_path_run(
    model,
    to_return = "posterior_parameters"
  )$posterior_parameters

  expect_equal(
    colnames(parameters),
    c("heterogeneity_parameter_mean", "heterogeneity_parameter_std")
  )
})


test_that("heterogeneity moments that diverge are reported as infinite", {
  parameters_for <- function(prior) {
    commensurate_fast_path_run(
      commensurate_prior_fast_path_model(prior),
      to_return = "posterior_parameters"
    )$posterior_parameters
  }

  # Dropping the power parameter does not change which tau moments exist: the
  # target marginal likelihood still tends to a positive constant as tau grows.
  divergent <- list(
    list(family = "inverse_gamma", alpha = 1 / 3, beta = 1),
    list(family = "inverse_gamma", alpha = 1 / 7, beta = 1),
    list(family = "inverse_gamma", alpha = 1 / 1000, beta = 1),
    list(family = "cauchy", location = 0, scale = 10)
  )

  for (prior in divergent) {
    parameters <- parameters_for(prior)
    expect_true(all(is.infinite(parameters$heterogeneity_parameter_mean)))
    expect_true(all(is.infinite(parameters$heterogeneity_parameter_std)))
  }

  finite <- parameters_for(list(family = "half_normal", std_dev = 1))
  expect_true(all(is.finite(finite$heterogeneity_parameter_mean)))
  expect_true(all(is.finite(finite$heterogeneity_parameter_std)))
})


test_that("borrowing is bracketed by the separate and pooled analyses", {
  # tau -> 0 leaves the target data alone; tau -> Inf pools them with the
  # source. Any prior on tau has to land between the two.
  model <- commensurate_prior_fast_path_model(
    list(family = "half_normal", std_dev = 2)
  )
  estimate <- 0.9
  standard_error <- 0.1
  source_mean <- 0.5
  source_standard_error <- 0.12

  mixture <- commensurate_prior_mixture(model, n_tau = 192L)
  posterior <- normal_mixture_posterior(
    weights = mixture$weights,
    means = mixture$means,
    sds = mixture$sds,
    estimate = estimate,
    standard_error = standard_error
  )
  posterior_mean <- drop(normal_mixture_summary(
    posterior$weights,
    posterior$means,
    posterior$sds
  )$mean)

  pooled_variance <- 1 / (1 / source_standard_error^2 + 1 / standard_error^2)
  pooled_mean <- pooled_variance *
    (source_mean / source_standard_error^2 + estimate / standard_error^2)

  expect_gt(posterior_mean, pooled_mean)
  expect_lt(posterior_mean, estimate)
})
