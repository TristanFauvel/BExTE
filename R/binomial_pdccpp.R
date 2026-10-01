# Calibrated power prior (PDCCPP) for the binomial model, with an exact
# calibration.
#
# Nikolakopoulos et al. (2018) set the power parameter from the standardised
# difference between the target and source estimates,
#
#   gamma = 1                                        if |d| <= Z sqrt(SE_S^2 + SE_T^2),
#   gamma = SE_S^2 / ((d / Z)^2 - SE_T^2)            otherwise,
#
# with d the difference of the estimates and Z a calibration parameter chosen
# so that the design's type I error rate is a prespecified value. This is
# equation (9) of that paper, as PDCCPP$power_parameter_from_calibration()
# writes it (there, tau2 / n0 = SE_S^2 and tau2 / n = SE_T^2). In the normal
# case the type I error is available in closed form for any Z.
#
# Here the rule is applied to the estimated risk differences and their standard
# errors as before, but the posterior is that of the binomial conditional power
# prior with the power parameter it gives, and Z is calibrated on the exact
# type I error of that binomial analysis: the sum, over every pair of responder
# counts under the null, of its probability times the indicator that the
# analysis rejects. For each pair, the set of power parameters at which it
# rejects is computed once; the type I error is then available for any Z at
# negligible cost, and Z is the largest value at which it does not exceed the
# desired one.


#' Power parameter of the calibrated power prior
#'
#' @param target_estimate,target_standard_error Target estimates and their
#'   standard errors.
#' @param source_estimate,source_standard_error Source estimate and its
#'   standard error.
#' @param calibration_parameter The calibration parameter Z, a number of
#'   predictive standard deviations.
#' @return The power parameters, vectorised over the target estimates.
#' @keywords internal
pdccpp_power_parameter <- function(target_estimate, target_standard_error,
                                   source_estimate, source_standard_error,
                                   calibration_parameter) {
  difference <- target_estimate - source_estimate
  predictive_sd <- sqrt(source_standard_error^2 + target_standard_error^2)
  discounted <- abs(difference) > calibration_parameter * predictive_sd
  out <- rep(1, length(difference))
  out[discounted] <- source_standard_error^2 /
    ((difference[discounted] / calibration_parameter)^2 - target_standard_error[discounted]^2)
  pmin(pmax(out, 0), 1)
}


#' Directory of the exact PDCCPP calibration tables
#' @return A directory path, created if needed.
#' @keywords internal
pdccpp_binomial_cache_dir <- function() {
  bexte_cache_dir("pdccpp_binomial")
}


#' Directory of BExTE's disk caches
#'
#' @description Under `BEXTE_CACHE_DIR` when it is set, and
#'   `tools::R_user_dir("BExTE", "cache")` otherwise. Everything stored there
#'   is a deterministic function of its key, so it can be deleted at any time.
#' @param subdirectory The cache's own subdirectory.
#' @return A directory path, created if needed.
#' @keywords internal
bexte_cache_dir <- function(subdirectory) {
  root <- Sys.getenv("BEXTE_CACHE_DIR", tools::R_user_dir("BExTE", "cache"))
  directory <- file.path(root, subdirectory)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  directory
}


#' Read a value from the disk cache, computing and storing it if absent
#'
#' @description Shares the binomial prior kernels between the worker processes
#'   of a run, and between runs: a kernel takes from seconds to minutes to
#'   compute and depends only on its key. Writes are atomic, so a process never
#'   reads a partly written file; two processes computing the same value at
#'   once both store the same result.
#'
#' @param key A list identifying the value.
#' @param compute A function of no arguments returning the value.
#' @param subdirectory Subdirectory of [bexte_cache_dir()].
#' @return The value.
#' @keywords internal
disk_cached <- function(key, compute, subdirectory = "lattice_kernels") {
  path <- file.path(bexte_cache_dir(subdirectory), paste0(rlang::hash(key), ".rds"))
  if (file.exists(path)) {
    value <- tryCatch(readRDS(path), error = function(e) NULL)
    if (!is.null(value)) {
      return(value)
    }
  }
  value <- compute()
  temporary <- tempfile(tmpdir = dirname(path), fileext = ".rds")
  saveRDS(value, temporary, compress = FALSE)
  file.rename(temporary, path)
  value
}


#' Where the binomial analysis rejects, for every outcome under the null
#'
#' @description For every pair of target responder counts under the null
#'   hypothesis (control rate `control_rate`, treatment rate `control_rate +
#'   theta_0`), the power parameters at which the binomial conditional power
#'   prior rejects the null hypothesis: the posterior probability that the
#'   treatment effect lies beyond `theta_0` on the alternative side is evaluated
#'   on a grid of 21 power parameters, and each crossing of `critical_value` is
#'   refined by `uniroot`. Pairs whose total probability is below `tail_mass`
#'   are omitted, as in `BinaryTargetData$enumerate_support()`.
#'
#'   The table depends on the source counts and the design alone, so it is
#'   saved under [pdccpp_binomial_cache_dir()] and read back by any process
#'   that needs it; `workers` computes it in parallel.
#'
#' @inheritParams binomial_power_prior_posterior
#' @param control_rate Target control rate of the design.
#' @param theta_0 Boundary of the null hypothesis space.
#' @param null_space `"left"` or `"right"`.
#' @param critical_value Posterior probability the analysis decides at.
#' @param tail_mass Probability of the omitted pairs.
#' @param workers Number of processes.
#' @return A list with, per pair, the `estimate`, `standard_error`, `weight`,
#'   `reject_at_zero` (whether it rejects at a power parameter of 0) and
#'   `crossings` (a list of the power parameters where that changes).
#' @keywords internal
pdccpp_binomial_null_table <- function(n_control_source,
                                       n_successes_control_source,
                                       n_treatment_source,
                                       n_successes_treatment_source,
                                       n_control,
                                       n_treatment,
                                       control_rate,
                                       theta_0,
                                       null_space,
                                       critical_value,
                                       n_lattice = 1000L,
                                       tail_mass = 1e-10,
                                       workers = 1L) {
  identity <- list(
    "pdccpp binomial null table v1",
    as.integer(c(n_control_source, n_successes_control_source,
                 n_treatment_source, n_successes_treatment_source,
                 n_control, n_treatment, n_lattice)),
    signif(c(control_rate, theta_0, critical_value, tail_mass), 12),
    null_space
  )
  path <- file.path(pdccpp_binomial_cache_dir(), paste0(rlang::hash(identity), ".rds"))
  if (file.exists(path)) {
    return(readRDS(path))
  }

  treatment_rate <- control_rate + theta_0
  arm_support <- function(n, rate) {
    counts <- seq.int(stats::qbinom(tail_mass / 4, n, rate),
                      stats::qbinom(tail_mass / 4, n, rate, lower.tail = FALSE))
    list(counts = counts, probabilities = stats::dbinom(counts, n, rate))
  }
  control <- arm_support(n_control, control_rate)
  treatment <- arm_support(n_treatment, treatment_rate)
  grid <- expand.grid(control = seq_along(control$counts),
                      treatment = seq_along(treatment$counts))
  control_counts <- control$counts[grid$control]
  treatment_counts <- treatment$counts[grid$treatment]
  weight <- control$probabilities[grid$control] * treatment$probabilities[grid$treatment]
  weight <- weight / sum(weight)

  control_estimate <- control_counts / n_control
  treatment_estimate <- treatment_counts / n_treatment
  estimate <- treatment_estimate - control_estimate
  standard_error <- sqrt(treatment_estimate * (1 - treatment_estimate) / n_treatment +
                           control_estimate * (1 - control_estimate) / n_control)

  benefit <- function(terms, gamma) {
    posterior <- binomial_power_prior_terms_posterior(terms, gamma)
    below <- grid_posterior_cdf(posterior, theta_0)
    if (identical(null_space, "left")) 1 - below else below
  }
  gamma_grid <- seq(0, 1, by = 0.05)
  one_pair <- function(index) {
    terms <- binomial_power_prior_target_terms(
      n_control_source, n_successes_control_source,
      n_treatment_source, n_successes_treatment_source,
      n_control, control_counts[index], n_treatment, treatment_counts[index],
      n_lattice = n_lattice
    )
    excess <- vapply(gamma_grid, function(gamma) benefit(terms, gamma) - critical_value,
                     numeric(1))
    changes <- which(diff(excess > 0) != 0)
    crossings <- vapply(changes, function(k) {
      stats::uniroot(function(gamma) benefit(terms, gamma) - critical_value,
                     interval = gamma_grid[c(k, k + 1L)], tol = 1e-8)$root
    }, numeric(1))
    list(reject_at_zero = excess[1] > 0, crossings = crossings)
  }

  pairs <- if (workers > 1L) {
    parallel::mclapply(seq_along(weight), one_pair, mc.cores = workers)
  } else {
    lapply(seq_along(weight), one_pair)
  }

  table <- list(
    estimate = estimate,
    standard_error = standard_error,
    weight = weight,
    reject_at_zero = vapply(pairs, `[[`, logical(1), "reject_at_zero"),
    crossings = lapply(pairs, `[[`, "crossings")
  )
  temporary <- tempfile(tmpdir = dirname(path), fileext = ".rds")
  saveRDS(table, temporary)
  file.rename(temporary, path)
  table
}


#' Exact type I error of the binomial PDCCPP for given calibration parameters
#'
#' @param table Output of [pdccpp_binomial_null_table()].
#' @param calibration_parameter Calibration parameters Z.
#' @param source_estimate,source_standard_error The source estimate and its
#'   standard error.
#' @return One type I error rate per calibration parameter.
#' @keywords internal
pdccpp_binomial_type_I_error <- function(table, calibration_parameter,
                                         source_estimate, source_standard_error) {
  vapply(calibration_parameter, function(z) {
    gamma <- pdccpp_power_parameter(table$estimate, table$standard_error,
                                    source_estimate, source_standard_error, z)
    flips <- mapply(function(crossings, g) sum(crossings < g), table$crossings, gamma)
    rejects <- xor(table$reject_at_zero, flips %% 2 == 1)
    sum(table$weight[rejects])
  }, numeric(1))
}


#' Calibrate the binomial PDCCPP on its exact type I error
#'
#' @description The largest calibration parameter Z whose exact type I error
#'   does not exceed `desired_tie`. The type I error is a step function of Z,
#'   so Z is located on a logarithmic grid over [1e-3, 1e3] and refined by
#'   bisection at the last grid step that stays within `desired_tie`. If even
#'   the largest Z does, borrowing is never discounted for conflict and Z is
#'   the top of the grid; if even the smallest does not, Z is its bottom.
#'
#' @inheritParams pdccpp_binomial_type_I_error
#' @param desired_tie Desired type I error rate.
#' @return A list with the `calibration_parameter` and its exact `type_I_error`.
#' @keywords internal
pdccpp_binomial_calibrate <- function(table, desired_tie, source_estimate,
                                      source_standard_error) {
  tie <- function(z) pdccpp_binomial_type_I_error(table, z, source_estimate,
                                                  source_standard_error)
  grid <- 10^seq(-3, 3, length.out = 241)
  values <- tie(grid)
  within <- values <= desired_tie
  if (all(within)) {
    return(list(calibration_parameter = max(grid), type_I_error = values[length(values)]))
  }
  if (!within[1]) {
    warning("The binomial PDCCPP exceeds the desired type I error at every calibration ",
            "parameter; using the smallest.", call. = FALSE)
    return(list(calibration_parameter = grid[1], type_I_error = values[1]))
  }
  last <- max(which(within & cumsum(!within) == 0))
  lower <- grid[last]
  upper <- grid[last + 1L]
  for (step in seq_len(60)) {
    middle <- sqrt(lower * upper)
    if (tie(middle) <= desired_tie) lower <- middle else upper <- middle
    if (upper / lower - 1 < 1e-10) break
  }
  list(calibration_parameter = lower, type_I_error = tie(lower))
}


#' BinomialPDCCPP class
#'
#' @description The calibrated power prior of [PDCCPP] for a binary endpoint:
#'   the power parameter is given by the same rule, applied to the estimated
#'   risk differences and their standard errors, the target data are analysed
#'   with the binomial conditional power prior of [BinomialCPP] at that power
#'   parameter, and the calibration parameter is calibrated on the exact type I
#'   error of this binomial analysis rather than on the closed form of a normal
#'   one; see the comment at the top of `R/binomial_pdccpp.R`.
#'
#'   The calibration needs the design, which [Model]`$calibrate_for_design()`
#'   records, and the critical value the analysis decides at, which is only
#'   known once a replicate is analysed, so it runs at the first replicate.
#'
#' @field method Method name.
#' @field empirical_bayes The prior depends on the target data.
#' @field empirical_bayes_from_sample The prior is a function of the
#'   replicate's sample alone.
#' @field fixed_power_parameter The power parameter changes between replicates.
#' @field null_space Side of the null hypothesis space.
#' @field theta_0 Boundary of the null hypothesis space.
#' @field design The target data of the design calibrated against.
#' @field calibration The calibration parameter and its exact type I error.
#' @export
BinomialPDCCPP <- R6::R6Class(
  "BinomialPDCCPP",
  inherit = BinomialCPP,
  public = list(
    method = "PDCCPP",
    empirical_bayes = TRUE,
    empirical_bayes_from_sample = TRUE,
    fixed_power_parameter = FALSE,
    null_space = NULL,
    theta_0 = NULL,
    design = NULL,
    calibration = NULL,

    #' @description Initialize a BinomialPDCCPP model.
    #' @param prior The prior object.
    #' @param theta_0 Boundary of the null hypothesis space.
    #' @param null_space Side of the null hypothesis space.
    #' @param mcmc_config The MCMC configuration; only the quadrature engine is
    #'   supported.
    initialize = function(prior, theta_0, null_space, mcmc_config) {
      if (identical(mcmc_config$engine, "stan")) {
        stop("The binomial PDCCPP is only computed by quadrature; set engine: quadrature.",
             call. = FALSE)
      }
      super$initialize(prior = prior, mcmc_config = mcmc_config)
      self$power_parameter <- 1
      self$theta_0 <- theta_0
      self$null_space <- null_space
      self$parameters <- list(
        desired_tie = prior$method_parameters$desired_tie[[1]],
        significance_level = prior$method_parameters$significance_level[[1]]
      )
    },

    #' @description Record the design the calibration is computed for.
    #' @param target_data Target study data for the scenario.
    #' @return `NULL`, invisibly.
    calibrate_for_design = function(target_data) {
      self$design <- list(
        n_control = as.integer(target_data$sample_size_control),
        n_treatment = as.integer(target_data$sample_size_treatment),
        control_rate = target_data$control_rate
      )
      self$calibration <- NULL
      invisible(NULL)
    },

    #' @description Calibrate, if not done yet for the current design and
    #' critical value.
    #' @param workers Number of processes for the null table.
    #' @return The calibration, invisibly.
    ensure_calibrated = function(workers = 1L) {
      critical_value <- if (is.null(self$analysis_critical_value)) {
        1 - self$parameters$significance_level
      } else {
        self$analysis_critical_value
      }
      if (!is.null(self$calibration) &&
          isTRUE(all.equal(self$calibration$critical_value, critical_value))) {
        return(invisible(self$calibration))
      }
      if (is.null(self$design)) {
        stop("The binomial PDCCPP has no design to calibrate against. Call ",
             "calibrate_for_design() with this scenario's target data first.", call. = FALSE)
      }
      counts <- self$prepare_data(list(
        sample_size_control = self$design$n_control,
        sample_size_treatment = self$design$n_treatment,
        sample = data.frame(sample_control_rate = 0, sample_treatment_rate = 0)
      ))
      table <- pdccpp_binomial_null_table(
        n_control_source = counts$n_control_source,
        n_successes_control_source = counts$successes_control_source,
        n_treatment_source = counts$n_treatment_source,
        n_successes_treatment_source = counts$successes_treatment_source,
        n_control = self$design$n_control,
        n_treatment = self$design$n_treatment,
        control_rate = self$design$control_rate,
        theta_0 = self$theta_0,
        null_space = self$null_space,
        critical_value = critical_value,
        workers = workers
      )
      calibration <- pdccpp_binomial_calibrate(
        table,
        desired_tie = self$parameters$desired_tie,
        source_estimate = self$prior$source$treatment_effect_estimate,
        source_standard_error = self$prior$source$standard_error
      )
      calibration$critical_value <- critical_value
      self$calibration <- calibration
      invisible(calibration)
    },

    #' @description Set the power parameter from the replicate's estimates.
    #' @param target_data Target study data.
    empirical_bayes_update = function(target_data) {
      self$ensure_calibrated()
      gamma <- pdccpp_power_parameter(
        target_data$sample$treatment_effect_estimate,
        target_data$sample$treatment_effect_standard_error,
        self$prior$source$treatment_effect_estimate,
        self$prior$source$standard_error,
        self$calibration$calibration_parameter
      )
      self$power_parameter <- gamma
      self$posterior_parameters <- list(
        power_parameter = gamma,
        calibration_parameter = self$calibration$calibration_parameter,
        calibrated_type_I_error = self$calibration$type_I_error
      )
      self$prior_grid <- NULL
      self$prior_pdf_approx <- NULL
      self$prior_cdf_approx <- NULL
      invisible(NULL)
    },

    #' @description ELIR effective sample size of the current prior,
    #' interpolated over the power parameter; see
    #' [binomial_power_prior_unit_elir()].
    #' @param target_data Target study data.
    #' @param simulation_config Configuration of the simulation study.
    #' @return The ELIR effective sample size.
    prior_elir_ess = function(target_data, simulation_config) {
      unit_information <- binomial_power_prior_unit_elir(
        model = self,
        power_parameter = self$power_parameter,
        n_samples = simulation_config$n_samples_mixture_approx
      )
      unit_information * target_data$sample$standard_deviation^2
    }
  )
)
