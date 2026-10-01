# The empirical Bayes power prior for a binary endpoint, with the binomial
# likelihood of each arm: the marginal likelihood against brute-force
# integration, the maximization, and the wiring into the model.

ebpp_prior <- function() {
  list(
    source = list(
      treatment_effect_estimate = 184 / 293 - 154 / 280,
      standard_error = 0.041,
      sample_size_control = 280,
      sample_size_treatment = 293,
      control_rate = 154 / 280,
      treatment_rate = 184 / 293
    ),
    method_parameters = list(initial_prior = list("noninformative"))
  )
}

ebpp_mcmc_config <- function(engine = NULL) {
  config <- list(
    num_chains = 4L, parallel_chains = 1L, tune = 1000L, target_accept = 0.8,
    chain_length = 5000L, max_chain_length = 10000L, target_ess = 10000L,
    rhat_threshold = 1.1, max_divergence_rate = 0.01
  )
  config$engine <- engine
  config
}

ebpp_target_data <- function(successes_control, successes_treatment, n) {
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


test_that("the marginal likelihood matches brute-force integration", {
  # Small counts keep the nested integration quick. The marginal likelihood is
  # Z_T(gamma) / Z_S(gamma), each a triple integral over both control rates and
  # the risk difference.
  source_part <- function(u, theta, gamma) {
    (stats::dbinom(7, 12, u) * stats::dbinom(9, 12, u + theta))^gamma
  }
  inner <- function(u, theta, with_target) {
    stats::integrate(function(vv) {
      likelihood <- if (with_target) {
        stats::dbinom(4, 10, vv) * stats::dbinom(2, 10, vv + theta)
      } else {
        1
      }
      likelihood / (1 - abs(u - vv))
    }, max(0, -theta), min(1, 1 - theta), rel.tol = 1e-9)$value
  }
  integral <- function(gamma, with_target) {
    stats::integrate(function(tt) vapply(tt, function(theta) {
      stats::integrate(function(uu) vapply(uu, function(u) {
        inner(u, theta, with_target) * source_part(u, theta, gamma)
      }, numeric(1)), max(0, -theta), min(1, 1 - theta), rel.tol = 1e-9)$value
    }, numeric(1)), -1, 1, rel.tol = 1e-8, subdivisions = 500)$value
  }
  brute <- function(gamma) log(integral(gamma, TRUE)) - log(integral(gamma, FALSE))

  terms <- binomial_power_prior_target_terms(12, 7, 12, 9, 10, 4, 10, 2, n_lattice = 1000L)
  lattice <- binomial_power_prior_log_marginal(terms, c(0, 0.6))
  expect_equal(lattice[2] - lattice[1], brute(0.6) - brute(0), tolerance = 1e-4)
})

test_that("the estimate is the maximum of the marginal likelihood", {
  for (treatment in c(45, 33, 20)) {
    terms <- binomial_power_prior_target_terms(280, 154, 293, 184, 71, 39, 71, treatment,
                                               n_lattice = 500L)
    estimate <- binomial_power_prior_empirical_bayes(terms)
    fine <- seq(0, 1, by = 0.002)
    values <- binomial_power_prior_log_marginal(terms, fine)
    expect_gte(binomial_power_prior_log_marginal(terms, estimate), max(values) - 1e-8)
  }
})

test_that("agreement borrows fully and strong conflict not at all", {
  agree <- binomial_power_prior_target_terms(280, 154, 293, 184, 71, 39, 71, 45, n_lattice = 500L)
  expect_equal(binomial_power_prior_empirical_bayes(agree), 1)
  conflict <- binomial_power_prior_target_terms(280, 154, 293, 184, 143, 79, 143, 0, n_lattice = 500L)
  expect_equal(binomial_power_prior_empirical_bayes(conflict), 0)
})

test_that("the posterior from the target terms is the power prior posterior", {
  terms <- binomial_power_prior_target_terms(280, 154, 293, 184, 71, 39, 71, 33, n_lattice = 500L)
  from_terms <- binomial_power_prior_terms_posterior(terms, 0.4)
  direct <- binomial_power_prior_posterior(0.4, 280, 154, 293, 184, 71, 39, 71, 33, n_lattice = 500L)
  expect_equal(from_terms$mean, direct$mean, tolerance = 1e-10)
  expect_equal(grid_posterior_cdf(from_terms, 0), grid_posterior_cdf(direct, 0), tolerance = 1e-10)
})

test_that("a binary EB-PP is built as BinomialGravestockEBPP", {
  model <- Model$new()$create(
    case_study_config = list(summary_measure_likelihood = "binomial", null_space = "left",
                             theta_0 = 0, name = "example"),
    method = "EB_PP",
    method_parameters = ebpp_prior()$method_parameters,
    source_data = ebpp_prior()$source,
    mcmc_config = ebpp_mcmc_config()
  )
  expect_s3_class(model, "BinomialGravestockEBPP")
  expect_false(model$mcmc)
})

test_that("the model analyses each replicate at its own power parameter", {
  binomial_npp_cache_reset()
  inference_cache_reset()
  model <- BinomialGravestockEBPP$new(prior = ebpp_prior(), mcmc_config = ebpp_mcmc_config())
  model$prior <- ebpp_prior()

  agree <- ebpp_target_data(39, 45, 71)
  conflict <- ebpp_target_data(39, 20, 71)
  expect_identical(model$inference(agree), "Success")
  expect_equal(model$posterior_parameters$power_parameter, 1)
  agree_mean <- model$post_mean
  expect_identical(model$inference(conflict), "Success")
  expect_lt(model$posterior_parameters$power_parameter, 0.05)

  # The same dataset again: the estimate is read from the cache, and the
  # posterior, computed afresh, is the same.
  expect_identical(model$inference(agree), "Success")
  expect_equal(model$post_mean, agree_mean, tolerance = 1e-10)

  interval <- model$credible_interval(level = 0.95)
  expect_equal(model$posterior_cdf(interval), c(0.025, 0.975), tolerance = 1e-6)
})
