# The binomial test-then-pool and p-value based power prior spent most of their
# time on the ELIR of the prior, refitting a mixture to fresh prior draws for
# every replicate, and the Egidi mixture rebuilt its prior-predictive tables in
# every scenario. These tests pin the faster routes: that test-then-pool reads
# each component's own fixed ELIR and may share analyses through the inference
# cache, that the power prior's ELIR is interpolated from cached nodes without
# touching the caller's random numbers, and that the Egidi tables are unchanged
# by how they are now computed and cached.

speedup_prior <- function(method_parameters) {
  list(
    source = list(
      standard_error = 0.1,
      treatment_effect_estimate = 0.25,
      equivalent_source_sample_size_per_arm = 40,
      sample_size_control = 40,
      sample_size_treatment = 40,
      summary_measure_likelihood = "binomial",
      control_rate = 0.25,
      treatment_rate = 0.5
    ),
    method_parameters = c(
      list(initial_prior = list("noninformative")),
      method_parameters
    )
  )
}

speedup_mcmc_config <- function() {
  list(
    num_chains = 4L,
    parallel_chains = 4L,
    tune = 1000L,
    target_accept = 0.9,
    chain_length = 5000L,
    max_chain_length = 10000L,
    target_ess = 10000L,
    rhat_threshold = 1.1,
    max_divergence_rate = 0.01
  )
}

speedup_samples <- function(successes_control, successes_treatment, n = 40) {
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

speedup_target_data <- function(samples, n = 40) {
  list(
    summary_measure_likelihood = "binomial",
    sample_size_per_arm = n,
    sample_size_control = n,
    sample_size_treatment = n,
    sample = samples[1, , drop = FALSE],
    generate = function(n_replicates) samples
  )
}

speedup_simulation <- function(model, target_data) {
  model$simulation_for_given_treatment_effect(
    target_data = target_data,
    n_replicates = nrow(target_data$generate(0)),
    critical_value = 0.975,
    theta_0 = 0,
    confidence_level = 0.95,
    null_space = "left",
    case_study = "example",
    method = model$method,
    to_return = c("test_decision", "posterior_mean", "credible_interval",
                  "posterior_parameters", "ess_moment", "ess_precision",
                  "ess_elir", "fit_success"),
    n_samples_quantiles_estimation = 100,
    simulation_config = list(n_samples_mixture_approx = 100)
  )
}

# The model factory assigns the prior after construction, as these do.
test_then_pool_model <- function() {
  prior <- speedup_prior(list(significance_level = list(0.1)))
  model <- TestThenPoolDifference$new(prior = prior, mcmc_config = speedup_mcmc_config())
  model$prior <- prior
  model
}

p_value_power_prior_model <- function() {
  prior <- speedup_prior(list(
    shape_parameter = list(1),
    equivalence_margin = list(0.5)
  ))
  model <- p_value_based_PP_Binomial$new(
    prior = prior,
    theta_0 = 0,
    null_space = "left",
    mcmc_config = speedup_mcmc_config()
  )
  model$prior <- prior
  model
}


test_that("test-then-pool reports the ELIR of the component its test selected", {
  model <- test_then_pool_model()
  simulation_config <- list(n_samples_mixture_approx = 100)
  # A target on the source effect is pooled, one far from it is not.
  pooled <- speedup_target_data(speedup_samples(10, 20))
  separate <- speedup_target_data(speedup_samples(20, 10))

  set.seed(1)
  model$test(pooled)
  expect_true(model$pool)
  pooled_elir <- model$prior_elir_ess(pooled, simulation_config)
  expect_equal(pooled_elir, model$pooling$prior_elir_ess(pooled, simulation_config))

  model$test(separate)
  expect_false(model$pool)
  separate_elir <- model$prior_elir_ess(separate, simulation_config)
  expect_equal(separate_elir, model$separate$prior_elir_ess(separate, simulation_config))

  # Neither component's prior depends on the data, so each is fitted once:
  # asking again returns the same value rather than a fresh fit's.
  model$test(pooled)
  expect_identical(model$prior_elir_ess(pooled, simulation_config), pooled_elir)
})


test_that("binomial test-then-pool may share analyses, normal test-then-pool may not", {
  expect_true(test_then_pool_model()$deterministic_inference)
  expect_true(test_then_pool_model()$empirical_bayes_from_sample)

  normal_prior <- speedup_prior(list(significance_level = list(0.1)))
  normal_prior$source$summary_measure_likelihood <- "normal"
  normal_model <- TestThenPoolDifference$new(prior = normal_prior)
  expect_false(normal_model$deterministic_inference)
})


test_that("test-then-pool results are unchanged by the inference cache", {
  # Pooled and separate replicates interleaved and repeated, so that a cached
  # replicate follows one that selected the other component.
  samples <- speedup_samples(
    successes_control = c(10, 20, 10, 20, 10),
    successes_treatment = c(20, 10, 20, 10, 20)
  )

  uncached_model <- test_then_pool_model()
  uncached_model$deterministic_inference <- FALSE
  inference_cache_reset()
  set.seed(20260930)
  uncached <- speedup_simulation(uncached_model, speedup_target_data(samples))

  inference_cache_reset()
  set.seed(20260930)
  cached <- speedup_simulation(test_then_pool_model(), speedup_target_data(samples))

  expect_equal(inference_cache_size(), 2)
  expect_equal(cached, uncached)
})


test_that("a power prior ELIR node is the mean over its fits, drawn under a fixed seed", {
  power_prior_elir_cache_reset()
  model <- p_value_power_prior_model()

  node <- binomial_power_prior_unit_elir(model, 0.5, n_samples = 200, n_fits = 2L)
  direct <- grid_prior_unit_elir(
    prior_grid = model$quadrature_prior(power_parameter = 0.5),
    n_samples = 200,
    n_fits = 2L,
    n_components = model$n_components_mixture_approx,
    aic_penalty = model$aic_penalty_parameter_mixture_approx
  )

  expect_equal(node, direct)
  expect_true(is.finite(node) && node > 0)
  expect_equal(power_prior_elir_cache_size(), 1)
})


test_that("the power prior ELIR is interpolated linearly between cached nodes", {
  power_prior_elir_cache_reset()
  model <- p_value_power_prior_model()
  unit_elir <- function(gamma) {
    binomial_power_prior_unit_elir(model, gamma, n_samples = 200, n_fits = 2L)
  }

  lower <- unit_elir(0.3)
  upper <- unit_elir(0.35)
  expect_equal(unit_elir(0.32), 0.6 * lower + 0.4 * upper)
  # The interpolated value was read off the two nodes already held.
  expect_equal(power_prior_elir_cache_size(), 2)
  # A power parameter of one is a node rather than the start of an interval.
  expect_true(is.finite(unit_elir(1)))
})


test_that("filling a power prior ELIR node leaves the caller's random numbers alone", {
  power_prior_elir_cache_reset()
  model <- p_value_power_prior_model()

  set.seed(7)
  expected <- stats::runif(3)

  set.seed(7)
  binomial_power_prior_unit_elir(model, 0.5, n_samples = 200, n_fits = 2L)
  expect_equal(stats::runif(3), expected)
})


test_that("the p-value based power prior rescales the interpolated unit ELIR", {
  power_prior_elir_cache_reset()
  model <- p_value_power_prior_model()
  target_data <- speedup_target_data(speedup_samples(12, 18))
  model$empirical_bayes_update(target_data)

  simulation_config <- list(n_samples_mixture_approx = 200)
  elir <- model$prior_elir_ess(target_data, simulation_config)

  expect_equal(
    elir,
    binomial_power_prior_unit_elir(model, model$power_parameter, n_samples = 200) *
      target_data$sample$standard_deviation^2
  )
})


test_that("the Egidi table equals the pairwise kernel it replaces", {
  n_control <- 12L
  n_treatment <- 15L
  n_nodes <- 201L
  mu <- 0.1
  sd <- 0.3

  # The table as it was computed before the kernel was indexed by offset.
  nodes <- seq(0, 1, length.out = n_nodes)
  spacing <- nodes[2] - nodes[1]
  simpson <- c(1, rep(c(4, 2), length.out = n_nodes - 2), 1) * spacing / 3
  normalisers <- stats::pnorm(1 - nodes, mu, sd) - stats::pnorm(-nodes, mu, sd)
  control <- outer(nodes, 0:n_control, function(p, y) stats::dbinom(y, n_control, p)) * simpson
  treatment <- outer(nodes, 0:n_treatment, function(p, y) stats::dbinom(y, n_treatment, p)) * simpson
  kernel <- outer(nodes, nodes, function(c, t) stats::dnorm(t - c, mu, sd)) / normalisers
  reference <- crossprod(control, kernel %*% treatment)

  table <- egidi_binomial_predictive_table(mu, sd, n_control, n_treatment, n_nodes = n_nodes, block = 64L)
  expect_equal(table, reference, tolerance = 1e-12)
})


test_that("Egidi tables are built once and the cache is bounded", {
  egidi_table_cache_reset()
  first <- egidi_cached_predictive_table(0.1, 0.3, 12L, 15L, 201L)
  expect_identical(first, egidi_binomial_predictive_table(0.1, 0.3, 12L, 15L, n_nodes = 201L))
  expect_identical(egidi_cached_predictive_table(0.1, 0.3, 12L, 15L, 201L), first)
  expect_equal(length(ls(egidi_table_cache_store)), 1)

  # A second table overflows a cache sized for one, which is emptied first.
  egidi_cached_predictive_table(0.1, 0.4, 12L, 15L, 201L, max_bytes = 8 * 13 * 16 * 1.5)
  expect_equal(length(ls(egidi_table_cache_store)), 1)
  egidi_table_cache_reset()
})


test_that("the conflict p-value path matches the p-value at each weight", {
  informative <- egidi_binomial_predictive_table(0.1, 0.05, 20L, 20L, n_nodes = 2001L)
  weak <- egidi_binomial_predictive_table(0, 0.7, 20L, 20L, n_nodes = 2001L)
  psi <- seq(0, 1, by = 0.01)

  for (counts in list(c(3L, 17L), c(10L, 12L), c(0L, 20L), c(15L, 2L))) {
    direct <- vapply(psi, function(p) {
      egidi_binomial_conflict_pvalue(informative, weak, p, counts[1], counts[2])
    }, numeric(1))
    path <- egidi_binomial_conflict_pvalue_path(informative, weak, psi, counts[1], counts[2])
    expect_equal(path, direct, tolerance = 1e-10)
  }
})


test_that("the weight selected through the path is the scan's", {
  informative <- egidi_binomial_predictive_table(0.1, 0.05, 20L, 20L, n_nodes = 2001L)
  weak <- egidi_binomial_predictive_table(0, 0.7, 20L, 20L, n_nodes = 2001L)

  # The scan as it was, one weight at a time.
  scan <- function(y_control, y_treatment) {
    for (candidate in seq(0.001, 1, by = 0.001)) {
      pvalue <- egidi_binomial_conflict_pvalue(informative, weak, candidate, y_control, y_treatment)
      if (pvalue >= 0.05) return(candidate)
    }
    1
  }

  for (y_control in c(0L, 5L, 10L, 20L)) for (y_treatment in c(0L, 3L, 12L, 20L)) {
    selection <- egidi_select_weak_weight_binomial(informative, weak, y_control, y_treatment)
    if (isTRUE(selection$initial_conflict) && !isTRUE(selection$conflict_unresolved)) {
      expect_equal(selection$psi_weak, scan(y_control, y_treatment))
    }
  }
})
