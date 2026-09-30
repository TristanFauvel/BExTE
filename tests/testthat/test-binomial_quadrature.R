# The binomial models that borrow the treatment effect - the robust mixture
# prior, its Egidi variant, the conditional power prior and the p-value-based
# power prior - compute their posterior by quadrature unless told to sample with
# Stan. These tests pin the quadrature to independent references, check that it
# has converged, and check the wiring: the engine switch, the model methods the
# simulation calls, and the sharing of analyses between equal replicates.

quadrature_mcmc_config <- function(engine = NULL) {
  config <- list(
    num_chains = 4L,
    parallel_chains = 1L,
    tune = 1000L,
    target_accept = 0.8,
    chain_length = 5000L,
    max_chain_length = 10000L,
    target_ess = 10000L,
    rhat_threshold = 1.1,
    max_divergence_rate = 0.01
  )
  config$engine <- engine
  config
}

rmp_quadrature_prior <- function(prior_weight = 0.5, empirical_bayes = TRUE) {
  list(
    source = list(
      treatment_effect_estimate = 0.078,
      standard_error = 0.041,
      equivalent_source_sample_size_per_arm = 286
    ),
    vague_mean = 0,
    method_parameters = list(
      prior_weight = list(prior_weight),
      initial_prior = list("noninformative"),
      empirical_bayes = list(empirical_bayes)
    )
  )
}

cpp_quadrature_prior <- function(power_parameter = 0.5) {
  list(
    source = list(
      treatment_effect_estimate = 184 / 293 - 154 / 280,
      standard_error = 0.041,
      sample_size_control = 280,
      sample_size_treatment = 293,
      control_rate = 154 / 280,
      treatment_rate = 184 / 293
    ),
    method_parameters = list(
      power_parameter = list(power_parameter),
      initial_prior = list("noninformative")
    )
  )
}

# The row the target data generator produces for given counts.
quadrature_samples <- function(successes_control, successes_treatment, n = 40) {
  control_rate <- successes_control / n
  treatment_rate <- successes_treatment / n
  data.frame(
    sample_control_rate = control_rate,
    sample_treatment_rate = treatment_rate,
    sample_size_per_arm = n,
    treatment_effect_estimate = treatment_rate - control_rate,
    treatment_effect_standard_error = sqrt(
      treatment_rate * (1 - treatment_rate) / n +
        control_rate * (1 - control_rate) / n
    ),
    standard_deviation = sqrt(
      treatment_rate * (1 - treatment_rate) +
        control_rate * (1 - control_rate)
    )
  )
}

quadrature_target_data <- function(samples, n = 40) {
  list(
    summary_measure_likelihood = "binomial",
    sample_size_per_arm = n,
    sample_size_control = n,
    sample_size_treatment = n,
    sample = samples[1, , drop = FALSE],
    generate = function(n_replicates) samples
  )
}

quadrature_simulation <- function(model, target_data) {
  model$simulation_for_given_treatment_effect(
    target_data = target_data,
    n_replicates = nrow(target_data$generate(0)),
    critical_value = 0.975,
    theta_0 = 0,
    confidence_level = 0.95,
    null_space = "left",
    case_study = "example",
    method = "RMP",
    to_return = c(
      "test_decision", "posterior_mean", "posterior_median",
      "credible_interval", "posterior_parameters",
      "ess_moment", "ess_precision", "ess_elir", "fit_success"
    ),
    n_samples_quantiles_estimation = 100,
    simulation_config = list(n_samples_mixture_approx = 100)
  )
}


# ---- The quadrature against independent references ---------------------------

test_that("a single flat component reproduces the separate analysis", {
  # A normal prior far wider than (-1, 1), truncated to (-v, 1 - v), is the
  # uniform prior of the separate analysis, whose posterior is the difference of
  # two independent Beta distributions.
  n <- 143
  s_c <- 80
  s_t <- 92
  posterior <- truncated_normal_mixture_binomial_posterior(
    weights = 1, means = 0, sds = 1e4,
    n_control = n, n_successes_control = s_c,
    n_treatment = n, n_successes_treatment = s_t
  )

  exact_mean <- (s_t + 1) / (n + 2) - (s_c + 1) / (n + 2)
  exact_cdf_at_zero <- stats::integrate(
    function(v) stats::pbeta(v, s_t + 1, n - s_t + 1) * stats::dbeta(v, s_c + 1, n - s_c + 1),
    0, 1, rel.tol = 1e-12
  )$value

  expect_equal(posterior$mean, exact_mean, tolerance = 1e-5)
  expect_equal(grid_posterior_cdf(posterior, 0), exact_cdf_at_zero, tolerance = 1e-4)
})


test_that("the mixture component weights agree with the existing quadrature", {
  arguments <- list(
    weights = c(0.5, 0.5), means = c(0.078, 0), sds = c(0.041, 0.6),
    n_control = 143, n_successes_control = 80,
    n_treatment = 143, n_successes_treatment = 92
  )
  grid <- do.call(truncated_normal_mixture_binomial_posterior, arguments)
  reference <- do.call(truncated_normal_mixture_binomial_weights, arguments)

  expect_equal(grid$component_weights, reference, tolerance = 1e-4)
})


test_that("the power prior posterior matches brute-force integration", {
  # Small counts keep the nested integration over both control rates quick.
  counts <- list(
    n_control_source = 12, n_successes_control_source = 7,
    n_treatment_source = 12, n_successes_treatment_source = 9,
    n_control = 10, n_successes_control = 4,
    n_treatment = 10, n_successes_treatment = 7
  )
  gamma <- 0.6

  joint <- function(theta) {
    source_part <- function(u) {
      (stats::dbinom(counts$n_successes_control_source, counts$n_control_source, u) *
         stats::dbinom(counts$n_successes_treatment_source, counts$n_treatment_source, u + theta))^gamma
    }
    stats::integrate(function(uu) vapply(uu, function(u) {
      inner <- stats::integrate(function(vv) {
        stats::dbinom(counts$n_successes_control, counts$n_control, vv) *
          stats::dbinom(counts$n_successes_treatment, counts$n_treatment, vv + theta) /
          (1 - abs(u - vv))
      }, max(0, -theta), min(1, 1 - theta), rel.tol = 1e-8)$value
      inner * source_part(u)
    }, numeric(1)), max(0, -theta), min(1, 1 - theta), rel.tol = 1e-8)$value
  }
  thetas <- seq(-0.6, 0.9, length.out = 151)
  reference <- grid_posterior(thetas, vapply(thetas, joint, numeric(1)))

  posterior <- do.call(
    binomial_power_prior_posterior,
    c(list(power_parameter = gamma), counts)
  )

  expect_equal(posterior$mean, reference$mean, tolerance = 5e-4)
  expect_equal(
    grid_posterior_cdf(posterior, 0), grid_posterior_cdf(reference, 0),
    tolerance = 1e-3
  )
})


test_that("the quadrature has converged at the default resolution", {
  rmp <- function(nodes, points) {
    truncated_normal_mixture_binomial_posterior(
      weights = c(0.5, 0.5), means = c(0.078, 0), sds = c(0.041, 0.6),
      n_control = 143, n_successes_control = 80,
      n_treatment = 143, n_successes_treatment = 92,
      n_control_nodes = nodes, points_per_scale = points
    )
  }
  cpp <- function(nodes, points) {
    binomial_power_prior_posterior(
      power_parameter = 0.5,
      n_control_source = 280, n_successes_control_source = 154,
      n_treatment_source = 293, n_successes_treatment_source = 184,
      n_control = 143, n_successes_control = 80,
      n_treatment = 143, n_successes_treatment = 92,
      n_control_nodes = nodes, n_source_nodes = nodes,
      points_per_scale = points
    )
  }

  for (build in list(rmp, cpp)) {
    default <- build(512L, 20)
    fine <- build(2048L, 60)
    expect_equal(grid_posterior_cdf(default, 0), grid_posterior_cdf(fine, 0), tolerance = 1e-4)
    expect_equal(
      grid_posterior_quantile(default, c(0.025, 0.975)),
      grid_posterior_quantile(fine, c(0.025, 0.975)),
      tolerance = 1e-3
    )
  }
})


test_that("with no target patients the power prior posterior is the prior", {
  prior <- binomial_power_prior_posterior(
    power_parameter = 1,
    n_control_source = 280, n_successes_control_source = 154,
    n_treatment_source = 293, n_successes_treatment_source = 184,
    n_control = 0, n_successes_control = 0,
    n_treatment = 0, n_successes_treatment = 0
  )

  # At full borrowing, the prior mean sits on the source difference in rates.
  expect_equal(prior$mean, 184 / 293 - 154 / 280, tolerance = 5e-3)
})


# ---- The engine switch ---------------------------------------------------------

test_that("the binomial robust mixture prior uses quadrature by default", {
  model <- TruncatedGaussianRMP$new(
    prior = rmp_quadrature_prior(empirical_bayes = FALSE),
    mcmc_config = quadrature_mcmc_config()
  )

  expect_true(model$uses_quadrature())
  expect_false(model$mcmc)
  expect_true(model$deterministic_inference)
  expect_null(model$stan_model)
})


test_that("engine = \"stan\" keeps the sampling path", {
  model <- testthat::with_mocked_bindings(
    TruncatedGaussianRMP$new(
      prior = rmp_quadrature_prior(empirical_bayes = FALSE),
      mcmc_config = quadrature_mcmc_config(engine = "stan")
    ),
    compile_stan_model = function(...) "compiled",
    .package = "BExTE"
  )

  expect_false(model$uses_quadrature())
  expect_true(model$mcmc)
  expect_false(model$deterministic_inference)
  expect_identical(model$stan_model, "compiled")
})


test_that("a model without a quadrature implementation samples whatever the engine", {
  model <- MCMCModel$new(prior = NULL, mcmc_config = quadrature_mcmc_config("quadrature"))

  expect_false(model$uses_quadrature())
  expect_true(model$mcmc)
})


test_that("an unknown engine is rejected", {
  expect_error(
    MCMCModel$new(prior = NULL, mcmc_config = quadrature_mcmc_config("gibbs")),
    "engine"
  )
})


# ---- The model methods the simulation calls ----------------------------------

test_that("the robust mixture prior reports a consistent quadrature posterior", {
  model <- TruncatedGaussianRMP$new(
    prior = rmp_quadrature_prior(prior_weight = 0.5, empirical_bayes = FALSE),
    mcmc_config = quadrature_mcmc_config()
  )
  target_data <- quadrature_target_data(quadrature_samples(22, 30))
  model$vague_prior_variance <- 0.3^2

  expect_identical(model$inference(target_data), "Success")

  interval <- model$credible_interval(level = 0.95)
  expect_equal(model$posterior_cdf(interval), c(0.025, 0.975), tolerance = 1e-6)
  expect_equal(model$posterior_cdf(model$post_median), 0.5, tolerance = 1e-6)
  expect_identical(
    model$test_decision(critical_value = 0.975, theta_0 = 0, null_space = "left",
                        confidence_level = 0.95),
    1 - model$posterior_cdf(0) > 0.975
  )
  # The reported weight is the informative component's, from the same grid.
  expect_equal(
    model$posterior_parameters$prior_weight,
    truncated_normal_mixture_binomial_weights(
      weights = c(0.5, 0.5), means = c(0.078, 0), sds = c(0.041, 0.3),
      n_control = 40, n_successes_control = 22,
      n_treatment = 40, n_successes_treatment = 30
    )[1],
    tolerance = 1e-4
  )
  # Other credible levels are available, unlike from the Stan summary.
  expect_length(model$credible_interval(level = 0.9), 2)
})


test_that("the conditional power prior samples its prior by quadrature", {
  prior <- cpp_quadrature_prior(power_parameter = 1)
  model <- BinomialCPP$new(prior = prior, mcmc_config = quadrature_mcmc_config())
  # Model$create() attaches the prior after construction; so do these tests.
  model$prior <- prior

  set.seed(1)
  draws <- model$sample_prior(20000)

  expect_null(model$stan_model)
  expect_equal(mean(draws), 184 / 293 - 154 / 280, tolerance = 1e-2)
})


test_that("the p-value-based power prior discards its prior when the power parameter changes", {
  prior <- list(
    source = list(
      treatment_effect_estimate = 184 / 293 - 154 / 280,
      standard_error = 0.041,
      equivalent_source_sample_size_per_arm = 286,
      sample_size_control = 280,
      sample_size_treatment = 293,
      control_rate = 154 / 280,
      treatment_rate = 184 / 293
    ),
    method_parameters = list(
      power_parameter = list(NA_real_),
      shape_parameter = list(1),
      equivalence_margin = list(0.1),
      initial_prior = list("noninformative")
    )
  )
  model <- p_value_based_PP_Binomial$new(
    prior = prior,
    theta_0 = 0,
    null_space = "left",
    mcmc_config = quadrature_mcmc_config()
  )
  model$prior <- prior

  model$inference(quadrature_target_data(quadrature_samples(22, 25)))
  first <- model$power_parameter
  set.seed(1)
  first_prior <- mean(model$sample_prior(20000))

  model$inference(quadrature_target_data(quadrature_samples(22, 36)))
  second <- model$power_parameter
  set.seed(1)
  second_prior <- mean(model$sample_prior(20000))

  expect_false(isTRUE(all.equal(first, second)))
  expect_false(isTRUE(all.equal(first_prior, second_prior)))
})


# ---- Sharing analyses between equal replicates ---------------------------------

test_that("an empirical Bayes quadrature model is cached, and the cache changes nothing", {
  samples <- quadrature_samples(
    successes_control = c(20, 24, 20, 24, 20),
    successes_treatment = c(30, 26, 30, 26, 30)
  )
  build <- function() {
    TruncatedGaussianRMP$new(
      prior = rmp_quadrature_prior(prior_weight = 0.5, empirical_bayes = TRUE),
      mcmc_config = quadrature_mcmc_config()
    )
  }

  inference_cache_reset()
  cached <- quadrature_simulation(build(), quadrature_target_data(samples))
  expect_equal(inference_cache_size(), 2)

  inference_cache_reset()
  uncached_model <- build()
  uncached_model$empirical_bayes_from_sample <- FALSE
  uncached <- quadrature_simulation(uncached_model, quadrature_target_data(samples))
  expect_equal(inference_cache_size(), 0)

  for (output in c("test_decisions", "posterior_means", "posterior_medians",
                   "credible_intervals", "ess_moments", "ess_elir")) {
    expect_equal(cached[[output]], uncached[[output]], label = output)
  }
})


test_that("the Stan engine keeps empirical Bayes models out of the cache", {
  model <- testthat::with_mocked_bindings(
    TruncatedGaussianRMP$new(
      prior = rmp_quadrature_prior(empirical_bayes = TRUE),
      mcmc_config = quadrature_mcmc_config(engine = "stan")
    ),
    compile_stan_model = function(...) NULL,
    .package = "BExTE"
  )

  scope <- model$inference_cache_scope(
    target_data = quadrature_target_data(quadrature_samples(20, 30)),
    critical_value = 0.975,
    theta_0 = 0,
    confidence_level = 0.95,
    null_space = "left",
    n_samples_quantiles_estimation = 100,
    simulation_config = list(n_samples_mixture_approx = 100)
  )

  expect_null(scope)
})
