# The calibrated power prior (PDCCPP) for a binary endpoint: the power
# parameter rule of PDCCPP, the binomial conditional power prior analysis, and
# the calibration on the exact type I error of that analysis.

pdccpp_source <- list(estimate = 184 / 293 - 154 / 280,
                      se = sqrt(184 / 293 * (1 - 184 / 293) / 293 + 154 / 280 * (1 - 154 / 280) / 280))

# Callers point BEXTE_CACHE_DIR at a temporary directory first.
small_null_table <- function() {
  pdccpp_binomial_null_table(280L, 154L, 293L, 184L, 20L, 20L, control_rate = 0.55,
                             theta_0 = 0, null_space = "left", critical_value = 0.975,
                             n_lattice = 300L)
}


test_that("the power parameter rule is equation (9) of Nikolakopoulos et al.", {
  # PDCCPP writes it with tau2 / n0 = SE_S^2 and tau2 / n = SE_T^2.
  set.seed(1)
  target <- stats::rnorm(50, 0.05, 0.15)
  target_se <- stats::runif(50, 0.03, 0.1)
  z <- 1.3
  expected <- ifelse(
    abs(target - pdccpp_source$estimate) > z * sqrt(pdccpp_source$se^2 + target_se^2),
    pdccpp_source$se^2 / (((target - pdccpp_source$estimate) / z)^2 - target_se^2),
    1
  )
  expect_equal(
    pdccpp_power_parameter(target, target_se, pdccpp_source$estimate, pdccpp_source$se, z),
    expected
  )
  # A target standard error of zero, as when both arms are all or none,
  # discounts rather than failing.
  expect_true(is.finite(pdccpp_power_parameter(-0.5, 0, pdccpp_source$estimate, pdccpp_source$se, z)))
})

test_that("the null table reproduces the analysis' decisions", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  table <- small_null_table()
  arm <- function(rate) seq.int(stats::qbinom(1e-10 / 4, 20, rate),
                                stats::qbinom(1e-10 / 4, 20, rate, lower.tail = FALSE))
  grid <- expand.grid(control = arm(0.55), treatment = arm(0.55))
  expect_equal(nrow(grid), length(table$weight))
  expect_equal(sum(table$weight), 1)

  set.seed(2)
  for (index in sample(nrow(grid), 15)) {
    for (gamma in c(0.1, 0.5, 0.9)) {
      posterior <- binomial_power_prior_posterior(gamma, 280, 154, 293, 184, 20,
                                                  grid$control[index], 20, grid$treatment[index],
                                                  n_lattice = 300L)
      direct <- 1 - grid_posterior_cdf(posterior, 0) > 0.975
      from_table <- xor(table$reject_at_zero[index], sum(table$crossings[[index]] < gamma) %% 2 == 1)
      expect_identical(from_table, direct)
    }
  }
})

test_that("the calibration is the largest parameter within the desired type I error", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  table <- small_null_table()
  calibration <- pdccpp_binomial_calibrate(table, 0.065, pdccpp_source$estimate, pdccpp_source$se)
  z <- calibration$calibration_parameter
  expect_lte(calibration$type_I_error, 0.065)
  expect_equal(
    calibration$type_I_error,
    pdccpp_binomial_type_I_error(table, z, pdccpp_source$estimate, pdccpp_source$se)
  )
  if (z < 1e3) {
    expect_gt(pdccpp_binomial_type_I_error(table, z * (1 + 1e-8), pdccpp_source$estimate,
                                           pdccpp_source$se), 0.065)
  }
})

test_that("the null table is read back from the cache", {
  directory <- withr::local_tempdir()
  withr::local_envvar(BEXTE_CACHE_DIR = directory)
  first <- pdccpp_binomial_null_table(280L, 154L, 293L, 184L, 10L, 10L, control_rate = 0.55,
                                      theta_0 = 0, null_space = "left", critical_value = 0.975,
                                      n_lattice = 200L)
  expect_length(list.files(directory, pattern = "\\.rds$", recursive = TRUE), 1)
  second <- pdccpp_binomial_null_table(280L, 154L, 293L, 184L, 10L, 10L, control_rate = 0.55,
                                       theta_0 = 0, null_space = "left", critical_value = 0.975,
                                       n_lattice = 200L)
  expect_identical(first, second)
})

test_that("a binary PDCCPP is built as BinomialPDCCPP", {
  model <- Model$new()$create(
    case_study_config = list(summary_measure_likelihood = "binomial", null_space = "left",
                             theta_0 = 0, name = "example"),
    method = "PDCCPP",
    method_parameters = list(initial_prior = list("noninformative"), desired_tie = list(0.065),
                             significance_level = list(0.05), tolerance = list(1e-4)),
    source_data = list(sample_size_control = 280, sample_size_treatment = 293,
                       control_rate = 154 / 280, treatment_rate = 184 / 293,
                       treatment_effect_estimate = pdccpp_source$estimate,
                       standard_error = pdccpp_source$se, equivalent_source_sample_size_per_arm = 286),
    mcmc_config = list(num_chains = 1L, parallel_chains = 1L, tune = 1L, target_accept = 0.8,
                       chain_length = 1L, target_ess = 1L, rhat_threshold = 1.1,
                       max_divergence_rate = 0.01)
  )
  expect_s3_class(model, "BinomialPDCCPP")
  expect_error(model$ensure_calibrated(), "no design to calibrate against")
})
