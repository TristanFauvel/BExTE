# The KL-calibrated normalized power prior for a binary endpoint: calibrated
# with the normal criterion, analysed with the binomial normalized power prior.

kl_config <- function() {
  yaml::read_yaml(testthat::test_path("..", "..", "inst", "conf", "case_studies", "aprepitant.yml"))
}

kl_mcmc_config <- function() {
  list(num_chains = 1L, parallel_chains = 1L, tune = 1L, target_accept = 0.8,
       chain_length = 1L, target_ess = 1L, rhat_threshold = 1.1,
       max_divergence_rate = 0.01, engine = "quadrature")
}

kl_design <- function(config, source_data, drift) {
  TargetDataFactory$new()$create(
    source_data = source_data, case_study_config = config,
    target_sample_size_per_arm = 71, control_drift = 0,
    treatment_drift = drift, summary_measure_likelihood = config$summary_measure_likelihood
  )
}


test_that("a binary KL-NPP is built as BinomialNPP_KL", {
  config <- kl_config()
  model <- Model$new()$create(
    case_study_config = config, method = "NPP_KL",
    method_parameters = list(initial_prior = list("noninformative")),
    source_data = SourceData$new(config), mcmc_config = kl_mcmc_config()
  )
  expect_s3_class(model, "BinomialNPP_KL")
  expect_error(model$kernels(), "no prior on the power parameter")
})

test_that("for a binary endpoint the calibration does not depend on the drift", {
  # The expected target standard error is taken at zero treatment drift; at
  # the scenario's true rates it would make the prior depend on the true
  # treatment effect.
  config <- kl_config()
  source_data <- SourceData$new(config)
  model <- Model$new()$create(
    case_study_config = config, method = "NPP_KL",
    method_parameters = list(initial_prior = list("noninformative")),
    source_data = source_data, mcmc_config = kl_mcmc_config()
  )
  shapes <- sapply(c(-0.4, 0, 0.3), function(drift) {
    model$calibrate_for_design(kl_design(config, source_data, drift))
    c(model$p, model$q, model$calibration$se_target_expected)
  })
  expect_equal(shapes[, 1], shapes[, 2])
  expect_equal(shapes[, 3], shapes[, 2])
  # At zero drift it is the design's own standard error.
  design <- kl_design(config, source_data, 0)
  expect_equal(shapes[3, 2], design$standard_deviation / sqrt(71))
})

test_that("the binomial calibration is close to the normal one", {
  # The same criterion on the exact marginal likelihood of the expected counts:
  # for the Aprepitant design the two priors differ by a few thousandths.
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  config <- kl_config()
  source_data <- SourceData$new(config)
  model <- Model$new()$create(
    case_study_config = config, method = "NPP_KL",
    method_parameters = list(initial_prior = list("noninformative")),
    source_data = source_data, mcmc_config = kl_mcmc_config()
  )
  design <- kl_design(config, source_data, 0)
  model$calibrate_for_design(design)
  normal <- npp_kl_calibrate_design(model$prior$source, design, config$theta_0,
                                    model$calibration_settings)
  binomial <- npp_kl_beta_moments(model$p, model$q)
  reference <- npp_kl_beta_moments(normal$alpha_gamma, normal$beta_gamma)
  expect_equal(binomial$mean, reference$mean, tolerance = 0.01)
  expect_equal(binomial$sd, reference$sd, tolerance = 0.01)
  expect_true(model$calibration$optimizer_converged)
})

test_that("a continuous endpoint keeps the design's standard error", {
  design <- list(standard_deviation = 2, sample_size_per_arm = 100)
  expect_equal(npp_kl_expected_target_se(design, list()), 0.2)
})
