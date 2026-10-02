# The block and cache rewrite of the binomial power prior on the lattice
# (R/binomial_lattice_fast.R) against the original implementation, which
# helper-binomial-reference.R keeps. The rewrite only reorders the sums, so
# posteriors agree to rounding and decisions are identical.

aprepitant_source <- c(280, 154, 293, 184)

lattice_fast_cases <- list(
  agreement = list(gamma = 0.4, source = aprepitant_source, target = c(71, 39, 71, 33)),
  strong_conflict = list(gamma = 1, source = aprepitant_source, target = c(143, 79, 143, 0)),
  extreme_conflict = list(gamma = 1, source = aprepitant_source, target = c(286, 10, 286, 280)),
  gamma_near_zero = list(gamma = 1e-12, source = aprepitant_source, target = c(47, 20, 47, 30)),
  gamma_zero = list(gamma = 0, source = aprepitant_source, target = c(47, 20, 47, 30)),
  gamma_near_one = list(gamma = 0.999, source = aprepitant_source, target = c(286, 150, 286, 160)),
  small_samples = list(gamma = 0.5, source = c(12, 7, 12, 9), target = c(10, 4, 10, 2)),
  boundary_counts = list(gamma = 0.7, source = aprepitant_source, target = c(286, 0, 286, 286)),
  all_responders = list(gamma = 0.3, source = aprepitant_source, target = c(30, 30, 30, 0)),
  no_target = list(gamma = 0.05, source = aprepitant_source, target = c(0, 0, 0, 0))
)

# Posterior summaries of a grid posterior, including the probability of
# benefit the test decides on.
lattice_fast_summaries <- function(posterior, theta_0 = 0) {
  c(mean = posterior$mean, variance = posterior$variance,
    median = grid_posterior_quantile(posterior, 0.5),
    benefit = 1 - grid_posterior_cdf(posterior, theta_0),
    lower = grid_posterior_quantile(posterior, 0.025),
    upper = grid_posterior_quantile(posterior, 0.975))
}

expect_same_posterior <- function(new, reference) {
  expect_identical(new$grid, reference$grid)
  expect_lt(max(abs(new$cdf - reference$cdf)), 1e-10)
  expect_lt(max(abs(lattice_fast_summaries(new) - lattice_fast_summaries(reference))), 1e-10)
}

# Every route binomial_power_prior_posterior() can take: computed directly,
# read off a kernel cached for its power parameter, and read off the target
# terms.
lattice_fast_modes <- list(
  direct = list(BExTE.power_prior_kernels = 0L, BExTE.target_terms_cache = 0L),
  kernel = list(BExTE.power_prior_kernels = 4L, BExTE.target_terms_cache = 0L),
  terms = list(BExTE.power_prior_kernels = 0L, BExTE.target_terms_cache = 4L)
)


test_that("the power prior posterior is the original one on every route", {
  for (case_name in names(lattice_fast_cases)) {
    case <- lattice_fast_cases[[case_name]]
    arguments <- c(list(case$gamma), as.list(case$source), as.list(case$target))
    reference <- do.call(reference_binomial_power_prior_posterior, arguments)
    for (mode in names(lattice_fast_modes)) {
      withr::local_options(lattice_fast_modes[[mode]])
      binomial_power_prior_kernel_reset()
      # The kernel is computed on the third call and read on the fourth.
      for (call in 1:4) {
        new <- do.call(binomial_power_prior_posterior, arguments)
        expect_same_posterior(new, reference)
      }
    }
  }
  binomial_power_prior_kernel_reset()
})

test_that("power parameters that round every likelihood to one share a kernel", {
  withr::local_options(BExTE.power_prior_kernels = 4L, BExTE.target_terms_cache = 0L)
  binomial_power_prior_kernel_reset()
  for (gamma in c(0, 1e-22, 1e-30)) {
    binomial_power_prior_posterior(gamma, 280, 154, 293, 184, 47, 20, 47, 30)
  }
  expect_length(binomial_power_prior_kernel_store$entries, 1)
  # A power parameter that does not round them all to one has its own.
  for (successes in 20:22) {
    binomial_power_prior_posterior(1e-10, 280, 154, 293, 184, 47, successes, 47, 30)
  }
  expect_length(binomial_power_prior_kernel_store$entries, 2)
  binomial_power_prior_kernel_reset()
})

test_that("the kernel store keeps the most recently used kernels only", {
  withr::local_options(BExTE.power_prior_kernels = 2L)
  binomial_power_prior_kernel_reset()
  for (gamma in rep(c(0.2, 0.4, 0.6), each = 3)) {
    binomial_power_prior_posterior(gamma, 12, 7, 12, 9, 10, 4, 10, 2, n_lattice = 200L)
  }
  expect_length(binomial_power_prior_kernel_store$entries, 2)
  binomial_power_prior_kernel_reset()
})

test_that("a power parameter met only twice gets no kernel", {
  # Mirrored datasets, (x_c, x_t) and (n - x_t, n - x_c), have the same
  # estimate and standard error, so the PDCCPP and the p-value-based power
  # prior give them the same power parameter; computing its kernel for two
  # datasets costs more than analysing them directly.
  withr::local_options(BExTE.power_prior_kernels = 4L)
  binomial_power_prior_kernel_reset()
  binomial_power_prior_posterior(0.37, 280, 154, 293, 184, 47, 20, 47, 30)
  binomial_power_prior_posterior(0.37, 280, 154, 293, 184, 47, 17, 47, 27)
  expect_length(binomial_power_prior_kernel_store$entries, 0)
  binomial_power_prior_posterior(0.37, 280, 154, 293, 184, 47, 25, 47, 25)
  expect_length(binomial_power_prior_kernel_store$entries, 1)
  binomial_power_prior_kernel_reset()
})

test_that("the posterior given a control rate is the original one", {
  for (rate in c(0.002, 0.4, 0.9995)) {
    expect_same_posterior(
      binomial_power_prior_posterior(0.6, 280, 154, 293, 184, 0, 0, 0, 0, control_rate = rate),
      reference_binomial_power_prior_posterior(0.6, 280, 154, 293, 184, 0, 0, 0, 0,
                                               control_rate = rate)
    )
  }
})

test_that("the empirical Bayes power prior terms are the original ones", {
  cases <- list(c(aprepitant_source, 71, 39, 71, 33), c(aprepitant_source, 143, 79, 143, 0),
                c(aprepitant_source, 47, 20, 47, 30), c(12, 7, 12, 9, 10, 4, 10, 2),
                c(aprepitant_source, 286, 10, 286, 280),
                # Non-integer counts, as the KL-calibrated NPP passes.
                c(aprepitant_source, 71, 71 * 0.3, 71, 71 * 0.45))
  # The kernel store plays no part in the target terms.
  for (mode in c("direct", "terms")) {
    withr::local_options(lattice_fast_modes[[mode]])
    binomial_power_prior_kernel_reset()
    for (case in cases) {
      reference <- do.call(reference_binomial_power_prior_target_terms, as.list(case))
      new <- do.call(binomial_power_prior_target_terms, as.list(case))
      expect_identical(new$differences, reference$differences)
      expect_identical(new$source_log_likelihood, reference$source_log_likelihood)
      # The target terms agree wherever the source treatment rate is on the
      # lattice, the only entries ever read.
      band <- is.finite(reference$source_log_likelihood)
      expect_lt(max(abs(new$target[band] / reference$target[band] - 1)), 1e-12)

      reference_bilinear <- reference_binomial_power_prior_bilinear(reference)
      new_bilinear <- binomial_power_prior_bilinear(new)
      expect_identical(new_bilinear == 0, reference_bilinear == 0)
      nonzero <- reference_bilinear != 0
      expect_lt(max(abs(new_bilinear[nonzero] / reference_bilinear[nonzero] - 1)), 1e-12)

      gamma <- c(0, 1e-10, 0.05, 0.3, 0.77, 1)
      expect_lt(max(abs(binomial_power_prior_log_marginal(new, gamma) -
                          reference_binomial_power_prior_log_marginal(reference, gamma))), 1e-10)
      estimate <- binomial_power_prior_empirical_bayes(new)
      expect_lt(abs(estimate - reference_binomial_power_prior_empirical_bayes(reference)), 1e-10)
      for (power_parameter in c(gamma, estimate)) {
        expect_same_posterior(binomial_power_prior_terms_posterior(new, power_parameter),
                              reference_binomial_power_prior_terms_posterior(reference, power_parameter))
      }
    }
  }
  binomial_power_prior_kernel_reset()
})

test_that("the empirical Bayes posterior read off the target terms is the direct one", {
  withr::local_options(BExTE.power_prior_kernels = 0L, BExTE.target_terms_cache = 4L)
  binomial_power_prior_kernel_reset()
  terms <- binomial_power_prior_target_terms(280, 154, 293, 184, 71, 39, 71, 33)
  # The power prior analysis of the same data now reads the same terms.
  expect_same_posterior(
    binomial_power_prior_posterior(0.4, 280, 154, 293, 184, 71, 39, 71, 33),
    reference_binomial_power_prior_posterior(0.4, 280, 154, 293, 184, 71, 39, 71, 33)
  )
  expect_length(binomial_target_terms_store$entries, 1)
  binomial_power_prior_kernel_reset()
})

test_that("the robust mixture posterior is the one of the mixture kernel", {
  components <- binomial_rmp_components(list(
    n_control_source = 280L, n_successes_control_source = 154L,
    n_treatment_source = 293L, n_successes_treatment_source = 184L
  ), n_lattice = 400L)
  targets <- list(c(47, 20, 47, 30), c(286, 150, 286, 100), c(71, 0, 71, 71), c(0, 0, 0, 0))
  for (weight in c(0, 0.3, 0.561, 1)) {
    for (target in targets) {
      reference <- do.call(binomial_npp_posterior,
                           c(list(binomial_rmp_kernels(components, weight)), as.list(target)))
      new <- do.call(binomial_rmp_posterior, c(list(components, weight), as.list(target)))
      expect_same_posterior(new, reference)
      expect_identical(names(new), names(reference))
      expect_lt(abs(new$prior_weight_mean - reference$prior_weight_mean), 1e-10)
    }
  }
})


# The analyses of the four methods whose power parameter or weight is chosen
# from the data, on the aprepitant case study, with the original
# implementation swapped back into the namespace for the reference.

lattice_fast_mcmc_config <- list(
  num_chains = 4L, parallel_chains = 4L, threads_per_chain = 1L, tune = 1000L,
  target_accept = 0.9, chain_length = 5000L, max_chain_length = 10000L,
  target_ess = 10000L, rhat_threshold = 1.1, max_divergence_rate = 0.01,
  engine = "quadrature"
)

lattice_fast_method_parameters <- list(
  p_value_based_PP = list(shape_parameter = list(1), initial_prior = list("noninformative"),
                          equivalence_margin = list(0.1)),
  EB_PP = list(initial_prior = list("noninformative")),
  PDCCPP = list(initial_prior = list("noninformative"), desired_tie = list(0.065),
                significance_level = list(0.05)),
  egidi_empirical_mixture = list(alpha_pc = list(0.05), pvalue_method = list("exact"),
                                 weight_grid_step = list(0.001),
                                 initial_prior = list("noninformative"),
                                 empirical_bayes = list(TRUE))
)

lattice_fast_model <- function(method, n) {
  case_study_config <- yaml::read_yaml(
    system.file("conf", "case_studies", "aprepitant.yml", package = "BExTE")
  )
  source_data <- SourceData$new(case_study_config)
  model <- Model$new()$create(
    case_study_config = case_study_config, method = method,
    method_parameters = lattice_fast_method_parameters[[method]],
    source_data = source_data, mcmc_config = lattice_fast_mcmc_config
  )
  target_data <- TargetDataFactory$new()$create(
    source_data = source_data, case_study_config = case_study_config,
    target_sample_size_per_arm = n, control_drift = 0,
    treatment_drift = case_study_config$theta_0 - source_data$treatment_effect_estimate,
    summary_measure_likelihood = case_study_config$summary_measure_likelihood
  )
  model$calibrate_for_design(target_data)
  if (method == "PDCCPP") {
    # The calibration only sets the calibration parameter, which is not what
    # is compared here; a fixed one spares computing its null table.
    model$calibration <- list(calibration_parameter = 0.3, type_I_error = NA_real_,
                              critical_value = 0.975)
  }
  list(model = model, target_data = target_data)
}

lattice_fast_analyse <- function(setup, counts) {
  inference_cache_reset()
  samples <- setup$target_data$samples_from_counts(counts$control, counts$treatment)
  setup$model$simulation_for_given_treatment_effect(
    target_data = setup$target_data, n_replicates = nrow(samples), critical_value = 0.975,
    theta_0 = 0, confidence_level = 0.95, null_space = "left", case_study = "aprepitant",
    method = setup$model$method,
    to_return = c("test_decision", "posterior_mean", "posterior_median", "fit_success"),
    n_samples_quantiles_estimation = 1000, simulation_config = list(), samples = samples
  )
}

lattice_fast_swapped <- c(
  "binomial_power_prior_posterior", "binomial_power_prior_target_terms",
  "binomial_power_prior_bilinear", "binomial_power_prior_log_marginal",
  "binomial_power_prior_empirical_bayes", "binomial_power_prior_terms_posterior"
)

# Runs `code` with the original implementation in the namespace, which every
# caller in the package then reaches.
with_reference_lattice <- function(code) {
  namespace <- asNamespace("BExTE")
  current <- mget(lattice_fast_swapped, envir = namespace)
  on.exit({
    for (name in lattice_fast_swapped) utils::assignInNamespace(name, current[[name]], ns = namespace)
  })
  for (name in lattice_fast_swapped) {
    utils::assignInNamespace(name, get(paste0("reference_", name)), ns = namespace)
  }
  # The Egidi mixture's own posterior, the inherited one of the lattice prior.
  egidi <- BinomialEgidiMixture$public_methods$quadrature_posterior
  on.exit(BinomialEgidiMixture$set("public", "quadrature_posterior", egidi, overwrite = TRUE),
          add = TRUE)
  BinomialEgidiMixture$set("public", "quadrature_posterior",
                           BinomialLatticePrior$public_methods$quadrature_posterior, overwrite = TRUE)
  force(code)
}

expect_same_analyses <- function(method, n, counts) {
  withr::local_options(BExTE.power_prior_kernels = 4L, BExTE.target_terms_cache = 0L)
  binomial_power_prior_kernel_reset()
  new <- lattice_fast_analyse(lattice_fast_model(method, n), counts)
  reference <- with_reference_lattice(lattice_fast_analyse(lattice_fast_model(method, n), counts))
  expect_identical(new$test_decisions, reference$test_decisions)
  expect_lt(max(abs(new$posterior_means - reference$posterior_means)), 1e-10)
  expect_lt(max(abs(new$posterior_medians - reference$posterior_medians)), 1e-10)
  binomial_power_prior_kernel_reset()
}

# Outcomes from the centre to the corners of the sample space, repeated so
# that the kernel store is exercised.
lattice_fast_counts <- function(n, size) {
  set.seed(n)
  counts <- data.frame(control = c(0, n, round(n / 2), sample(0:n, size, replace = TRUE)),
                       treatment = c(n, 0, round(n / 2), sample(0:n, size, replace = TRUE)))
  rbind(counts, counts[c(1, 2), ])
}

test_that("the data-driven binomial methods decide as before at 47 per arm", {
  for (method in names(lattice_fast_method_parameters)) {
    expect_same_analyses(method, 47, lattice_fast_counts(47, 8))
  }
})

test_that("the data-driven binomial methods decide as before at 286 per arm", {
  for (method in names(lattice_fast_method_parameters)) {
    counts <- lattice_fast_counts(286, 2)
    counts <- rbind(counts, data.frame(control = c(150, 160, 140), treatment = c(170, 165, 180)))
    expect_same_analyses(method, 286, counts)
  }
})

test_that("the data-driven binomial methods decide as before on every outcome at 47 per arm", {
  skip_if_not(identical(Sys.getenv("BEXTE_SLOW_TESTS"), "true"),
              "Set BEXTE_SLOW_TESTS=true for the full grid of outcomes (about an hour).")
  grid <- expand.grid(control = 0:47, treatment = 0:47)
  # BEXTE_SLOW_METHODS, a comma-separated list, splits the work between processes.
  methods <- strsplit(Sys.getenv("BEXTE_SLOW_METHODS",
                                 paste(names(lattice_fast_method_parameters), collapse = ",")), ",")[[1]]
  for (method in methods) {
    expect_same_analyses(method, 47, grid)
  }
})
