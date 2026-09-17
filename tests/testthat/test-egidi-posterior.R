## Once the weight is selected, the analysis is the robust mixture prior's. These
## tests pin the seam between the two: that the weight handed over is the one the
## RMP expects, that the ends of the weight range reproduce the single-component
## analyses, and that the posterior component probability is the marginal
## likelihood ratio rather than the selected weight repeated.

test_that("the robust mixture prior receives 1 - psi, not psi", {
  ## The RMP parameterises its mixture by the weight on the *informative*
  ## component while Egidi parameterises his by the weight on the weak one, so
  ## the conversion is the one place the two conventions meet. Passing psi
  ## straight through would still produce a valid mixture and plausible numbers,
  ## which is why this is checked against the RMP run at the matching weight
  ## rather than by reading the code.
  fixture <- egidi_fixture(treatment_drift = -0.6, n_replicates = 60)
  prior <- fixture$model$vectorised_prior_components(
    fixture$target_data, fixture$samples
  )
  psi <- fixture$model$selection$psi_weak

  expect_equal(prior$weights[, 1], 1 - psi, tolerance = 1e-12)
  expect_equal(prior$weights[, 2], psi, tolerance = 1e-12)
  expect_true(all(prior$means[, 1] == fixture$model$info_prior_mean))
  expect_true(all(prior$means[, 2] == fixture$model$vague_prior_mean))
  ## The weight moved off zero here, so passing psi instead of 1 - psi would
  ## give a different prior and this comparison would have something to catch.
  expect_gt(max(psi), 0.01)

  ## The same replicates through the RMP, at the weight Egidi chose for each.
  rmp <- egidi_fixture(
    method = "RMP",
    method_parameters = list(
      initial_prior = list("noninformative"),
      prior_weight = list(0.5),
      empirical_bayes = list(TRUE)
    ),
    treatment_drift = -0.6, n_replicates = 60
  )
  rmp_prior <- rmp$model$vectorised_prior_components(rmp$target_data, rmp$samples)
  rmp_prior$weights <- cbind(1 - psi, psi)

  egidi_posterior <- normal_mixture_posterior(
    prior$weights, prior$means, prior$sds,
    fixture$samples$treatment_effect_estimate,
    fixture$samples$treatment_effect_standard_error
  )
  rmp_posterior <- normal_mixture_posterior(
    rmp_prior$weights, rmp_prior$means, rmp_prior$sds,
    rmp$samples$treatment_effect_estimate,
    rmp$samples$treatment_effect_standard_error
  )
  ## unname() only because cbind() names a column after the local variable.
  expect_equal(unname(egidi_posterior$weights), unname(rmp_posterior$weights),
               tolerance = 1e-12)
  expect_equal(unname(egidi_posterior$means), unname(rmp_posterior$means),
               tolerance = 1e-12)
})

test_that("psi = 0 reproduces the informative-prior-only analysis", {
  informative <- list(mean = 0.5, sd = 0.12)
  weak <- list(mean = 0, sd = 4)
  ## A statistic right at the informative centre: no conflict, so psi is zero.
  fit <- fit_egidi_mixture(0.5, 0.2, informative, weak)
  expect_equal(fit$psi_weak, 0)

  precision <- 1 / 0.2^2 + 1 / informative$sd^2
  expect_equal(fit$posterior_mean,
               (0.5 / 0.2^2 + informative$mean / informative$sd^2) / precision,
               tolerance = 1e-10)
  expect_equal(fit$posterior_sd, sqrt(1 / precision), tolerance = 1e-10)
  expect_equal(fit$w_informative_posterior, 1, tolerance = 1e-12)
})

test_that("psi = 1 reproduces the weak-prior-only analysis", {
  informative <- list(mean = 0.5, sd = 0.02)
  weak <- list(mean = 0, sd = 0.05)
  ## Far enough out that even the weak component cannot predict it, so the rule
  ## returns one and flags the conflict rather than resolving it.
  fit <- fit_egidi_mixture(8, 0.2, informative, weak)
  expect_equal(fit$psi_weak, 1)
  expect_true(fit$conflict_unresolved)

  precision <- 1 / 0.2^2 + 1 / weak$sd^2
  expect_equal(fit$posterior_mean,
               (8 / 0.2^2 + weak$mean / weak$sd^2) / precision,
               tolerance = 1e-10)
  expect_equal(fit$posterior_sd, sqrt(1 / precision), tolerance = 1e-10)
  expect_equal(fit$w_informative_posterior, 0, tolerance = 1e-12)
})

test_that("the posterior component weight matches numerical integration", {
  ## The selected prior weight and the posterior component probability are
  ## different quantities, and the second is the first reweighted by the
  ## component marginal likelihoods. Those are integrals, so they are checked as
  ## integrals rather than against the closed form they were derived from.
  informative <- list(mean = 0.5, sd = 0.12)
  weak <- list(mean = 0, sd = 3.5)
  estimate <- -0.35
  standard_error <- 0.3

  fit <- fit_egidi_mixture(estimate, standard_error, informative, weak)

  marginal <- function(component) {
    stats::integrate(
      function(theta) {
        stats::dnorm(estimate, theta, standard_error) *
          stats::dnorm(theta, component$mean, component$sd)
      },
      lower = component$mean - 40 * component$sd,
      upper = component$mean + 40 * component$sd,
      rel.tol = 1e-12, subdivisions = 2000L
    )$value
  }

  informative_mass <- (1 - fit$psi_weak) * marginal(informative)
  weak_mass <- fit$psi_weak * marginal(weak)

  expect_equal(fit$w_informative_posterior,
               informative_mass / (informative_mass + weak_mass),
               tolerance = 1e-8)
  expect_equal(fit$psi_weak_posterior,
               weak_mass / (informative_mass + weak_mass),
               tolerance = 1e-8)
  ## The point of reporting both: they are not the same number.
  expect_gt(abs(fit$psi_weak_posterior - fit$psi_weak), 0.05)
})

test_that("the scalar and vectorised paths select the same weights", {
  ## The simulation runs the vectorised path; the case study analyses and the
  ## MCMC endpoints run the scalar one. They must not disagree about the prior.
  fixture <- egidi_fixture(treatment_drift = -0.5, n_replicates = 25)
  vectorised <- fixture$model$vectorised_prior_components(
    fixture$target_data, fixture$samples
  )
  vectorised_psi <- fixture$model$selection$psi_weak

  scalar_psi <- vapply(seq_len(nrow(fixture$samples)), function(i) {
    replicate_data <- fixture$target_data$clone()
    replicate_data$sample <- fixture$samples[i, ]
    model <- egidi_fixture(n_replicates = 1)$model
    model$empirical_bayes_update(replicate_data)
    model$selection$psi_weak
  }, numeric(1))

  expect_equal(scalar_psi, vectorised_psi, tolerance = 1e-12)
  expect_equal(1 - vectorised_psi, vectorised$weights[, 1], tolerance = 1e-12)
})

test_that("adding the method leaves the other methods' reporting unchanged", {
  ## The only shared code this method needed was an opt-in quantile summary on
  ## the base model. Every other method leaves it empty, so their reported
  ## posterior parameters are exactly what they were.
  rmp <- egidi_fixture(
    method = "RMP",
    method_parameters = list(
      initial_prior = list("noninformative"),
      prior_weight = list(0.5),
      empirical_bayes = list(TRUE)
    ),
    n_replicates = 40
  )
  expect_length(rmp$model$quantile_summary_columns, 0)

  set.seed(4)
  results <- rmp$model$estimate_frequentist_operating_characteristics(
    target_data = rmp$target_data, n_replicates = 40, critical_value = 0.975,
    theta_0 = 0, confidence_level = 0.95, null_space = "left",
    n_samples_quantiles_estimation = 100, case_study = "unit_test",
    method = "RMP"
  )
  expect_setequal(
    names(results$posterior_parameters),
    c("prior_weight", "conf_int_lower_prior_weight", "conf_int_upper_prior_weight")
  )

  ## And the method that does ask for them gets them.
  expect_equal(
    egidi_fixture(n_replicates = 1)$model$quantile_summary_columns,
    "psi_weak"
  )
})
