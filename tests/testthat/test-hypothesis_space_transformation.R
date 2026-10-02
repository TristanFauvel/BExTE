gaussian_ebpp <- function(null_space, theta_0, source_treatment_effect = 0.5) {
  prior <- list(
    source = list(treatment_effect_estimate = source_treatment_effect,
                  standard_error = 0.12),
    method_parameters = list(initial_prior = list("noninformative"),
                             power_parameter = list(0.5))
  )
  model <- Gaussian_Gravestock_EBPP$new(prior = prior,
                                        null_space = null_space,
                                        theta_0 = theta_0)
  # Model$create() assigns this after construction.
  model$prior <- prior
  model
}

test_that("hypothesis_space_transformation is repeatable for a right null space", {
  # The transformation used to negate self$parameters$theta_0 in place, so the
  # sign flipped on every call and consecutive replicates were transformed
  # differently. That is invisible while theta_0 is 0, as it is in every case
  # study configuration, but it makes the replicate loop and any vectorised
  # equivalent disagree as soon as theta_0 is not 0.
  model <- gaussian_ebpp("right", 0.2)

  first <- model$hypothesis_space_transformation(0.4)
  second <- model$hypothesis_space_transformation(0.4)

  expect_equal(second, first)
  expect_equal(model$parameters$theta_0, 0.2)
})

test_that("hypothesis_space_transformation puts the null hypothesis below 0", {
  # A left null space is translated by theta_0, a right one is mirrored as
  # well, so that in both the null is the half line below 0.
  left <- gaussian_ebpp("left", 0.2)$hypothesis_space_transformation(0.4)
  expect_equal(left$source_treatment_effect_estimate, 0.5 - 0.2)
  expect_equal(left$target_treatment_effect_estimate, 0.4 - 0.2)

  right <- gaussian_ebpp("right", 0.2)$hypothesis_space_transformation(0.4)
  expect_equal(right$source_treatment_effect_estimate, -(0.5 - 0.2))
  expect_equal(right$target_treatment_effect_estimate, -(0.4 - 0.2))
})

test_that("hypothesis_space_transformation transforms one estimate per replicate", {
  # The vectorised kernel passes every replicate's estimate at once, and each
  # must be transformed as the replicate loop transforms it on its own.
  model <- gaussian_ebpp("right", 0.2)
  estimates <- c(-0.7, 0.1, 0.4, 0.9)

  transformed <- model$hypothesis_space_transformation(estimates)

  expect_identical(
    transformed$target_treatment_effect_estimate,
    vapply(estimates, function(estimate) {
      model$hypothesis_space_transformation(estimate)$target_treatment_effect_estimate
    }, numeric(1))
  )
  expect_length(transformed$source_treatment_effect_estimate, 1)
})

test_that("the binomial p-value based power prior shares the transformation", {
  # p_value_based_PP_Binomial is not a Gaussian_empirical_Bayes_PP, and used to
  # carry its own copy of the transformation; both now inherit it from Model.
  prior <- list(
    source = list(treatment_effect_estimate = 0.5),
    method_parameters = list(initial_prior = list("noninformative"),
                             shape_parameter = list(1),
                             equivalence_margin = list(0.1))
  )
  binomial <- p_value_based_PP_Binomial$new(prior = prior, theta_0 = 0.2,
                                            null_space = "right",
                                            mcmc_config = list(
                                              num_chains = 1L, parallel_chains = 1L,
                                              tune = 1L, target_accept = 0.8,
                                              chain_length = 1L, target_ess = 1L,
                                              rhat_threshold = 1.1,
                                              max_divergence_rate = 0.01
                                            ))
  binomial$prior <- prior

  expect_identical(
    binomial$hypothesis_space_transformation(c(0.1, 0.4)),
    gaussian_ebpp("right", 0.2)$hypothesis_space_transformation(c(0.1, 0.4))
  )
})

test_that("hypothesis_space_transformation rejects an unknown null space", {
  expect_error(
    gaussian_ebpp("both", 0)$hypothesis_space_transformation(0.4),
    "null_space must be either 'left' or 'right'"
  )
})
