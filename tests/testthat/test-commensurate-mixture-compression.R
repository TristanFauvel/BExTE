# The commensurate fast path replaces its quadrature mixture with a compressed
# one - see compress_commensurate_mixture(). Fixtures live in
# helper-commensurate.R.

compression_samples <- function(n = 400) {
  estimate <- seq(-0.5, 1.5, length.out = n)
  standard_error <- rep(c(0.08, 0.12, 0.2), length.out = n)
  data.frame(
    treatment_effect_estimate = estimate,
    treatment_effect_standard_error = standard_error,
    standard_deviation = standard_error * sqrt(60)
  )
}

all_outputs <- c(
  "test_decision", "posterior_mean", "posterior_median", "credible_interval",
  "posterior_parameters", "ess_moment", "ess_precision", "ess_elir",
  "fit_success", "mcmc_diagnostics"
)


test_that("the Gauss rule of a discrete measure matches its moments", {
  nodes <- seq(0.01, 1, length.out = 300)
  weights <- exp(-3 * nodes) * (1 + sin(20 * nodes)^2)
  rule <- gauss_rule_for_discrete_measure(nodes, weights, 10)

  expect_length(rule$nodes, 10)
  for (degree in 0:19) {
    expect_equal(
      sum(rule$weights * rule$nodes^degree),
      sum(weights * nodes^degree),
      tolerance = 1e-12
    )
  }
})


test_that("a measure with few distinct atoms gets an exact, shorter rule", {
  rule <- gauss_rule_for_discrete_measure(
    rep(c(0.2, 0.7), each = 50), rep(1, 100), 10
  )

  expect_length(rule$nodes, 2)
  expect_equal(sort(rule$nodes), c(0.2, 0.7), tolerance = 1e-12)
  expect_equal(rule$weights, c(50, 50), tolerance = 1e-12)
})


test_that("a scale mixture no larger than the rule is left as it is", {
  compressed <- compress_normal_scale_mixture(
    weights = c(0.5, 0.5), variances = c(1, 2),
    reference_variance = 1, n_nodes = 4
  )

  expect_identical(compressed, list(weights = c(0.5, 0.5), variances = c(1, 2)))
})


test_that("compression leaves every fast-path output unchanged", {
  priors <- c(
    commensurate_configured_priors(),
    list(list(family = "inverse_gamma", alpha = 1 / 1000, beta = 1))
  )
  samples <- compression_samples()

  for (prior in priors) {
    model <- commensurate_fast_path_model(prior)

    expect_false(is.null(compress_commensurate_mixture(
      commensurate_prior_mixture(model), samples, theta_0 = 0,
      confidence_level = 0.95,
      heterogeneity_prior_family = model$heterogeneity_prior_family,
      heterogeneity_prior = prior
    )))

    compressed <- commensurate_fast_path_run(model, all_outputs, samples = samples)
    full <- local({
      local_mocked_bindings(compress_commensurate_mixture = function(...) NULL)
      commensurate_fast_path_run(model, all_outputs, samples = samples)
    })

    expect_identical(compressed$test_decisions, full$test_decisions)
    for (output in c("posterior_means", "posterior_medians",
                     "credible_intervals", "ess_moments", "ess_precisions",
                     "ess_elir")) {
      expect_equal(compressed[[output]], full[[output]], tolerance = 1e-9,
                   info = paste(prior$family, output))
    }
    expect_equal(compressed$posterior_parameters, full$posterior_parameters,
                 tolerance = 1e-9, info = prior$family)
  }
})


test_that("a mixture too small to repay compression is kept whole", {
  model <- commensurate_prior_fast_path_model(list(
    family = "half_normal",
    std_dev = 1
  ))
  mixture <- commensurate_prior_mixture(model)
  expect_lt(length(mixture$weights), 4 * 32)

  expect_null(compress_commensurate_mixture(
    mixture, compression_samples(), theta_0 = 0, confidence_level = 0.95,
    heterogeneity_prior_family = "half_normal",
    heterogeneity_prior = list(family = "half_normal", std_dev = 1)
  ))
})


test_that("a parameter the rules cannot integrate keeps the mixture whole", {
  model <- commensurate_fast_path_model(list(family = "half_normal", std_dev = 1))
  mixture <- commensurate_prior_mixture(model)
  mixture$tau[1] <- Inf

  expect_null(compress_commensurate_mixture(
    mixture, compression_samples(), theta_0 = 0, confidence_level = 0.95,
    heterogeneity_prior_family = "half_normal",
    heterogeneity_prior = list(family = "half_normal", std_dev = 1)
  ))
})


test_that("decisions at the critical value are retaken on the full mixture", {
  model <- commensurate_fast_path_model(list(family = "half_normal", std_dev = 1))
  mixture <- commensurate_prior_mixture(model)
  standard_error <- 0.1

  probability_of_benefit <- function(estimate) {
    posterior <- normal_mixture_posterior(
      mixture$weights, mixture$means, mixture$sds, estimate, standard_error
    )
    1 - sum(posterior$weights * stats::pnorm(0, posterior$means, posterior$sds))
  }
  borderline <- stats::uniroot(
    function(estimate) probability_of_benefit(estimate) - 0.975,
    c(0, 1), tol = 1e-14
  )$root
  estimate <- c(borderline, 1.5)
  posterior <- normal_mixture_posterior(
    mixture$weights, mixture$means, mixture$sds, estimate, standard_error
  )
  exact <- as.numeric(vectorised_test_decision(
    posterior$weights, posterior$means, posterior$sds,
    critical_value = 0.975, theta_0 = 0, null_space = "left"
  ))

  # The borderline decision is deliberately wrong going in; the clear one is
  # left alone even though it is wrong too, since it is nowhere near the line.
  rechecked <- recheck_borderline_decisions(
    test_decisions = 1 - exact,
    posterior = posterior,
    mixture = mixture,
    estimate = estimate,
    standard_error = rep(standard_error, 2),
    critical_value = 0.975,
    theta_0 = 0,
    null_space = "left"
  )

  expect_equal(rechecked, c(exact[1], 1 - exact[2]))
})
