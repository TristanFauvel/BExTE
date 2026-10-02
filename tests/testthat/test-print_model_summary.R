# Every model prints a summary: the moments shared by all models, then the
# entries of posterior_parameters, then whatever the method adds. Only the
# Gaussian RMP classes used to have one.

summary_attributes <- function(model) {
  model$summary_rows()$Attribute
}

gaussian_target <- function(estimate = 0.3, standard_error = 0.15) {
  list(sample_size_per_arm = 50,
       sample = data.frame(treatment_effect_estimate = estimate,
                           treatment_effect_standard_error = standard_error))
}

test_that("quantities the model has not set get no row", {
  model <- Model$new()
  expect_equal(nrow(model$summary_rows()), 0)

  model$method <- "test"
  model$post_mean <- c(mean = 0.25)
  model$posterior_parameters <- list(prior_weight = 0.4,
                                     per_replicate = c(0.1, 0.2))

  rows <- model$summary_rows()
  expect_equal(rows$Attribute,
               c("Method", "Posterior Mean", "Posterior prior weight"))
  expect_equal(rows$Value[1], "test")
  expect_equal(as.numeric(rows$Value[2]), 0.25)
})

test_that("print_model_summary prints the rows and returns them invisibly", {
  model <- Model$new()
  model$post_mean <- 0.25

  expect_output(returned <- withVisible(model$print_model_summary()),
                "Posterior Mean")
  expect_false(returned$visible)
  expect_equal(returned$value, model$summary_rows())
})

test_that("the Gaussian RMP still shows its mixture components", {
  prior <- list(
    source = list(treatment_effect_estimate = 0.5, standard_error = 0.12,
                  equivalent_source_sample_size_per_arm = 100),
    vague_mean = 0,
    method_parameters = list(initial_prior = list("noninformative"),
                             prior_weight = list(0.5),
                             empirical_bayes = list(FALSE))
  )
  model <- GaussianRMP_RBesT$new(prior = prior)
  target_data <- gaussian_target()
  # RBesT takes its reference scale from the sample standard deviation.
  target_data$sample$standard_deviation <- 0.15 * sqrt(50)
  model$inference(target_data)

  expect_contains(summary_attributes(model), c(
    "Posterior Mean", "Posterior Variance", "Prior Weight",
    "Posterior prior weight", "Vague Posterior Mean", "Vague Posterior Variance",
    "Informative Posterior Mean", "Informative Posterior Variance"
  ))
  expect_output(model$print_model_summary(), "Informative Posterior Variance")
})

test_that("static borrowing shows its power parameter", {
  prior <- list(
    source = list(treatment_effect_estimate = 0.5, standard_error = 0.12),
    method_parameters = list(initial_prior = list("noninformative"),
                             power_parameter = list(0.5))
  )
  model <- StaticBorrowingGaussian$new(prior = prior)
  model$inference(gaussian_target())

  rows <- model$summary_rows()
  expect_contains(rows$Attribute, c("Prior Variance", "Posterior Mean",
                                    "Power Parameter"))
  expect_equal(as.numeric(rows$Value[rows$Attribute == "Power Parameter"]), 0.5)
})

test_that("the binary RMP shows its prior weight", {
  withr::local_envvar(BEXTE_CACHE_DIR = withr::local_tempdir())
  prior <- list(
    source = list(sample_size_control = 280, sample_size_treatment = 293,
                  control_rate = 154 / 280, treatment_rate = 184 / 293,
                  treatment_effect_estimate = 184 / 293 - 154 / 280,
                  standard_error = 0.041,
                  equivalent_source_sample_size_per_arm = 286),
    method_parameters = list(initial_prior = list("noninformative"),
                             prior_weight = list(0.5),
                             empirical_bayes = list(FALSE))
  )
  mcmc_config <- list(num_chains = 1L, parallel_chains = 1L, tune = 1L,
                      target_accept = 0.8, chain_length = 1L, target_ess = 1L,
                      rhat_threshold = 1.1, max_divergence_rate = 0.01)
  model <- BinomialRMP$new(prior = prior, mcmc_config = mcmc_config)

  expect_contains(summary_attributes(model), c("Method", "Prior Weight"))
})

test_that("test-then-pool shows its pooling decision", {
  prior <- list(
    source = list(treatment_effect_estimate = 0.5, standard_error = 0.12,
                  summary_measure_likelihood = "normal",
                  equivalent_source_sample_size_per_arm = 100),
    method_parameters = list(initial_prior = list("noninformative"),
                             significance_level = list(0.05))
  )
  model <- TestThenPoolDifference$new(prior = prior)
  model$prior <- prior
  model$inference(list(
    sample_size_per_arm = 50, summary_measure_likelihood = "normal",
    sample = data.frame(treatment_effect_estimate = 0.4,
                        treatment_effect_standard_error = 0.2,
                        sample_size_per_arm = 50, standard_deviation = 1.4)
  ))

  rows <- model$summary_rows()
  expect_equal(rows$Value[rows$Attribute == "Posterior pool"], "TRUE")
})
