# The normalized power prior for a binary endpoint, with the binomial likelihood
# of each arm rather than a normal approximation of the risk difference. These
# tests pin the lattice to independent references at a fixed power parameter,
# check the integration over the power parameter, and check the wiring into the
# model the simulation builds.

npp_source <- list(
  n_control_source = 280L, n_successes_control_source = 154L,
  n_treatment_source = 293L, n_successes_treatment_source = 184L
)

fixed_gamma_kernels <- function(gamma, n_lattice = 500L) {
  do.call(binomial_npp_prior_kernels, c(npp_source, list(
    gamma_rule = list(nodes = gamma, weights = 1), n_lattice = n_lattice
  )))
}

npp_prior <- function(mean = 0.5, std = 0.2) {
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
      initial_prior = list("noninformative"),
      power_parameter_mean = list(mean),
      power_parameter_std = list(std)
    )
  )
}

npp_mcmc_config <- function(engine = NULL) {
  config <- list(
    num_chains = 4L, parallel_chains = 1L, tune = 1000L, target_accept = 0.8,
    chain_length = 5000L, max_chain_length = 10000L, target_ess = 10000L,
    rhat_threshold = 1.1, max_divergence_rate = 0.01
  )
  config$engine <- engine
  config
}

npp_target_data <- function(successes_control, successes_treatment, n) {
  control_rate <- successes_control / n
  treatment_rate <- successes_treatment / n
  list(
    summary_measure_likelihood = "binomial",
    sample_size_per_arm = n,
    sample_size_control = n,
    sample_size_treatment = n,
    sample = data.frame(
      sample_control_rate = control_rate,
      sample_treatment_rate = treatment_rate,
      sample_size_per_arm = n,
      treatment_effect_estimate = treatment_rate - control_rate,
      treatment_effect_standard_error = sqrt(
        treatment_rate * (1 - treatment_rate) / n + control_rate * (1 - control_rate) / n
      ),
      standard_deviation = sqrt(
        treatment_rate * (1 - treatment_rate) + control_rate * (1 - control_rate)
      )
    )
  )
}


# ---- At a fixed power parameter: the conditional power prior -----------------

test_that("with a single power parameter the lattice is the conditional power prior", {
  # Without conflict, the existing quadrature of the conditional power prior is
  # an independent reference.
  for (gamma in c(0, 0.3, 1)) {
    lattice <- binomial_npp_posterior(fixed_gamma_kernels(gamma), 71, 39, 71, 45)
    reference <- binomial_power_prior_posterior(gamma, 280L, 154L, 293L, 184L, 71L, 39L, 71L, 45L)
    expect_equal(lattice$mean, reference$mean, tolerance = 1e-4)
    expect_equal(sqrt(lattice$variance), sqrt(reference$variance), tolerance = 1e-3)
    expect_equal(grid_posterior_cdf(lattice, 0), grid_posterior_cdf(reference, 0), tolerance = 1e-3)
  }
})

test_that("the lattice matches Stan when the target conflicts with the source", {
  # Stan, 4 x 25,000 draws of the BinomialCPP program (effective sample size
  # about 60,000): the posterior moves into the tails of the source likelihood,
  # which a lattice over the whole unit square follows.
  moderate <- binomial_npp_posterior(fixed_gamma_kernels(1), 71, 39, 71, 20)
  expect_equal(moderate$mean, 0.0091689, tolerance = 0.001)
  expect_equal(1 - grid_posterior_cdf(moderate, 0), 0.59745, tolerance = 0.006)

  strong <- binomial_npp_posterior(fixed_gamma_kernels(1), 143, 79, 143, 0)
  expect_equal(strong$mean, -0.18789, tolerance = 0.001)
  expect_equal(sqrt(strong$variance), 0.0345939, tolerance = 0.001)
})

test_that("a coarser lattice gives the same posterior", {
  coarse <- binomial_npp_posterior(fixed_gamma_kernels(0.3, 300L), 71, 39, 71, 20)
  fine <- binomial_npp_posterior(fixed_gamma_kernels(0.3, 600L), 71, 39, 71, 20)
  expect_equal(coarse$mean, fine$mean, tolerance = 1e-4)
  expect_equal(grid_posterior_cdf(coarse, 0), grid_posterior_cdf(fine, 0), tolerance = 1e-3)
})


# ---- Integrating over the power parameter ------------------------------------

test_that("the power parameter rule integrates the Beta prior", {
  for (std in c(0.1, 0.2, 0.4)) {
    shapes <- npp_beta_shapes(0.5, std)
    rule <- npp_gamma_rule(shapes$p, shapes$q)
    expect_equal(sum(rule$weights), 1)
    expect_equal(sum(rule$weights * rule$nodes), 0.5, tolerance = 1e-7)
    expect_equal(sqrt(sum(rule$weights * rule$nodes^2) - 0.25), std, tolerance = 1e-6)
  }
})

test_that("without target data the power parameter keeps its prior", {
  for (std in c(0.2, 0.4)) {
    shapes <- npp_beta_shapes(0.5, std)
    kernels <- do.call(binomial_npp_prior_kernels, c(npp_source, list(
      gamma_rule = npp_gamma_rule(shapes$p, shapes$q), n_lattice = 300L
    )))
    prior <- binomial_npp_posterior(kernels, 0, 0, 0, 0)
    expect_equal(prior$power_parameter_mean, 0.5, tolerance = 1e-4)
    expect_equal(prior$power_parameter_std, std, tolerance = 1e-4)
  }
})

test_that("the power parameter moves towards zero as the target conflicts", {
  shapes <- npp_beta_shapes(0.5, 0.2)
  kernels <- do.call(binomial_npp_prior_kernels, c(npp_source, list(
    gamma_rule = npp_gamma_rule(shapes$p, shapes$q), n_lattice = 300L
  )))
  consistent <- binomial_npp_posterior(kernels, 71, 39, 71, 45)
  conflicting <- binomial_npp_posterior(kernels, 71, 39, 71, 20)
  expect_gt(consistent$power_parameter_mean, conflicting$power_parameter_mean)
  expect_lt(conflicting$power_parameter_mean, 0.35)
})

test_that("a finer power parameter rule changes nothing", {
  shapes <- npp_beta_shapes(0.5, 0.4)
  posterior <- function(rule) {
    kernels <- do.call(binomial_npp_prior_kernels, c(npp_source, list(
      gamma_rule = rule, n_lattice = 300L
    )))
    binomial_npp_posterior(kernels, 71, 39, 71, 20)
  }
  default <- posterior(npp_gamma_rule(shapes$p, shapes$q))
  fine <- posterior(npp_gamma_rule(shapes$p, shapes$q, t_limit = 40, t_step = 0.0125))
  expect_equal(default$mean, fine$mean, tolerance = 1e-5)
  expect_equal(default$power_parameter_mean, fine$power_parameter_mean, tolerance = 1e-4)
})


# ---- The model ---------------------------------------------------------------

test_that("a binary NPP is built as BinomialNPP, a normal one as GaussianNPP", {
  binomial <- Model$new()$create(
    case_study_config = list(summary_measure_likelihood = "binomial", null_space = "left",
                             theta_0 = 0, name = "example"),
    method = "NPP",
    method_parameters = npp_prior()$method_parameters,
    source_data = npp_prior()$source,
    mcmc_config = npp_mcmc_config()
  )
  expect_s3_class(binomial, "BinomialNPP")
  expect_false(binomial$mcmc)
  expect_true(binomial$deterministic_inference)

  normal <- Model$new()$create(
    case_study_config = list(summary_measure_likelihood = "normal", null_space = "left",
                             theta_0 = 0, name = "example"),
    method = "NPP",
    method_parameters = npp_prior()$method_parameters,
    source_data = list(treatment_effect_estimate = 0.078, standard_error = 0.041,
                       equivalent_source_sample_size_per_arm = 286),
    mcmc_config = npp_mcmc_config()
  )
  expect_s3_class(normal, "GaussianNPP")
})

test_that("the binomial NPP refuses the Stan engine", {
  expect_error(
    BinomialNPP$new(prior = npp_prior(), mcmc_config = npp_mcmc_config(engine = "stan")),
    "only computed by quadrature"
  )
})

test_that("the model reports its posterior and the power parameter's", {
  model <- BinomialNPP$new(prior = npp_prior(), mcmc_config = npp_mcmc_config())
  model$prior <- npp_prior()
  model$n_lattice <- 300L
  target_data <- npp_target_data(39, 45, 71)

  expect_identical(model$inference(target_data), "Success")
  interval <- model$credible_interval(level = 0.95)
  expect_equal(model$posterior_cdf(interval), c(0.025, 0.975), tolerance = 1e-6)
  expect_identical(
    model$test_decision(critical_value = 0.975, theta_0 = 0, null_space = "left",
                        confidence_level = 0.95),
    1 - model$posterior_cdf(0) > 0.975
  )
  expect_named(model$posterior_parameters, c("power_parameter_mean", "power_parameter_std"))
  expect_gt(model$posterior_parameters$power_parameter_mean, 0)
  expect_lt(model$posterior_parameters$power_parameter_mean, 1)
})

test_that("the prior given a control rate stays within the admissible effects", {
  model <- BinomialNPP$new(prior = npp_prior(), mcmc_config = npp_mcmc_config())
  model$prior <- npp_prior()
  model$n_lattice <- 300L
  conditional <- model$prior_given_control_rate(0.55)
  expect_equal(conditional$cdf(-0.56), 0)
  expect_equal(conditional$cdf(0.46), 1)
  expect_equal(conditional$cdf(0.6), 1)
  set.seed(1)
  draws <- conditional$sample(5000)
  expect_true(all(draws >= -0.56 & draws <= 0.46))
})

test_that("replicates with the same counts share one analysis", {
  inference_cache_reset()
  model <- BinomialNPP$new(prior = npp_prior(), mcmc_config = npp_mcmc_config())
  model$prior <- npp_prior()
  model$n_lattice <- 300L
  one <- npp_target_data(22, 30, 40)$sample
  other <- npp_target_data(20, 31, 40)$sample
  samples <- rbind(one, other, one)
  target_data <- npp_target_data(22, 30, 40)

  result <- model$simulation_for_given_treatment_effect(
    target_data = target_data, n_replicates = 3, critical_value = 0.975,
    theta_0 = 0, confidence_level = 0.95, null_space = "left",
    case_study = "example", method = "NPP",
    to_return = c("test_decision", "posterior_mean", "credible_interval",
                  "posterior_parameters", "ess_elir"),
    n_samples_quantiles_estimation = 100,
    simulation_config = list(n_samples_mixture_approx = 1000),
    samples = samples
  )
  expect_identical(result$posterior_means[1], result$posterior_means[3])
  expect_false(identical(result$posterior_means[1], result$posterior_means[2]))
  expect_equal(nrow(result$posterior_parameters), 3)
  expect_true(all(is.finite(result$ess_elir) & result$ess_elir > 0))
})
