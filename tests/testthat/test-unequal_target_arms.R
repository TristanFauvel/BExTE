## The target study may have arms of different sizes. A summary-based method
## sees them only through the standard error and the equivalent sample size
## per arm, 2 / (1 / n_C + 1 / n_T); an arm-level one reads each arm.

case_study_config <- function(case_study, sampling_approximation = NULL) {
  config <- yaml::yaml.load_file(
    system.file("conf/case_studies", paste0(case_study, ".yml"), package = "BExTE")
  )
  if (!is.null(sampling_approximation)) {
    config$sampling_approximation <- sampling_approximation
  }
  config
}

unequal_target <- function(case_study, n_control = 40, n_treatment = 120,
                           sampling_approximation = NULL) {
  config <- case_study_config(case_study, sampling_approximation)
  TargetDataFactory$new()$create(
    source_data = ObservedSourceData$new(config),
    case_study_config = config,
    target_sample_size_control = n_control,
    target_sample_size_treatment = n_treatment,
    treatment_drift = 0,
    summary_measure_likelihood = config$summary_measure_likelihood
  )
}

test_that("the equivalent sample size per arm is the harmonic mean of the arms", {
  expect_equal(effective_arm_size(30, 60), 40)
  expect_equal(effective_arm_size(46, 46), 46)
  expect_equal(target_effective_arm_size(list(sample_size_control = 30,
                                              sample_size_treatment = 60)), 40)
})

test_that("the total target sample size is split by the allocation ratio", {
  expect_equal(split_target_sample_size(93, 1), list(control = 46, treatment = 46))
  expect_equal(split_target_sample_size(300, 2), list(control = 100, treatment = 200))
  expect_equal(split_target_sample_size(301, 0.5), list(control = 201, treatment = 100))
  expect_error(split_target_sample_size(5, 10), "fewer than 2 patients")
  expect_error(split_target_sample_size(100, 0), "positive")
})

test_that("the allocation ratio is read per case study, then for the run", {
  expect_equal(target_allocation_ratio(list(), "botox"), 1)
  config <- list(target_allocation_ratio = 2,
                 case_study_target_allocation_ratio = list(belimumab = list(1.5)))
  expect_equal(target_allocation_ratio(config, "botox"), 2)
  expect_equal(target_allocation_ratio(config, "belimumab"), 1.5)
  expect_error(target_allocation_ratio(list(target_allocation_ratio = -1), "botox"),
               "positive")
})

test_that("each generator draws estimates whose spread matches the design standard error", {
  cases <- list(
    list(case_study = "botox", sampling_approximation = TRUE),
    list(case_study = "botox", sampling_approximation = FALSE),
    list(case_study = "aprepitant", sampling_approximation = FALSE),
    list(case_study = "belimumab", sampling_approximation = FALSE),
    list(case_study = "belimumab", sampling_approximation = TRUE),
    list(case_study = "mepolizumab", sampling_approximation = TRUE),
    list(case_study = "teriflunomide", sampling_approximation = FALSE)
  )
  for (case in cases) {
    set.seed(1)
    target <- unequal_target(case$case_study,
                             sampling_approximation = case$sampling_approximation)
    samples <- target$generate(4000)
    label <- paste(case$case_study, case$sampling_approximation)
    design_se <- target$standard_deviation / sqrt(target_effective_arm_size(target))

    expect_equal(unique(samples$sample_size_control), 40, info = label)
    expect_equal(unique(samples$sample_size_treatment), 120, info = label)
    expect_equal(sd(samples$treatment_effect_estimate, na.rm = TRUE), design_se,
                 tolerance = 0.06, info = label)
    expect_equal(mean(samples$treatment_effect_standard_error, na.rm = TRUE), design_se,
                 tolerance = 0.06, info = label)
    # The per-patient standard deviation of each replicate is on the same scale.
    expect_equal(samples$standard_deviation,
                 samples$treatment_effect_standard_error * sqrt(target_effective_arm_size(target)),
                 info = label)
  }
})

test_that("the binary design standard error adds the variance of each arm", {
  target <- unequal_target("aprepitant")
  expect_equal(
    target$standard_deviation / sqrt(target_effective_arm_size(target)),
    sqrt(target$treatment_rate * (1 - target$treatment_rate) / 120 +
           target$control_rate * (1 - target$control_rate) / 40)
  )
})

test_that("the recurrent event design standard error uses each arm's size", {
  target <- unequal_target("mepolizumab")
  variance <- function(mu, k) negative_binomial_variance(mu, k)
  expect_equal(
    target$standard_deviation / sqrt(target_effective_arm_size(target)),
    sqrt(variance(target$treatment_rate, target$k_treatment) /
           (120 * target$treatment_rate^2) +
           variance(target$control_rate, target$k_control) /
           (40 * target$control_rate^2))
  )
})

test_that("the time-to-event trial has the requested number of patients in each arm", {
  target <- unequal_target("teriflunomide", n_control = 30, n_treatment = 90)
  events <- time_to_event_expected_events(case_study_config("teriflunomide"), 30, 90)
  balanced <- time_to_event_expected_events(case_study_config("teriflunomide"), 30)
  expect_equal(events[["control"]], balanced[["control"]])
  expect_equal(events[["treatment"]], 3 * balanced[["treatment"]])
  # The design variance is 1 / E[events] in each arm.
  expect_equal(
    target$standard_deviation^2 / target_effective_arm_size(target),
    1 / events[["control"]] + 1 / events[["treatment"]],
    tolerance = 1e-6
  )
})

test_that("balanced arms keep the design standard deviation of one patient per arm", {
  target <- unequal_target("teriflunomide", n_control = 50, n_treatment = 50)
  parameters <- target$arm_parameters()
  per_patient <- time_to_event_standard_deviation(
    control_parameter = parameters$control,
    treatment_parameter = parameters$treatment,
    event_time_distribution = target$event_time_distribution,
    weibull_shape = target$weibull_shape,
    accrual_period = target$accrual_period,
    final_follow_up = target$final_follow_up,
    max_follow_up_time = target$max_follow_up_time,
    dropout_rate = target$dropout_rate()
  )
  expect_identical(target$standard_deviation, per_patient)
})

test_that("summary-based posteriors depend on the arms only through the standard error and the equivalent size", {
  src <- source_data(config = system.file("conf/case_studies/botox.yml", package = "BExTE"))
  # 30 and 60 patients are as precise as 40 per arm.
  unequal <- target_data(n_control = 30, n_treatment = 60, estimate = 0.3, se = 0.2)
  balanced <- target_data(n_control = 40, n_treatment = 40, estimate = 0.3, se = 0.2)
  priors <- list(
    separate = separate_prior(src),
    pooling = pooling_prior(src),
    power_prior = power_prior(src, a0 = 0.5),
    npp = npp(src),
    rmp = rmp(src, weight = 0.5),
    rmp_empirical_bayes = rmp(src, weight = 0.5, empirical_bayes = TRUE),
    egidi = egidi_mixture(src),
    eb_power_prior = eb_power_prior(src),
    test_then_pool = test_then_pool(src)
  )
  for (name in names(priors)) {
    a <- posterior(priors[[name]], unequal)
    b <- posterior(priors[[name]], balanced)
    expect_equal(summary(a), summary(b), info = name)
  }
})

test_that("the analytical binomial power tests the two arms at their own sizes", {
  target <- unequal_target("aprepitant")
  expected <- pwr::pwr.2p2n.test(
    h = pwr::ES.h(target$treatment_rate, target$control_rate),
    n1 = 120, n2 = 40, sig.level = 0.025, alternative = "greater"
  )$power
  expect_equal(
    analytical_power(0.025, target, "z-test", theta_0 = 0, alternative = "greater"),
    expected
  )
})

test_that("the pooled binomial power sums over each arm's own responder counts", {
  target <- unequal_target("aprepitant", n_control = 20, n_treatment = 60)
  source <- ObservedSourceData$new(case_study_config("aprepitant"))
  power <- pooled_binomial_power(0.025, target, source, "greater")
  expect_true(power > 0 && power < 1)

  # Brute force over the target responder counts.
  source_treatment <- counts_from_rate(source$treatment_rate, source$sample_size_treatment)
  source_control <- counts_from_rate(source$control_rate, source$sample_size_control)
  grid <- expand.grid(treatment = 0:60, control = 0:20)
  rate_treatment <- (source_treatment + grid$treatment) / (60 + source$sample_size_treatment)
  rate_control <- (source_control + grid$control) / (20 + source$sample_size_control)
  statistic <- (2 * asin(sqrt(rate_treatment)) - 2 * asin(sqrt(rate_control))) /
    sqrt(1 / (60 + source$sample_size_treatment) + 1 / (20 + source$sample_size_control))
  probability <- stats::dbinom(grid$treatment, 60, target$treatment_rate) *
    stats::dbinom(grid$control, 20, target$control_rate)
  expect_equal(power, sum(probability[statistic > stats::qnorm(0.975)]))
})

test_that("oc_frequentist() takes either n_per_arm or the two arm sizes", {
  src <- source_data(config = system.file("conf/case_studies/botox.yml", package = "BExTE"))
  set.seed(1)
  oc <- oc_frequentist(separate_prior(src), decision(0.975),
                       n_control = 30, n_treatment = 60, drift = 0, n_rep = 50)
  expect_equal(oc$n_control, 30)
  expect_equal(oc$n_treatment, 60)
  expect_error(
    oc_frequentist(separate_prior(src), decision(0.975), n_per_arm = 40,
                   n_control = 30, n_treatment = 60, n_rep = 10),
    "not both"
  )
  expect_error(
    oc_frequentist(separate_prior(src), decision(0.975), n_control = 30, n_rep = 10),
    "n_treatment"
  )
})

test_that("results written with a single per-arm size load with both arm sizes", {
  old <- data.frame(case_study = "botox", target_sample_size_per_arm = 91)
  new <- upgrade_target_size_columns(old)
  expect_equal(new$target_sample_size_control, 91)
  expect_equal(new$target_sample_size_treatment, 91)
  expect_false("target_sample_size_per_arm" %in% names(new))
  expect_identical(upgrade_target_size_columns(new), new)
})

test_that("the scenario grid splits each total by the allocation ratio", {
  config_dir <- testthat::test_path("fixtures", "aprepitant_mcmc_config_light", "")
  skip_if(config_dir == "/", "packaged configuration not available")
  scenarios_config <- yaml::read_yaml(paste0(config_dir, "scenarios_config.yml"))
  case_studies_config_dir <- paste0(system.file("conf/case_studies", package = "BExTE"), "/")

  balanced <- simulation_scenarios(config_dir, scenarios_config, case_studies_config_dir)
  scenarios_config$target_allocation_ratio <- 2
  unequal <- simulation_scenarios(config_dir, scenarios_config, case_studies_config_dir)

  expect_false("target_sample_size_per_arm" %in% names(unequal))
  expect_equal(balanced$target_sample_size_control, balanced$target_sample_size_treatment)
  expect_true(all(abs(unequal$target_sample_size_treatment -
                        2 * unequal$target_sample_size_control) <= 2))
  expect_true(all(unequal$target_sample_size_control +
                    unequal$target_sample_size_treatment >=
                    balanced$target_sample_size_control + balanced$target_sample_size_treatment))
})
