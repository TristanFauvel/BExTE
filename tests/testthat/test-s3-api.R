## The S3 front end only builds the arguments of the R6 classes and calls
## them, so each check compares it with the same R6 calls made by hand.

belimumab_path <- function() {
  system.file("conf/case_studies/belimumab.yml", package = "BExTE")
}

belimumab_target <- function() {
  target_data(n_control = 39, n_treatment = 53,
              responses_control = 17, responses_treatment = 28)
}

r6_posterior <- function(source, target, method, method_parameters) {
  model <- Model$new()$create(
    case_study_config = source$config,
    method = method,
    method_parameters = c(list(initial_prior = "noninformative"), method_parameters),
    source_data = source$data,
    mcmc_config = api_default_config("full/mcmc_config.yml")
  )
  target_r6 <- api_target_r6(target, source)
  model$calibrate_for_design(api_design_target(source, target_r6$sample_size_per_arm))
  model$inference(target_r6)
  model
}

test_that("posterior() matches the R6 chain for each method", {
  src <- source_data(config = belimumab_path())
  tgt <- belimumab_target()
  cases <- list(
    list(separate_prior(src), "separate", list()),
    list(pooling_prior(src), "pooling", list()),
    list(npp(src, a0_mean = 0.5, a0_sd = 0.2), "NPP",
         list(power_parameter_mean = 0.5, power_parameter_std = 0.2)),
    list(rmp(src, weight = 0.5), "RMP",
         list(prior_weight = 0.5, empirical_bayes = FALSE)),
    list(commensurate_prior(src), "commensurate_prior",
         list(heterogeneity_prior = default_heterogeneity_prior()))
  )
  for (case in cases) {
    post <- posterior(case[[1]], tgt)
    model <- r6_posterior(src, tgt, case[[2]], case[[3]])
    expect_s3_class(post, "bexte_posterior")
    expect_equal(post$model$post_mean, model$post_mean, info = case[[2]])
    expect_equal(post$model$post_var, model$post_var, info = case[[2]])
  }
})

test_that("source_data() from arguments matches the configuration file", {
  from_config <- source_data(config = belimumab_path())
  from_args <- source_data(n_control = 562, n_treatment = 563,
                           responses_control = 218, responses_treatment = 285)
  expect_equal(from_args$data$treatment_effect_estimate,
               from_config$data$treatment_effect_estimate)
  expect_equal(from_args$data$standard_error, from_config$data$standard_error)
})

test_that("the binomial likelihood analyses the risk difference", {
  src <- source_data(n_control = 280, n_treatment = 293,
                     responses_control = 154, responses_treatment = 184,
                     likelihood = "binomial")
  post <- posterior(separate_prior(src),
                    target_data(n_control = 52, n_treatment = 57,
                                responses_control = 42, responses_treatment = 48))
  expect_equal(post$target_r6$sample$treatment_effect_estimate, 48 / 57 - 42 / 52)
  expect_lt(abs(summary(post)$mean - (48 / 57 - 42 / 52)), 0.01)
})

test_that("summary(), quantile() and as.data.frame() agree", {
  post <- posterior(rmp(source_data(config = belimumab_path()), weight = 0.5),
                    belimumab_target())
  s <- summary(post, level = 0.9)
  q <- quantile(post, c(0.05, 0.95))
  expect_s3_class(s, "summary.bexte_posterior")
  expect_equal(c(s$lower, s$upper), unname(q))
  expect_equal(s$mean, unname(post$model$post_mean))
  expect_equal(nrow(as.data.frame(post)), 1)
  expect_output(print(post), "Robust mixture prior")
})

test_that("ess() matches the R6 methods", {
  post <- posterior(rmp(source_data(config = belimumab_path()), weight = 0.5),
                    belimumab_target())
  simulation_config <- api_simulation_config()
  expect_equal(ess(post), post$model$prior_elir_ess(post$target_r6, simulation_config))
  expect_gt(ess(post, method = "moment"), 0)
})

test_that("decision() uses the hypothesis of the source by default", {
  src <- source_data(config = belimumab_path())
  post <- posterior(pooling_prior(src), belimumab_target())
  # The posterior probability of a benefit, from the posterior CDF.
  proba_benefit <- 1 - post$model$posterior_cdf(0)
  expect_equal(decision(0.975)(post), proba_benefit > 0.975)
  expect_equal(decision(0.5, theta_0 = 10)(post), FALSE)
  expect_error(decision(1.5), "critical_value")
})

test_that("oc_frequentist() matches the R6 method with the same seed", {
  src <- source_data(config = system.file("conf/case_studies/botox.yml", package = "BExTE"))
  prior <- rmp(src, weight = 0.5)
  set.seed(3)
  oc <- oc_frequentist(prior, decision(0.975), n_per_arm = 50, drift = -0.2, n_rep = 20)

  set.seed(3)
  model <- api_create_model(prior)
  target <- api_design_target(src, 50, drift = -0.2)
  model$calibrate_for_design(target)
  simulation_config <- api_simulation_config(critical_value = 0.975, confidence_level = 0.95)
  expected <- model$estimate_frequentist_operating_characteristics(
    theta_0 = 0, target_data = target, n_replicates = 20, critical_value = 0.975,
    confidence_level = 0.95, null_space = "left",
    n_samples_quantiles_estimation = simulation_config$n_samples_quantiles_estimation,
    case_study = src$config$name, method = "RMP", simulation_config = simulation_config
  )

  expect_s3_class(oc, "bexte_oc_frequentist")
  expect_equal(oc$success_proba, expected$success_proba)
  expect_equal(oc$true_effect, 0)
  expect_true(oc$null_true)
  expect_equal(summary(oc)$metric, "type I error")
})

test_that("oc_bayesian() runs for each design prior and differs from the frequentist class", {
  src <- source_data(config = system.file("conf/case_studies/botox.yml", package = "BExTE"))
  for (type in c("source_posterior", "unit_information", "analysis_prior")) {
    set.seed(4)
    # With this few draws, a ratio such as the average power can leave [0, 1]
    # and check_probability_value() warns as it clips it.
    oc <- suppressWarnings(
      oc_bayesian(rmp(src, weight = 0.5), decision(0.975), design_prior(type),
                  n_per_arm = 50, n_rep = 5, n_draws = 5)
    )
    expect_s3_class(oc, "bexte_oc_bayesian")
    expect_false(inherits(oc, "bexte_oc_frequentist"))
    expect_true(all(c("prior_proba_success", "average_tie", "average_power") %in%
                      names(summary(oc))), info = type)
  }
  expect_error(
    oc_bayesian(eb_power_prior(src), decision(), design_prior("analysis_prior"),
                n_per_arm = 50, n_rep = 5, n_draws = 5),
    "empirical Bayes"
  )
})

test_that("the builders reject bad arguments", {
  src <- source_data(config = belimumab_path())
  expect_error(power_prior(src, 2), "a0")
  expect_error(npp(src, a0_mean = 0.5, a0_sd = 0.6), "a0_sd")
  expect_error(rmp(src, weight = -1), "weight")
  expect_error(commensurate_prior(src, list(family = "gamma")), "heterogeneity_prior")
  expect_error(npp(list()), "source_data")
  expect_error(source_data(10, 10), "either")
  expect_error(posterior(src, belimumab_target()), "prior builder")
  expect_error(oc_frequentist(rmp(src), 0.975, 10), "decision")
})
