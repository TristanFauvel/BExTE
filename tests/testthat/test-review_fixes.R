# Three fixes from a review of the Bayesian and pooled operating
# characteristics:
# - under a binomial likelihood the design prior is taken given the control
#   rate the trials are simulated at, so it puts no mass on effects those trials
#   cannot have;
# - the analytic power of the pooled analysis holds the source data fixed, as
#   the simulation does, rather than treating them as resampled;
# - the Monte Carlo Bayesian operating characteristics average the decisions
#   of the replicates actually analysed.

review_case_study <- function(name) {
  yaml::read_yaml(system.file("conf", "case_studies", paste0(name, ".yml"), package = "BExTE"))
}

review_mcmc_config <- function() {
  yaml::read_yaml(system.file("conf", "full", "mcmc_config.yml", package = "BExTE"))
}

review_model <- function(method, parameters, config = review_case_study("aprepitant")) {
  Model$new()$create(
    case_study_config = config,
    method = method,
    method_parameters = lapply(parameters, list),
    source_data = SourceData$new(config, NA),
    mcmc_config = review_mcmc_config()
  )
}

review_design_prior <- function(type, model, config, control_rate) {
  DesignPrior$new()$create(
    design_prior_type = type,
    model = model,
    source_data = SourceData$new(config, NA),
    case_study_config = config,
    simulation_config = list(n_samples_mixture_approx = 500),
    mcmc_config = review_mcmc_config(),
    case_study = config$name,
    target_control_rate = control_rate
  )
}


test_that("binomial design priors put no mass outside the feasible effects", {
  config <- review_case_study("aprepitant")
  control_rate <- SourceData$new(config, NA)$control_rate
  lower <- -control_rate
  upper <- 1 - control_rate

  set.seed(1)
  cases <- list(
    list("analysis_prior", review_model("separate", list(initial_prior = "noninformative"))),
    list("analysis_prior", review_model("pooling", list(initial_prior = "noninformative"))),
    list("analysis_prior", review_model("conditional_power_prior",
                                        list(power_parameter = 0.5, initial_prior = "noninformative"))),
    list("source_posterior", review_model("separate", list(initial_prior = "noninformative"))),
    list("ui_design_prior", review_model("separate", list(initial_prior = "noninformative")))
  )

  for (case in cases) {
    prior <- review_design_prior(case[[1]], case[[2]], config, control_rate)
    label <- paste(case[[1]], case[[2]]$method)
    expect_equal(prior$cdf(lower), 0, tolerance = 1e-9, label = label)
    expect_equal(prior$cdf(upper), 1, tolerance = 1e-9, label = label)
    expect_equal(prior$pdf(c(lower - 0.1, upper + 0.1)), c(0, 0), label = label)
    draws <- prior$sample(2000)
    expect_true(all(draws >= lower & draws <= upper), label = label)
    # The density integrates to the distribution function inside the range.
    grid <- seq(lower, upper, length.out = 4001)
    integral <- sum(diff(grid) * (prior$pdf(grid[-1]) + prior$pdf(grid[-length(grid)])) / 2)
    expect_equal(integral, 1, tolerance = 1e-3, label = label)
  }
})


test_that("the separate analysis prior given the control rate is uniform on the feasible effects", {
  config <- review_case_study("aprepitant")
  prior <- review_design_prior(
    "analysis_prior", review_model("separate", list(initial_prior = "noninformative")), config, 0.55
  )
  expect_equal(prior$cdf(c(-0.55, -0.05, 0.45)), c(0, 0.5, 1))
  expect_equal(prior$pdf(0.1), 1)
})


test_that("without a control rate, or off a binomial likelihood, design priors are unchanged", {
  config <- review_case_study("aprepitant")
  model <- review_model("separate", list(initial_prior = "noninformative"))
  prior <- review_design_prior("analysis_prior", model, config, NULL)
  expect_s3_class(prior, "AnalysisPriorDesignPrior")
  # The marginal triangular prior.
  expect_equal(prior$cdf(0), 0.5)
})


test_that("the conditioned power prior matches its quadrature at a fixed control rate", {
  model <- review_model("conditional_power_prior",
                        list(power_parameter = 0.5, initial_prior = "noninformative"))
  conditional <- model$prior_given_control_rate(0.55)

  # Reference: the density on a fine grid, integrating the source control rate
  # against its power-posterior density directly.
  source <- model$prior$source
  s_c <- counts_from_rate(source$control_rate, source$sample_size_control)
  s_t <- counts_from_rate(source$treatment_rate, source$sample_size_treatment)
  n_c <- source$sample_size_control
  n_t <- source$sample_size_treatment
  gamma <- 0.5
  density_at <- function(theta) {
    stats::integrate(function(u) {
      inside <- theta > -pmin(u, 0.55) & theta < 1 - pmax(u, 0.55)
      stats::dbeta(u, gamma * s_c + 1, gamma * (n_c - s_c) + 1) *
        stats::dbeta(u + theta, gamma * s_t + 1, gamma * (n_t - s_t) + 1) *
        inside / (1 - abs(u - 0.55))
    }, 0, 1, subdivisions = 2000L)$value
  }
  thetas <- c(-0.1, 0, 0.05, 0.1, 0.2)
  reference <- vapply(thetas, density_at, numeric(1))
  total <- stats::integrate(Vectorize(density_at), -0.55, 0.45, subdivisions = 500L)$value
  expect_equal(conditional$pdf(thetas), reference / total, tolerance = 1e-3)
})


test_that("only analysed replicates count towards the Monte Carlo success probability", {
  # The replicate loop leaves unanalysed slots at zero, with no fit status.
  from_loop <- list(test_decisions = c(1, 1, 0, 1, 0, 0), fit_success = c(rep("Success", 4), "", ""))
  expect_equal(analysed_success_probability(from_loop), 0.75)

  # The vectorised path returns the analysed replicates only.
  vectorised <- list(test_decisions = c(1, 0, 1, 1), fit_success = rep("Success", 4))
  expect_equal(analysed_success_probability(vectorised), 0.75)

  expect_true(is.na(analysed_success_probability(list(test_decisions = 1, fit_success = ""))))
  expect_error(analysed_success_probability(list(test_decisions = c(1, 0))), "fit_success")
  expect_error(analysed_success_probability(list(test_decisions = c(1, 0), fit_success = "Success")),
               "decisions for")
})
