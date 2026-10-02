# Robust mixture priors for the binomial model, with an exact binomial
# informative component.
#
# The informative component is the source posterior of the risk difference
# carried to the target, i.e. the binomial conditional power prior with full
# borrowing (gamma = 1), rather than its normal approximation
# N(theta_S_hat, SE_S^2). The weak component gives both target response rates
# independent uniform priors, which is the prior of the separate analysis.
# Both are priors on the target control rate and the risk difference,
# tabulated on the lattice of binomial_npp_prior_kernels() and normalised, so
# the robust mixture prior w * informative + (1 - w) * weak is a lattice prior
# too, and the posterior weight of the informative component comes out of the
# same weighted sums as the posterior.
#
# The empirical mixture prior of Egidi et al. (2022) chooses w for each dataset
# from a prior-predictive conflict p-value. Its component tables - the
# prior-predictive probability of every pair of responder counts - are
# computed exactly from the same two lattice priors.


#' The two components of the binomial robust mixture prior
#'
#' @param source_counts List of the four source counts.
#' @param n_lattice Number of lattice points N.
#' @return A list with `n_lattice`, `rates`, `differences`, and the N x (2N - 1)
#'   kernels `informative` and `weak`, each summing to one.
#' @keywords internal
binomial_rmp_components <- function(source_counts, n_lattice = 1000L) {
  lattice_kernel_cached(list("binomial robust mixture components", source_counts,
                             as.integer(n_lattice)), function() {
    full_borrowing <- do.call(binomial_cpp_cached_kernel, c(source_counts, list(
      power_parameter = 1, n_lattice = n_lattice
    )))
    N <- full_borrowing$n_lattice
    target_rate <- outer(seq_len(N), full_borrowing$differences, "+")
    admissible <- target_rate >= 1L & target_rate <= N
    list(
      n_lattice = N,
      rates = full_borrowing$rates,
      differences = full_borrowing$differences,
      informative = full_borrowing$kernel / sum(full_borrowing$kernel),
      # Uniform target control rate and, given it, a uniform treatment rate:
      # N admissible risk differences for each of the N control rates.
      weak = admissible / N^2
    )
  })
}


#' Prior kernels of the binomial robust mixture prior with a given weight
#'
#' @param components Output of [binomial_rmp_components()].
#' @param weight Prior weight of the informative component.
#' @return A list as [binomial_npp_posterior()] reads it, whose
#'   `prior_weight` moment gives the posterior weight of the informative
#'   component.
#' @keywords internal
binomial_rmp_kernels <- function(components, weight) {
  informative <- weight * components$informative
  list(
    n_lattice = components$n_lattice,
    rates = components$rates,
    differences = components$differences,
    kernel = informative + (1 - weight) * components$weak,
    moments = list(prior_weight = list(first = informative, second = informative))
  )
}


#' Prior-predictive tables of the binomial robust mixture components
#'
#' @description The prior-predictive probability of every pair of target
#'   responder counts under each component, as the matrices
#'   [egidi_binomial_conflict_pvalue()] reads: one row per control count and
#'   one column per treatment count. On the lattice, the table is
#'   `t(B_c) K B_t`, with `K` the component in target control and treatment
#'   rates and `B` the binomial probabilities of each count at each rate.
#'
#' @param components Output of [binomial_rmp_components()].
#' @param source_counts The source counts the components were built from,
#'   which identify them in the cache.
#' @param n_control,n_treatment Target arm sizes.
#' @return A list with `informative` and `weak` tables.
#' @keywords internal
binomial_rmp_predictive_tables <- function(components, source_counts, n_control, n_treatment) {
  lattice_kernel_cached(list("binomial robust mixture predictive tables",
                             components$n_lattice, source_counts,
                             as.integer(n_control), as.integer(n_treatment)), function() {
    N <- components$n_lattice
    rates <- components$rates
    control <- outer(rates, seq.int(0, n_control), function(r, y) stats::dbinom(y, n_control, r))
    treatment <- outer(rates, seq.int(0, n_treatment), function(r, y) stats::dbinom(y, n_treatment, r))
    rows <- rep(seq_len(N), times = length(components$differences))
    columns <- rows + rep(components$differences, each = N)
    inside <- columns >= 1L & columns <= N
    table_of <- function(kernel) {
      in_rates <- matrix(0, N, N)
      in_rates[cbind(rows[inside], columns[inside])] <- kernel[inside]
      crossprod(control, in_rates %*% treatment)
    }
    # Under independent uniform response rates every pair of counts is equally
    # likely a priori (beta-binomial with unit shapes), so the weak table is
    # exactly uniform. Its lattice value differs by a few parts in 10^4, which
    # would break the ties the conflict p-value counts.
    weak <- matrix(1 / ((n_control + 1) * (n_treatment + 1)), n_control + 1L, n_treatment + 1L)
    list(informative = table_of(components$informative), weak = weak)
  })
}


#' BinomialRMP class
#'
#' @description The robust mixture prior for a binary endpoint, with the
#'   binomial likelihoods of both arms and an exact binomial informative
#'   component; see the comment at the top of `R/binomial_rmp.R`. It replaced
#'   a truncated normal mixture whose informative component was the normal
#'   approximation of the source posterior.
#'
#' @field w Prior weight of the informative component.
#' @field method Method name.
#' @export
BinomialRMP <- R6::R6Class(
  "BinomialRMP",
  inherit = BinomialLatticePrior,
  public = list(
    w = NULL,
    method = "RMP",

    #' @description Initialize the model.
    #' @param prior The prior object, with `prior_weight` among its method
    #'   parameters.
    #' @param mcmc_config The MCMC configuration; only the quadrature engine is
    #'   supported.
    initialize = function(prior, mcmc_config) {
      super$initialize(prior = prior, mcmc_config = mcmc_config)
      self$w <- unlist(prior$method_parameters$prior_weight)
      self$posterior_parameters <- list(prior_weight = NA_real_)
    },

    #' @description
    #' Rows of the model summary, with the prior weight
    #' @return A data frame with columns `Attribute` and `Value`.
    summary_rows = function() {
      rbind(
        super$summary_rows(),
        summary_row("Prior Weight", self$w)
      )
    },

    #' @description The two components, computed once per worker and shared.
    #' @return The output of [binomial_rmp_components()].
    components = function() {
      binomial_rmp_components(self$source_counts(), self$n_lattice)
    },

    #' @description The prior kernels at the current weight, kept until the
    #' weight changes.
    #' @return The output of [binomial_rmp_kernels()].
    kernels = function() {
      if (is.null(private$memo) || !identical(private$memo_weight, self$w)) {
        private$memo <- binomial_rmp_kernels(self$components(), self$w)
        private$memo_weight <- self$w
      }
      private$memo
    },

    #' @description What identifies the prior, for the ELIR cache.
    #' @return A list.
    kernel_key = function() {
      c(self$source_counts(), list(w = self$w))
    },

    #' @description Record the posterior weight of the informative component.
    compute_posterior_parameters = function() {
      self$posterior_parameters <- list(
        prior_weight = self$grid_posterior$prior_weight_mean
      )
    }
  ),
  private = list(
    memo = NULL,
    memo_weight = NULL
  )
)


#' BinomialEgidiMixture class
#'
#' @description The empirical robust mixture prior of Egidi et al. (2022) for a
#'   binary endpoint, on the components of [BinomialRMP]: for each dataset, the
#'   weight of the weak component is the smallest on the grid at which the
#'   prior-predictive conflict p-value of the observed counts reaches
#'   `alpha_pc`, the p-value being computed exactly from the components'
#'   prior-predictive tables (see [egidi_select_weak_weight_binomial()]).
#'
#' @field alpha_pc Conflict threshold.
#' @field pvalue_method Conflict p-value method.
#' @field weight_grid_step Resolution of the weight scan.
#' @field selection The selection of the current dataset.
#' @field quantile_summary_columns Columns summarised by quantiles across
#'   replicates.
#' @field empirical_bayes The prior depends on the target data.
#' @field empirical_bayes_from_sample The prior is a function of the
#'   replicate's sample alone.
#' @field method Method name.
#' @export
BinomialEgidiMixture <- R6::R6Class(
  "BinomialEgidiMixture",
  inherit = BinomialRMP,
  public = list(
    alpha_pc = NULL,
    pvalue_method = NULL,
    weight_grid_step = NULL,
    selection = NULL,
    quantile_summary_columns = "psi_weak",
    empirical_bayes = TRUE,
    empirical_bayes_from_sample = TRUE,
    method = "egidi_empirical_mixture",

    #' @description Initialize the model.
    #' @param prior The prior object.
    #' @param mcmc_config The MCMC configuration; only the quadrature engine is
    #'   supported.
    initialize = function(prior, mcmc_config) {
      settings <- egidi_method_settings(prior$method_parameters)
      prior$method_parameters$prior_weight <- NA_real_
      super$initialize(prior = prior, mcmc_config = mcmc_config)
      self$alpha_pc <- settings$alpha_pc
      self$pvalue_method <- settings$pvalue_method
      self$weight_grid_step <- settings$weight_grid_step
      self$selection <- egidi_empty_selection()
      self$posterior_parameters <- egidi_posterior_parameters(NA_real_, self$selection)
    },

    #' @description Choose the weight from the replicate's counts.
    #' @param target_data Target study data.
    empirical_bayes_update = function(target_data) {
      n_control <- as.integer(target_data$sample_size_control)
      n_treatment <- as.integer(target_data$sample_size_treatment)
      tables <- binomial_rmp_predictive_tables(self$components(), self$source_counts(),
                                               n_control, n_treatment)
      self$selection <- egidi_select_weak_weight_binomial(
        table_informative = tables$informative,
        table_weak = tables$weak,
        y_control = counts_from_rate(target_data$sample$sample_control_rate, n_control),
        y_treatment = counts_from_rate(target_data$sample$sample_treatment_rate, n_treatment),
        alpha_pc = self$alpha_pc,
        weight_grid_step = self$weight_grid_step
      )
      self$w <- 1 - self$selection$psi_weak
      # The prior changed with the weight.
      self$prior_grid <- NULL
      self$prior_elir_unit_information <- NULL
      invisible(NULL)
    },

    #' @description Record the posterior weight and the selection.
    compute_posterior_parameters = function() {
      self$posterior_parameters <- egidi_posterior_parameters(
        informative_posterior_weight = self$grid_posterior$prior_weight_mean,
        selection = self$selection
      )
    },

    #' @description ELIR effective sample size of the current prior. The prior
    #' changes between datasets only through its weight, so the unit-scale ELIR
    #' is computed at weights 0, 0.05, ..., 1, once per worker, and interpolated
    #' linearly.
    #' @param target_data Target study data.
    #' @param simulation_config Simulation configuration.
    #' @return The ELIR effective sample size.
    prior_elir_ess = function(target_data, simulation_config) {
      node_value <- function(weight) {
        key <- rlang::hash(list("binomial egidi elir", self$source_counts(), weight,
                                self$n_lattice, as.integer(simulation_config$n_samples_mixture_approx),
                                self$n_components_mixture_approx,
                                self$aic_penalty_parameter_mixture_approx))
        if (!exists(key, envir = power_prior_elir_cache_store, inherits = FALSE)) {
          kernels <- binomial_rmp_kernels(self$components(), weight)
          assign(key, grid_prior_unit_elir(
            prior_grid = binomial_npp_posterior(kernels, 0L, 0L, 0L, 0L),
            n_samples = simulation_config$n_samples_mixture_approx,
            n_fits = 10L,
            n_components = self$n_components_mixture_approx,
            aic_penalty = self$aic_penalty_parameter_mixture_approx
          ), envir = power_prior_elir_cache_store)
        }
        get(key, envir = power_prior_elir_cache_store)
      }
      step <- 0.05
      lower <- floor(self$w / step + 1e-9)
      fraction <- self$w / step - lower
      unit <- if (fraction <= 1e-9 || lower * step >= 1) {
        node_value(min(1, lower * step))
      } else {
        (1 - fraction) * node_value(lower * step) + fraction * node_value((lower + 1) * step)
      }
      unit * target_data$sample$standard_deviation^2
    }
  )
)
