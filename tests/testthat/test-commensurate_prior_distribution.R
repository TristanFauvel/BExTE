# The prior density, CDF and draws of the two commensurate models feed the
# analysis-prior design prior of the Bayesian operating characteristics. They
# are checked here against a reference that shares no code with them: exact
# draws of the borrowing parameters, with the treatment effect integrated out
# analytically (Rao-Blackwellised), so no draw is ever dropped or truncated.
#
# Fixtures (commensurate_fast_path_model() and friends) live in
# helper-commensurate.R.

commensurate_reference_draws <- function(model, n_draws) {
  prior <- model$prior$method_parameters$heterogeneity_prior
  log_tau <- switch(
    model$heterogeneity_prior_family,
    cauchy = stats::rcauchy(n_draws, prior$location, prior$scale),
    half_normal = log(abs(stats::rnorm(n_draws, 0, prior$std_dev))),
    # 1 / tau^2 ~ Gamma(alpha, rate = beta), on the log scale so that the
    # shape of 1/1000 does not underflow to a precision of exactly zero.
    inverse_gamma = -0.5 * (log(stats::runif(n_draws)) / prior$alpha +
      log(stats::rgamma(n_draws, prior$alpha + 1, prior$beta)))
  )
  power_parameter <- if (isTRUE(model$borrows_power_parameter)) {
    stats::rbeta(n_draws, pmax(log_tau, 1), 1)
  } else {
    1
  }
  list(
    mean = model$prior$source$treatment_effect_estimate,
    # log-sum-exp of 1 / tau and the source variance: finite for any log_tau.
    log_sd = 0.5 * pmax(-log_tau, log(model$prior$source$standard_error^2 /
      power_parameter)) +
      0.5 * log1p(exp(-abs(-log_tau - log(
        model$prior$source$standard_error^2 / power_parameter
      ))))
  )
}

reference_cdf <- function(reference, x) {
  sd <- exp(reference$log_sd)
  vapply(x, function(xi) mean(stats::pnorm(xi, reference$mean, sd)), numeric(1))
}

reference_pdf <- function(reference, x) {
  sd <- exp(reference$log_sd)
  vapply(x, function(xi) mean(stats::dnorm(xi, reference$mean, sd)), numeric(1))
}

commensurate_prior_models <- function() {
  models <- list()
  for (prior in commensurate_configured_priors()) {
    models <- c(models, list(
      commensurate_fast_path_model(prior),
      commensurate_prior_fast_path_model(prior)
    ))
  }
  models
}

test_that("the prior density and CDF keep every part of the prior", {
  # The earlier density integrated tau over [0.001, 100] and renormalised,
  # which kept 0.9% of an inverse_gamma(1/1000, 1) prior and 12% of a
  # Cauchy(0, 30) one.
  set.seed(11)
  x <- 0.5 + c(-1, -0.4, -0.1, 0, 0.1, 0.4, 1)

  for (model in commensurate_prior_models()) {
    reference <- commensurate_reference_draws(model, 4e5)

    expect_equal(model$prior_cdf(x), reference_cdf(reference, x),
                 tolerance = 3e-3)
    expect_equal(model$prior_pdf(x), reference_pdf(reference, x),
                 tolerance = 1e-2)
  }
})

test_that("the prior density is the derivative of the prior CDF", {
  x <- c(-0.3, 0.2, 0.5, 0.9)
  step <- 1e-5

  for (model in commensurate_prior_models()) {
    slope <- (model$prior_cdf(x + step) - model$prior_cdf(x - step)) /
      (2 * step)
    expect_equal(model$prior_pdf(x), slope, tolerance = 1e-5)
  }
})

test_that("prior draws are neither dropped nor recycled", {
  set.seed(5)
  n_draws <- 2e5

  for (model in commensurate_prior_models()) {
    draws <- model$sample_prior(n_draws)

    expect_length(draws, n_draws)
    expect_true(all(is.finite(draws)))

    # Dropping the least representable precisions and recycling the remaining
    # standard deviations both show up as a CDF that is too concentrated.
    reference <- commensurate_reference_draws(model, 4e5)
    x <- 0.5 + c(-1, -0.2, 0.2, 1)
    expect_equal(stats::ecdf(draws)(x), reference_cdf(reference, x),
                 tolerance = 5e-3)
  }
})

test_that("a Cauchy(0, 30) prior keeps its most diffuse draws", {
  set.seed(3)
  model <- commensurate_fast_path_model(
    list(family = "cauchy", location = 0, scale = 30)
  )
  draws <- model$sample_prior(2e5)

  # |theta - theta_S| > 1e10 needs 1 / tau of order 1e20, that is
  # log(tau) < -46: probability pcauchy(-46, 0, 30), about 0.18.
  expect_equal(mean(abs(draws - 0.5) > 1e10), stats::pcauchy(-46, 0, 30),
               tolerance = 1e-2)
})
