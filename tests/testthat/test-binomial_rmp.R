# The robust mixture priors for a binary endpoint with an exact binomial
# informative component: the full-borrowing conditional power prior, mixed
# with independent uniform response rates.

rmp_source <- list(n_control_source = 280L, n_successes_control_source = 154L,
                   n_treatment_source = 293L, n_successes_treatment_source = 184L)

rmp_prior <- function(weight = 0.5) {
  list(
    source = list(sample_size_control = 280, sample_size_treatment = 293,
                  control_rate = 154 / 280, treatment_rate = 184 / 293,
                  treatment_effect_estimate = 184 / 293 - 154 / 280,
                  standard_error = 0.041, equivalent_source_sample_size_per_arm = 286),
    method_parameters = list(initial_prior = list("noninformative"),
                             prior_weight = list(weight), empirical_bayes = list(FALSE))
  )
}

rmp_mcmc_config <- function() {
  list(num_chains = 1L, parallel_chains = 1L, tune = 1L, target_accept = 0.8,
       chain_length = 1L, target_ess = 1L, rhat_threshold = 1.1, max_divergence_rate = 0.01)
}

rmp_target <- function(control, treatment, n = 71) {
  control_rate <- control / n
  treatment_rate <- treatment / n
  list(sample_size_control = n, sample_size_treatment = n, sample_size_per_arm = n,
       sample = data.frame(
         sample_control_rate = control_rate, sample_treatment_rate = treatment_rate,
         treatment_effect_estimate = treatment_rate - control_rate,
         treatment_effect_standard_error = sqrt(treatment_rate * (1 - treatment_rate) / n +
                                                  control_rate * (1 - control_rate) / n),
         standard_deviation = sqrt(treatment_rate * (1 - treatment_rate) +
                                     control_rate * (1 - control_rate))
       ))
}


# The informative and weak prior-predictive tables of the binomial RMP, which
# Egidi's conflict p-value and weight selection read.
rmp_predictive_tables <- function(n_control, n_treatment) {
  components <- binomial_rmp_components(rmp_source, n_lattice = 500L)
  binomial_rmp_predictive_tables(components, rmp_source, n_control, n_treatment)
}


test_that("the weak component alone is the separate analysis", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  components <- binomial_rmp_components(rmp_source, n_lattice = 500L)
  posterior <- binomial_npp_posterior(binomial_rmp_kernels(components, 0), 71, 39, 71, 20)
  exact <- stats::integrate(function(c) {
    stats::dbeta(c, 40, 33) * stats::pbeta(c, 21, 52, lower.tail = FALSE)
  }, 0, 1, rel.tol = 1e-12)$value
  expect_equal(1 - grid_posterior_cdf(posterior, 0), exact, tolerance = 1e-4)
  expect_equal(posterior$mean, 21 / 73 - 40 / 73, tolerance = 1e-6)
})

test_that("the informative component alone is the full-borrowing power prior", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  components <- binomial_rmp_components(rmp_source, n_lattice = 500L)
  posterior <- binomial_npp_posterior(binomial_rmp_kernels(components, 1), 71, 39, 71, 33)
  reference <- binomial_power_prior_posterior(1, 280, 154, 293, 184, 71, 39, 71, 33, n_lattice = 500L)
  expect_equal(posterior$mean, reference$mean, tolerance = 1e-10)
  expect_equal(grid_posterior_cdf(posterior, 0), grid_posterior_cdf(reference, 0), tolerance = 1e-10)
})

test_that("the posterior weight follows the marginal likelihoods", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  components <- binomial_rmp_components(rmp_source, n_lattice = 500L)
  agree <- binomial_npp_posterior(binomial_rmp_kernels(components, 0.5), 71, 39, 71, 45)
  conflict <- binomial_npp_posterior(binomial_rmp_kernels(components, 0.5), 71, 39, 71, 20)
  expect_gt(agree$prior_weight_mean, 0.5)
  expect_lt(conflict$prior_weight_mean, 0.05)
})

test_that("the predictive tables are distributions, the weak one uniform", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  components <- binomial_rmp_components(rmp_source, n_lattice = 500L)
  tables <- binomial_rmp_predictive_tables(components, rmp_source, 30L, 30L)
  expect_equal(sum(tables$informative), 1, tolerance = 1e-10)
  expect_equal(dim(tables$informative), c(31L, 31L))
  expect_true(all(tables$weak == 1 / 31^2))
})

test_that("binary RMP and Egidi are built as the exact binomial classes", {
  config <- list(summary_measure_likelihood = "binomial", null_space = "left",
                 theta_0 = 0, name = "example")
  rmp <- Model$new()$create(case_study_config = config, method = "RMP",
                            method_parameters = rmp_prior()$method_parameters,
                            source_data = rmp_prior()$source, mcmc_config = rmp_mcmc_config())
  expect_s3_class(rmp, "BinomialRMP")
  egidi <- Model$new()$create(case_study_config = config, method = "egidi_empirical_mixture",
                              method_parameters = list(initial_prior = list("noninformative")),
                              source_data = rmp_prior()$source, mcmc_config = rmp_mcmc_config())
  expect_s3_class(egidi, "BinomialEgidiMixture")
})

test_that("Egidi's weight discounts the source only under conflict", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  binomial_npp_cache_reset()
  prior <- rmp_prior()
  prior$method_parameters$empirical_bayes <- list(TRUE)
  model <- BinomialEgidiMixture$new(prior = prior, mcmc_config = rmp_mcmc_config())
  model$prior <- prior
  model$n_lattice <- 500L
  expect_identical(model$inference(rmp_target(39, 45)), "Success")
  expect_equal(model$selection$psi_weak, 0)
  expect_identical(model$inference(rmp_target(39, 20)), "Success")
  expect_gt(model$selection$psi_weak, 0)
  expect_true(is.finite(model$posterior_parameters$prior_weight))
})


test_that("the conflict p-value path matches the p-value at each weight", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  tables <- rmp_predictive_tables(20L, 20L)
  informative <- tables$informative
  weak <- tables$weak
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
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  tables <- rmp_predictive_tables(20L, 20L)
  informative <- tables$informative
  weak <- tables$weak

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


test_that("the discrete conflict p-value sums the right cells", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  tables <- rmp_predictive_tables(20L, 20L)
  informative <- tables$informative
  weak <- tables$weak
  psi <- 0.3
  mixture <- (1 - psi) * informative + psi * weak

  modal <- which(mixture == max(mixture), arr.ind = TRUE)[1, ]
  ## At the most probable cell nothing else is less probable, so the whole
  ## sample space conflicts at least as much and the p-value is one.
  expect_equal(
    egidi_binomial_conflict_pvalue(informative, weak, psi,
                                   modal[1] - 1L, modal[2] - 1L),
    1, tolerance = 1e-8
  )

  ## At an arbitrary cell it is the mass at or below that cell's, computed here
  ## directly from the table.
  observed <- mixture[6, 15]
  expect_equal(
    egidi_binomial_conflict_pvalue(informative, weak, psi, 5L, 14L),
    sum(mixture[mixture <= observed * (1 + 1e-9)]) / sum(mixture),
    tolerance = 1e-12
  )
})


test_that("the binomial selection rule behaves at both ends", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  tables <- rmp_predictive_tables(20L, 20L)
  informative <- tables$informative
  weak <- tables$weak

  modal <- which(((1 - 0) * informative) == max(informative), arr.ind = TRUE)[1, ]
  agreeing <- egidi_select_weak_weight_binomial(
    informative, weak, modal[1] - 1L, modal[2] - 1L
  )
  expect_equal(agreeing$psi_weak, 0)
  expect_false(agreeing$initial_conflict)

  ## Every responder in the control arm and none in the treatment arm is as far
  ## from the source as this sample space reaches: only the weak component
  ## alone accepts it. That component is exactly uniform over the pairs of
  ## counts, so at psi = 1 every cell has p-value one and the conflict resolves.
  extreme <- egidi_select_weak_weight_binomial(informative, weak, 20L, 0L)
  expect_true(extreme$initial_conflict)
  expect_equal(extreme$psi_weak, 1)
  expect_false(extreme$conflict_unresolved)
})
