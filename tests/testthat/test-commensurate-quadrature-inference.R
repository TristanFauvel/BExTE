# inference() on one target data set runs on quadrature by default, so the
# commensurate models need no CmdStan. These tests pin that path against the
# mixture it is built from and against an independent integral over tau.

quadrature_target <- function(estimate = 0.9, standard_error = 0.1) {
  list(
    sample_size_control = 60,
    sample_size_treatment = 60,
    sample = list(
      treatment_effect_estimate = estimate,
      treatment_effect_standard_error = standard_error,
      standard_deviation = standard_error * sqrt(60)
    )
  )
}

test_that("commensurate models default to quadrature and compile nothing", {
  for (model_for in list(commensurate_fast_path_model,
                         commensurate_prior_fast_path_model)) {
    model <- model_for(list(family = "half_normal", std_dev = 1))
    expect_true(model$uses_quadrature())
    expect_false(model$mcmc)

    testthat::with_mocked_bindings(
      expect_identical(model$inference(quadrature_target()), "Success"),
      compile_stan_model = function(...) stop("Stan was compiled"),
      .package = "BExTE"
    )
  }
})

test_that("quadrature inference matches the posterior mixture it is built from", {
  for (model_for in list(commensurate_fast_path_model,
                         commensurate_prior_fast_path_model)) {
    for (prior in commensurate_configured_priors()) {
      model <- model_for(prior)
      model$inference(quadrature_target())

      mixture <- commensurate_prior_mixture(model)
      posterior <- normal_mixture_posterior(
        mixture$weights, mixture$means, mixture$sds,
        estimate = 0.9, standard_error = 0.1
      )
      reference <- normal_mixture_summary(
        posterior$weights, posterior$means, posterior$sds
      )

      expect_equal(model$post_mean, reference$mean, tolerance = 1e-10)
      expect_equal(sqrt(model$post_var), reference$sd, tolerance = 1e-10)
      expect_equal(model$post_median, reference$quantiles[1, 2], tolerance = 1e-5)
      expect_equal(
        unname(model$credible_interval(level = 0.95)),
        reference$quantiles[1, c(1, 3)],
        tolerance = 1e-5
      )
      expect_equal(model$posterior_cdf(reference$quantiles[1, 2]), 0.5,
                   tolerance = 1e-5)
    }
  }
})

test_that("quadrature inference agrees with an integral over tau", {
  # Gamma = 1 and a half-normal tau: given tau the posterior is normal, so the
  # posterior mean is a one-dimensional integral over tau.
  model <- commensurate_prior_fast_path_model(
    list(family = "half_normal", std_dev = 1)
  )
  model$inference(quadrature_target())

  source_mean <- 0.5
  source_se <- 0.12
  estimate <- 0.9
  target_se <- 0.1
  prior_variance <- function(tau) 1 / tau + source_se^2
  marginal <- function(tau) {
    2 * stats::dnorm(tau, 0, 1) *
      stats::dnorm(estimate, source_mean, sqrt(prior_variance(tau) + target_se^2))
  }
  conditional_mean <- function(tau) {
    precision <- 1 / prior_variance(tau) + 1 / target_se^2
    (source_mean / prior_variance(tau) + estimate / target_se^2) / precision
  }
  evidence <- stats::integrate(marginal, 0, Inf, rel.tol = 1e-10)$value
  posterior_mean <- stats::integrate(
    function(tau) marginal(tau) * conditional_mean(tau), 0, Inf,
    rel.tol = 1e-10
  )$value / evidence
  posterior_tau <- stats::integrate(
    function(tau) marginal(tau) * tau, 0, Inf, rel.tol = 1e-10
  )$value / evidence

  expect_equal(model$post_mean, posterior_mean, tolerance = 1e-4)
  expect_equal(model$posterior_parameters$heterogeneity_parameter_mean,
               posterior_tau, tolerance = 1e-3)
})

test_that("quadrature inference reports the borrowing parameters", {
  power <- commensurate_fast_path_model(list(family = "half_normal", std_dev = 1))
  power$inference(quadrature_target())
  expect_named(power$posterior_parameters, c(
    "heterogeneity_parameter_mean", "heterogeneity_parameter_std",
    "power_parameter_mean", "power_parameter_std"
  ))
  expect_true(all(is.finite(unlist(power$posterior_parameters))))

  plain <- commensurate_prior_fast_path_model(list(family = "half_normal", std_dev = 1))
  plain$inference(quadrature_target())
  expect_named(plain$posterior_parameters, c(
    "heterogeneity_parameter_mean", "heterogeneity_parameter_std"
  ))

  # The mean of tau does not exist under a log-Cauchy prior.
  cauchy <- commensurate_fast_path_model(list(family = "cauchy", location = 0, scale = 30))
  cauchy$inference(quadrature_target())
  expect_identical(cauchy$posterior_parameters$heterogeneity_parameter_mean, Inf)
})

test_that("engine: stan still selects the sampler", {
  mcmc_config <- commensurate_mcmc_config()
  mcmc_config$engine <- "stan"
  model <- commensurate_model(
    commensurate_fast_path_prior(list(family = "half_normal", std_dev = 1)),
    mcmc_config = mcmc_config
  )
  expect_false(model$uses_quadrature())
  expect_true(model$mcmc)
})
