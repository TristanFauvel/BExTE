exact_target_data <- function(case_study, n, treatment_drift = 0) {
  case_study_config <- yaml::read_yaml(
    system.file("conf", "case_studies", paste0(case_study, ".yml"), package = "BExTE")
  )
  source_data <- SourceData$new(case_study_config)
  TargetDataFactory$new()$create(
    source_data = source_data,
    case_study_config = case_study_config,
    target_sample_size_per_arm = n,
    control_drift = 0,
    treatment_drift = treatment_drift,
    summary_measure_likelihood = case_study_config$summary_measure_likelihood
  )
}


test_that("generate() builds its trials from counts drawn treatment arm first", {
  for (case_study in c("aprepitant", "belimumab")) {
    target_data <- exact_target_data(case_study, 71)

    set.seed(3)
    generated <- target_data$generate(200)

    set.seed(3)
    n_treatment_responders <- rbinom(200, 71, target_data$treatment_rate)
    n_control_responders <- rbinom(200, 71, target_data$control_rate)

    expect_identical(
      generated,
      target_data$samples_from_counts(n_control_responders, n_treatment_responders),
      info = case_study
    )
  }
})


test_that("enumerate_support lists the likely trials with their probabilities", {
  for (case_study in c("aprepitant", "belimumab")) {
    target_data <- exact_target_data(case_study, 47)
    support <- target_data$enumerate_support(tail_mass = 1e-10)

    expect_equal(sum(support$weights), 1, tolerance = 1e-14, info = case_study)
    expect_lte(support$omitted_mass, 1e-10)
    expect_gt(support$omitted_mass, 0)
    expect_equal(nrow(support$samples), length(support$weights))
    expect_identical(
      colnames(support$samples),
      colnames(target_data$generate(1)),
      info = case_study
    )
  }

  # Against the binomial probabilities directly, on the rate scale.
  target_data <- exact_target_data("aprepitant", 47)
  support <- target_data$enumerate_support(tail_mass = 1e-10)
  y_control <- counts_from_rate(support$samples$sample_control_rate, 47)
  y_treatment <- counts_from_rate(support$samples$sample_treatment_rate, 47)
  expect_false(anyDuplicated(paste(y_control, y_treatment)) > 0)
  probabilities <- dbinom(y_control, 47, target_data$control_rate) *
    dbinom(y_treatment, 47, target_data$treatment_rate)
  expect_equal(support$weights, probabilities / sum(probabilities), tolerance = 1e-14)
  expect_equal(1 - sum(probabilities), support$omitted_mass, tolerance = 1e-12)
})


test_that("a larger tail mass keeps fewer trials", {
  target_data <- exact_target_data("aprepitant", 143)
  expect_lt(
    nrow(target_data$enumerate_support(tail_mass = 1e-4)$samples),
    nrow(target_data$enumerate_support(tail_mass = 1e-10)$samples)
  )
})


test_that("weighted_quantile is the type 1 quantile under equal weights", {
  set.seed(1)
  x <- rnorm(101)
  probs <- c(0.025, 0.25, 0.5, 0.75, 0.975)
  expect_equal(
    weighted_quantile(x, rep(1, 101), probs),
    unname(stats::quantile(x, probs, type = 1))
  )
  # Integer weights act as repeated values.
  expect_equal(
    weighted_quantile(c(1, 2, 3), c(1, 3, 1), probs),
    unname(stats::quantile(c(1, 2, 2, 2, 3), probs, type = 1))
  )
  expect_equal(weighted_quantile(c(NA, 2, 3), c(10, 1, 1), 0.5), 2)
})


test_that("collapse_monte_carlo_intervals puts every interval on its estimate", {
  result <- list(
    success_proba = 0.2,
    mcse_success_proba = 0.004,
    conf_int_success_proba_lower = 0.19,
    conf_int_success_proba_upper = 0.21,
    mse = 0.01,
    conf_int_mse_lower = 0.009,
    conf_int_mse_upper = 0.011,
    credible_interval_lower = -0.1,
    credible_interval_upper = 0.3,
    posterior_parameters = list(
      w = 0.4, conf_int_lower_w = 0.3, conf_int_upper_w = 0.5, median_w = 0.45
    )
  )
  collapsed <- collapse_monte_carlo_intervals(result)

  expect_identical(collapsed$conf_int_success_proba_lower, 0.2)
  expect_identical(collapsed$conf_int_success_proba_upper, 0.2)
  expect_identical(collapsed$conf_int_mse_lower, 0.01)
  expect_identical(collapsed$mcse_success_proba, 0)
  expect_identical(collapsed$posterior_parameters$conf_int_lower_w, 0.4)
  expect_identical(collapsed$posterior_parameters$conf_int_upper_w, 0.4)
  # The average credible interval is an estimate, not a Monte Carlo interval.
  expect_identical(collapsed$credible_interval_lower, -0.1)
  expect_identical(collapsed$posterior_parameters$median_w, 0.45)
})


test_that("exact enumeration is only accepted for count-based binary endpoints", {
  expect_true(case_study_exact_enumeration(
    list(exact_enumeration = list("aprepitant", "belimumab")), "belimumab"
  ))
  expect_false(case_study_exact_enumeration(
    list(exact_enumeration = list("aprepitant")), "botox"
  ))
  expect_false(case_study_exact_enumeration(list(), "aprepitant"))

  expect_silent(check_exact_enumeration_supported(
    list(endpoint = "binary", summary_measure_likelihood = "binomial"), "aprepitant"
  ))
  expect_silent(check_exact_enumeration_supported(
    list(endpoint = "binary", summary_measure_likelihood = "normal",
         sampling_approximation = FALSE), "belimumab"
  ))
  expect_error(check_exact_enumeration_supported(
    list(endpoint = "binary", summary_measure_likelihood = "normal",
         sampling_approximation = TRUE), "belimumab"
  ), "only a binary endpoint")
  expect_error(check_exact_enumeration_supported(
    list(endpoint = "continuous", summary_measure_likelihood = "normal"), "botox"
  ), "only a binary endpoint")
})


test_that("the exact type I error of the separate analysis is the binomial sum", {
  n <- 15
  target_data <- exact_target_data("aprepitant", n, treatment_drift = 0)
  # Both arms at the source control rate: a null scenario.
  target_data$treatment_rate <- target_data$control_rate
  target_data$treatment_effect <- 0

  case_study_config <- yaml::read_yaml(
    system.file("conf", "case_studies", "aprepitant.yml", package = "BExTE")
  )
  model <- Model$new()$create(
    case_study_config = case_study_config,
    method = "separate",
    method_parameters = list(initial_prior = list("noninformative")),
    source_data = SourceData$new(case_study_config),
    mcmc_config = list(
      num_chains = 4L, parallel_chains = 4L, threads_per_chain = 1L,
      tune = 1000L, target_accept = 0.9, chain_length = 5000L,
      max_chain_length = 10000L, target_ess = 10000L, rhat_threshold = 1.1,
      max_divergence_rate = 0.01, engine = "quadrature"
    )
  )
  result <- model$estimate_frequentist_operating_characteristics(
    theta_0 = 0,
    target_data = target_data,
    n_replicates = 1,
    critical_value = 0.975,
    confidence_level = 0.95,
    null_space = "left",
    n_samples_quantiles_estimation = 1000,
    case_study = "aprepitant",
    method = "separate",
    simulation_config = list(n_samples_mixture_approx = 1000),
    exact_enumeration = TRUE,
    enumeration_tail_mass = 1e-12
  )

  # Under uniform priors the arms have independent Beta posteriors, and the
  # trial succeeds when P(treatment rate > control rate) exceeds 0.975.
  p <- target_data$control_rate
  counts <- expand.grid(y_control = 0:n, y_treatment = 0:n)
  posterior_benefit <- mapply(function(y_control, y_treatment) {
    stats::integrate(function(x) {
      stats::dbeta(x, y_control + 1, n - y_control + 1) *
        stats::pbeta(x, y_treatment + 1, n - y_treatment + 1, lower.tail = FALSE)
    }, 0, 1, rel.tol = 1e-10)$value
  }, counts$y_control, counts$y_treatment)
  type_I_error <- sum(
    (posterior_benefit > 0.975) *
      dbinom(counts$y_control, n, p) * dbinom(counts$y_treatment, n, p)
  )

  expect_true(result$exact_ocs)
  expect_lte(result$enumeration_omitted_mass, 1e-12)
  expect_equal(result$success_proba, type_I_error, tolerance = 1e-10)
  expect_identical(result$conf_int_success_proba_lower, result$success_proba)
  expect_identical(result$conf_int_success_proba_upper, result$success_proba)
  expect_identical(result$mcse_success_proba, 0)
})


test_that("a simulated result is marked as such", {
  target_data <- exact_target_data("belimumab", 40)
  case_study_config <- yaml::read_yaml(
    system.file("conf", "case_studies", "belimumab.yml", package = "BExTE")
  )
  model <- Model$new()$create(
    case_study_config = case_study_config,
    method = "separate",
    method_parameters = list(initial_prior = list("noninformative")),
    source_data = SourceData$new(case_study_config)
  )
  set.seed(1)
  result <- model$estimate_frequentist_operating_characteristics(
    theta_0 = 0,
    target_data = target_data,
    n_replicates = 200,
    critical_value = 0.975,
    confidence_level = 0.95,
    null_space = "left",
    n_samples_quantiles_estimation = 1000,
    case_study = "belimumab",
    method = "separate"
  )
  expect_false(result$exact_ocs)
  expect_true(is.na(result$enumeration_omitted_mass))
  expect_gt(result$mcse_success_proba, 0)
})


test_that("a rate a rounding error outside [0, 1] is clamped onto it", {
  # The edge of Aprepitant's drift range, as rebuilt from a results file.
  target_data <- exact_target_data("aprepitant", 47, treatment_drift = -184 / 293 - 1e-16)
  expect_identical(target_data$treatment_rate, 0)

  set.seed(1)
  expect_false(anyNA(target_data$generate(20)$treatment_effect_estimate))
  support <- target_data$enumerate_support()
  expect_false(anyNA(support$weights))
  expect_true(all(support$samples$sample_treatment_rate == 0))
})
