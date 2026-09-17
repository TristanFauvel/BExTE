## For the binary endpoint the target statistic is the pair of responder counts,
## whose sample space is finite, so the conflict p-value is an exact sum over
## cells rather than an integral. Section 7 is explicit that no other conflict
## statistic may be substituted, so these tests check that the tables really are
## the joint prior predictive of the model the analysis uses - the truncated
## normal mixture on the rate difference the RMP's Stan program encodes - and not
## some more convenient approximation to it.
##
## Nothing here samples: the sampler and the compiler are stubbed.

egidi_binomial_prior <- function() {
  list(
    source = list(
      treatment_effect_estimate = 0.1315456,
      standard_error = 0.03505291,
      equivalent_source_sample_size_per_arm = 286
    ),
    vague_mean = 0,
    method_parameters = egidi_method_parameters()
  )
}

egidi_binomial_mcmc_config <- function() {
  list(
    num_chains = 4L, parallel_chains = 1L, tune = 1000L, target_accept = 0.8,
    chain_length = 500L, max_chain_length = 10000L, target_ess = 10L,
    rhat_threshold = 1.1, max_divergence_rate = 0.01
  )
}

## Rates that are exact binary fractions of their arm sizes, so the counts do
## not depend on how the product rounds.
egidi_binomial_target_data <- function(sample_treatment_rate = 0.875,
                                       sample_control_rate = 0.75,
                                       standard_error = 0.0777) {
  list(
    sample_size_treatment = 56L,
    sample_size_control = 52L,
    sample_size_per_arm = 54L,
    sample = list(
      sample_treatment_rate = sample_treatment_rate,
      sample_control_rate = sample_control_rate,
      treatment_effect_estimate = sample_treatment_rate - sample_control_rate,
      treatment_effect_standard_error = standard_error
    )
  )
}

egidi_binomial_model <- function() {
  testthat::with_mocked_bindings(
    TruncatedEgidiMixture$new(
      prior = egidi_binomial_prior(),
      mcmc_config = egidi_binomial_mcmc_config()
    ),
    compile_stan_model = function(...) NULL,
    .package = "BExTE"
  )
}


test_that("a component's prior-predictive table is a probability distribution", {
  table <- egidi_binomial_predictive_table(0.1315456, 0.03505291, 52, 55)

  expect_equal(dim(table), c(53L, 56L))
  expect_true(all(table >= 0))
  ## The sample space is enumerated, so the table must exhaust it. Simpson's
  ## rule on the two nuisance integrals is what limits the agreement.
  expect_equal(sum(table), 1, tolerance = 1e-8)
})

test_that("the tables reproduce the existing truncated-mixture quadrature", {
  ## truncated_normal_mixture_binomial_weights() already computes the component
  ## marginal likelihoods of exactly this model, for one cell, by a different
  ## arrangement of the same two integrals: it convolves along the grid, these
  ## tables form a bilinear product. Agreement is the strongest available check
  ## that the tables describe the analysis model rather than a near neighbour.
  informative_mean <- 0.1315456
  informative_sd <- 0.03505291
  weak_mean <- 0
  weak_sd <- 0.6
  n_control <- 52L
  n_treatment <- 55L

  n_nodes <- egidi_binomial_nodes(c(informative_sd, weak_sd), n_control, n_treatment)
  informative <- egidi_binomial_predictive_table(
    informative_mean, informative_sd, n_control, n_treatment, n_nodes = n_nodes
  )
  weak <- egidi_binomial_predictive_table(
    weak_mean, weak_sd, n_control, n_treatment, n_nodes = n_nodes
  )

  for (cell in list(c(42, 48), c(10, 12), c(30, 50), c(0, 0), c(52, 55))) {
    for (w in c(0.1, 0.5, 0.9)) {
      existing <- truncated_normal_mixture_binomial_weights(
        weights = c(w, 1 - w),
        means = c(informative_mean, weak_mean),
        sds = c(informative_sd, weak_sd),
        n_control = n_control, n_successes_control = cell[1],
        n_treatment = n_treatment, n_successes_treatment = cell[2]
      )[1]
      from_tables <- w * informative[cell[1] + 1, cell[2] + 1] /
        (w * informative[cell[1] + 1, cell[2] + 1] +
           (1 - w) * weak[cell[1] + 1, cell[2] + 1])
      expect_equal(from_tables, existing, tolerance = 1e-10,
                   info = paste(cell[1], cell[2], w))
    }
  }
})

test_that("a table cell matches nested adaptive integration", {
  ## An independent reference for one cell, built the way the existing
  ## quadrature test builds its own: nested stats::integrate over the control
  ## rate and the treatment rate, with the component truncated to the range the
  ## control rate leaves the treatment effect.
  mu <- 0.1
  sd <- 0.25
  n_control <- 8L
  n_treatment <- 7L
  table <- egidi_binomial_predictive_table(mu, sd, n_control, n_treatment)

  reference_cell <- function(y_control, y_treatment) {
    stats::integrate(function(control_rate) {
      vapply(control_rate, function(rate) {
        normaliser <- stats::pnorm(1 - rate, mu, sd) - stats::pnorm(-rate, mu, sd)
        inner <- stats::integrate(function(treatment_rate) {
          stats::dbinom(y_treatment, n_treatment, treatment_rate) *
            stats::dnorm(treatment_rate - rate, mu, sd)
        }, lower = 0, upper = 1, rel.tol = 1e-12, subdivisions = 1000L)$value
        stats::dbinom(y_control, n_control, rate) * inner / normaliser
      }, numeric(1))
    }, lower = 0, upper = 1, rel.tol = 1e-12, subdivisions = 1000L)$value
  }

  for (cell in list(c(3, 4), c(0, 2), c(8, 7))) {
    expect_equal(table[cell[1] + 1, cell[2] + 1],
                 reference_cell(cell[1], cell[2]),
                 tolerance = 1e-6, info = paste(cell, collapse = ","))
  }
})

test_that("the discrete conflict p-value sums the right cells", {
  informative <- egidi_binomial_predictive_table(0.13, 0.035, 20, 20)
  weak <- egidi_binomial_predictive_table(0, 0.6, 20, 20)
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
  informative <- egidi_binomial_predictive_table(0.13, 0.035, 20, 20)
  weak <- egidi_binomial_predictive_table(0, 0.6, 20, 20)

  modal <- which(((1 - 0) * informative) == max(informative), arr.ind = TRUE)[1, ]
  agreeing <- egidi_select_weak_weight_binomial(
    informative, weak, modal[1] - 1L, modal[2] - 1L
  )
  expect_equal(agreeing$psi_weak, 0)
  expect_false(agreeing$initial_conflict)

  ## Every responder in the control arm and none in the treatment arm is as far
  ## from the source as this sample space reaches.
  extreme <- egidi_select_weak_weight_binomial(informative, weak, 20L, 0L)
  expect_true(extreme$initial_conflict)
  expect_equal(extreme$psi_weak, 1)
  expect_true(extreme$conflict_unresolved)
})

test_that("the binomial model hands the RMP 1 - psi and reports the selection", {
  model <- egidi_binomial_model()
  target_data <- egidi_binomial_target_data()

  model$empirical_bayes_update(target_data)

  expect_false(is.na(model$w))
  expect_equal(model$w, 1 - model$selection$psi_weak, tolerance = 1e-12)
  expect_true(model$w >= 0 && model$w <= 1)
  ## The weak component is the RMP's empirical Bayes one, re-derived per replicate.
  expect_equal(model$vague_prior_variance,
               target_data$sample$treatment_effect_standard_error^2 *
                 target_data$sample_size_per_arm,
               tolerance = 1e-12)
})

test_that("the weak component's table is cached across replicates", {
  ## The weak scale is re-derived from every replicate, so an uncached table
  ## would be rebuilt thousands of times per scenario. Rounding the scale to a
  ## fraction of a percent cannot move the selected weight, and the test pins
  ## that it does not: the same weight comes out with the cache disabled.
  model <- egidi_binomial_model()
  exact <- egidi_binomial_model()
  exact$table_scale_tolerance <- 0

  for (rate in c(0.875, 0.8750001)) {
    model$empirical_bayes_update(egidi_binomial_target_data(sample_treatment_rate = rate))
    exact$empirical_bayes_update(egidi_binomial_target_data(sample_treatment_rate = rate))
    expect_equal(model$selection$psi_weak, exact$selection$psi_weak,
                 tolerance = 1e-12, info = format(rate))
  }
})
