# The quadrature engine replaces Stan for the binomial borrowing models, so the
# two must describe the same posterior. Each comparison fits one dataset with a
# long Stan run and requires the quadrature mean and 2.5% and 97.5% quantiles to
# lie within four Monte Carlo standard errors of the Stan estimates.
#
# The Egidi variant of the robust mixture prior and the p-value-based power
# prior only choose the mixture weight or the power parameter from the data;
# their posterior is computed by the code compared here.
#
# Sampling means compiling and running the Stan programs, so the tests are
# skipped wherever CmdStan is unavailable, as it is in CI.

skip_without_cmdstan <- function() {
  testthat::skip_if_not(
    !inherits(try(cmdstanr::cmdstan_path(), silent = TRUE), "try-error"),
    "CmdStan is not installed"
  )
}

agreement_mcmc_config <- function(engine) {
  list(
    num_chains = 4L,
    parallel_chains = 1L,
    tune = 1000L,
    target_accept = 0.8,
    chain_length = 25000L,
    max_chain_length = 25000L,
    target_ess = 10L,
    rhat_threshold = 1.1,
    max_divergence_rate = 0.01,
    engine = engine
  )
}

agreement_target_data <- function(successes_control, successes_treatment, n) {
  control_rate <- successes_control / n
  treatment_rate <- successes_treatment / n
  list(
    summary_measure_likelihood = "binomial",
    sample_size_per_arm = n,
    sample_size_control = n,
    sample_size_treatment = n,
    sample = data.frame(
      sample_control_rate = control_rate,
      sample_treatment_rate = treatment_rate,
      treatment_effect_estimate = treatment_rate - control_rate,
      treatment_effect_standard_error = sqrt(
        treatment_rate * (1 - treatment_rate) / n +
          control_rate * (1 - control_rate) / n
      ),
      standard_deviation = sqrt(
        treatment_rate * (1 - treatment_rate) + control_rate * (1 - control_rate)
      )
    )
  )
}

# Fits the Stan model of `stan_model` on the data its prepare_data() builds, and
# compares the draws with the quadrature posterior of `quadrature_model`.
expect_quadrature_matches_stan <- function(stan_model, quadrature_model, target_data) {
  stan_model$draws_dir <- tempdir()
  fit <- stan_model$stan_model$sample(
    data = stan_model$prepare_data(target_data),
    chains = 4,
    parallel_chains = 1,
    iter_warmup = 1000,
    iter_sampling = 25000,
    seed = 20260930,
    refresh = 0,
    show_messages = FALSE
  )
  draws <- posterior::extract_variable_matrix(fit$draws("target_treatment_effect"),
                                              "target_treatment_effect")

  quadrature_model$inference(target_data)
  quadrature <- c(
    mean = quadrature_model$post_mean,
    quadrature_model$credible_interval(level = 0.95)
  )
  sampled <- c(
    mean = mean(draws),
    stats::quantile(draws, c(0.025, 0.975), names = FALSE)
  )
  mcse <- c(
    posterior::mcse_mean(draws),
    posterior::mcse_quantile(draws, probs = 0.025),
    posterior::mcse_quantile(draws, probs = 0.975)
  )

  expect_true(
    all(abs(quadrature - sampled) < 4 * mcse),
    info = paste0(
      "quadrature ", paste(signif(quadrature, 5), collapse = ", "),
      "; Stan ", paste(signif(sampled, 5), collapse = ", "),
      "; MCSE ", paste(signif(mcse, 2), collapse = ", ")
    )
  )
}


test_that("the robust mixture prior quadrature agrees with Stan", {
  skip_without_cmdstan()

  prior <- list(
    source = list(
      treatment_effect_estimate = 0.078,
      standard_error = 0.041,
      equivalent_source_sample_size_per_arm = 286
    ),
    vague_mean = 0,
    method_parameters = list(
      prior_weight = list(0.5),
      initial_prior = list("noninformative"),
      empirical_bayes = list(TRUE)
    )
  )
  build <- function(engine) {
    model <- TruncatedGaussianRMP$new(prior = prior, mcmc_config = agreement_mcmc_config(engine))
    model$prior <- prior
    model
  }

  # One dataset consistent with the source, one in conflict with it.
  for (counts in list(c(80, 92), c(80, 70))) {
    target_data <- agreement_target_data(counts[[1]], counts[[2]], n = 143)
    stan <- build("stan")
    # The empirical Bayes vague component must be set before prepare_data().
    stan$empirical_bayes_update(target_data)
    expect_quadrature_matches_stan(stan, build("quadrature"), target_data)
  }
})


test_that("the conditional power prior quadrature agrees with Stan", {
  skip_without_cmdstan()

  for (gamma in c(0.5, 1)) {
    prior <- list(
      source = list(
        treatment_effect_estimate = 184 / 293 - 154 / 280,
        standard_error = 0.041,
        sample_size_control = 280,
        sample_size_treatment = 293,
        control_rate = 154 / 280,
        treatment_rate = 184 / 293
      ),
      method_parameters = list(
        power_parameter = list(gamma),
        initial_prior = list("noninformative")
      )
    )
    build <- function(engine) {
      model <- BinomialCPP$new(prior = prior, mcmc_config = agreement_mcmc_config(engine))
      model$prior <- prior
      model
    }

    expect_quadrature_matches_stan(
      build("stan"), build("quadrature"),
      agreement_target_data(40, 52, n = 71)
    )
  }
})
