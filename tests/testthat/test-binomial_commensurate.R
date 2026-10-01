# The commensurate priors for a binary endpoint, with separate source and
# target risk differences and the binomial likelihoods of both arms of each
# study: the lattice against brute-force integration at a fixed
# commensurability parameter, and the models built on it.

commensurate_counts <- list(
  n_control_source = 280L, n_successes_control_source = 154L,
  n_treatment_source = 293L, n_successes_treatment_source = 184L
)

commensurate_prior <- function(family) {
  list(
    source = list(sample_size_control = 280, sample_size_treatment = 293,
                  control_rate = 154 / 280, treatment_rate = 184 / 293,
                  treatment_effect_estimate = 184 / 293 - 154 / 280,
                  standard_error = 0.041),
    method_parameters = list(initial_prior = list("noninformative"),
                             heterogeneity_prior = family)
  )
}

commensurate_mcmc_config <- function(engine = NULL) {
  config <- list(num_chains = 1L, parallel_chains = 1L, tune = 1L, target_accept = 0.8,
                 chain_length = 1L, target_ess = 1L, rhat_threshold = 1.1,
                 max_divergence_rate = 0.01)
  config$engine <- engine
  config
}

commensurate_target <- function(control, treatment, n = 71) {
  list(sample_size_control = n, sample_size_treatment = n,
       sample = data.frame(sample_control_rate = control / n,
                           sample_treatment_rate = treatment / n))
}


test_that("at a fixed commensurability the lattice matches brute-force integration", {
  # The brute force integrates on its own continuous grid of 600 control rates
  # and 1201 effects, with the continuous truncation constants.
  sd_kernel <- 0.1
  M <- 600L
  v <- (seq_len(M) - 0.5) / M
  theta <- seq(-1, 1, length.out = 2 * M + 1)
  u <- (seq_len(2000) - 0.5) / 2000
  control_source <- 154 * log(u) + 126 * log1p(-u)
  shift <- max(control_source) + max(184 * log(u) + 109 * log1p(-u))
  source_density <- vapply(theta, function(s) {
    r <- u + s
    ok <- r > 0 & r < 1
    if (!any(ok)) return(0)
    sum(exp(control_source[ok] + 184 * log(r[ok]) + 109 * log1p(-r[ok]) - shift))
  }, numeric(1))
  keep <- which(source_density > 1e-12 * max(source_density))

  brute <- function(control, treatment, n = 71) {
    lc <- control * log(v) + (n - control) * log1p(-v)
    lc <- exp(lc - max(lc))
    rate <- outer(v, theta, "+")
    ok <- rate > 0 & rate < 1
    lt <- matrix(-Inf, M, length(theta))
    lt[ok] <- treatment * log(rate[ok]) + (n - treatment) * log1p(-rate[ok])
    likelihood <- lc * exp(lt - max(lt))
    density <- numeric(length(theta))
    for (s in keep) {
      z <- stats::pnorm((1 - v - theta[s]) / sd_kernel) - stats::pnorm((-v - theta[s]) / sd_kernel)
      reciprocal <- ifelse(z > 0, 1 / z, 0)
      density <- density + source_density[s] *
        colSums(likelihood * reciprocal) * stats::dnorm(theta, theta[s], sd_kernel)
    }
    grid_posterior(theta, density)
  }

  kernels <- binomial_commensurate_prior_kernels(
    commensurate_counts,
    list(tau = 1 / sd_kernel^2, inverse_tau = sd_kernel^2,
         log_tau = log(1 / sd_kernel^2), weights = 1),
    borrows_power_parameter = FALSE,
    tau_moments_exist = c(mean = TRUE, sd = TRUE),
    n_lattice = 600L
  )
  for (treatment in c(45, 20)) {
    lattice <- binomial_npp_posterior(kernels, 71, 39, 71, treatment)
    reference <- brute(39, treatment)
    expect_equal(lattice$mean, reference$mean, tolerance = 1e-3)
    expect_equal(grid_posterior_cdf(lattice, 0), grid_posterior_cdf(reference, 0), tolerance = 2e-3)
  }
})

test_that("binary commensurate priors are built as the binomial classes", {
  config <- list(summary_measure_likelihood = "binomial", null_space = "left",
                 theta_0 = 0, name = "example")
  family <- list(family = "half_normal", std_dev = 1)
  for (method in c("commensurate_power_prior", "commensurate_prior")) {
    model <- Model$new()$create(
      case_study_config = config, method = method,
      method_parameters = commensurate_prior(family)$method_parameters,
      source_data = commensurate_prior(family)$source,
      mcmc_config = commensurate_mcmc_config()
    )
    expect_s3_class(model, "BinomialCommensuratePowerPrior")
    expect_identical(model$borrows_power_parameter, method == "commensurate_power_prior")
  }
  expect_error(
    BinomialCommensuratePrior$new(prior = commensurate_prior(family),
                                  mcmc_config = commensurate_mcmc_config("stan")),
    "only computed by quadrature"
  )
})

test_that("the models report the borrowing parameters, Inf where a moment does not exist", {
  binomial_npp_cache_reset()
  half_normal <- BinomialCommensuratePowerPrior$new(
    prior = commensurate_prior(list(family = "half_normal", std_dev = 1)),
    mcmc_config = commensurate_mcmc_config()
  )
  half_normal$prior <- commensurate_prior(list(family = "half_normal", std_dev = 1))
  half_normal$n_lattice <- 300L
  half_normal$n_tau_nodes <- 12L
  expect_identical(half_normal$inference(commensurate_target(39, 45)), "Success")
  parameters <- half_normal$posterior_parameters
  expect_true(all(is.finite(unlist(parameters))))
  expect_gt(parameters$power_parameter_mean, 0)
  expect_lt(parameters$power_parameter_mean, 1)

  cauchy <- BinomialCommensuratePrior$new(
    prior = commensurate_prior(list(family = "cauchy", location = 0, scale = 30)),
    mcmc_config = commensurate_mcmc_config()
  )
  cauchy$prior <- commensurate_prior(list(family = "cauchy", location = 0, scale = 30))
  cauchy$n_lattice <- 300L
  cauchy$n_tau_nodes <- 12L
  expect_identical(cauchy$inference(commensurate_target(39, 45)), "Success")
  expect_identical(cauchy$posterior_parameters$heterogeneity_parameter_mean, Inf)
  expect_null(cauchy$posterior_parameters$power_parameter_mean)
})
