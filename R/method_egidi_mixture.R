#' Per-replicate diagnostics reported by the Egidi mixture prior
#'
#' @description Assembles the columns both the scalar and the vectorised paths
#' report, so the two cannot describe the same run differently.
#'
#' @details
#' The summariser in [Model$estimate_frequentist_operating_characteristics()]
#' averages each column, so the quantities that are proportions are reported as
#' indicators whose mean is the proportion. The spread of the selected weight,
#' which no mean can give, comes from `quantile_summary_columns` instead.
#'
#' `prior_weight` is the posterior probability that the treatment effect came
#' from the informative component, which is what the robust mixture prior reports
#' under that name; the figures and tables that read it therefore work unchanged.
#' It is not the selected prior weight, which is `informative_prior_weight`.
#'
#' @param informative_posterior_weight Posterior probability of the informative
#'   component.
#' @param selection A data frame from [egidi_select_weak_weight()].
#' @return A data frame with one row per replicate.
#' @keywords internal
egidi_posterior_parameters <- function(informative_posterior_weight, selection) {
  parameters <- data.frame(
    prior_weight = informative_posterior_weight,
    psi_weak = selection$psi_weak,
    informative_prior_weight = 1 - selection$psi_weak,
    psi_weak_is_zero = as.numeric(selection$psi_weak <= 0),
    psi_weak_is_one = as.numeric(selection$psi_weak >= 1),
    initial_conflict = as.numeric(selection$initial_conflict),
    conflict_unresolved = as.numeric(selection$conflict_unresolved),
    pvalue_informative = selection$pvalue_informative,
    pvalue_selected = selection$pvalue_selected
  )
  parameters
}

#' An empty selection, for a model that has not seen data yet
#'
#' @return A one-row data frame of missing values shaped like
#'   [egidi_select_weak_weight()]'s.
#' @keywords internal
egidi_empty_selection <- function() {
  data.frame(
    psi_weak = NA_real_, pvalue_informative = NA_real_, pvalue_weak = NA_real_,
    pvalue_selected = NA_real_, initial_conflict = NA, conflict_unresolved = NA
  )
}

#' Read the Egidi method parameters from a configuration
#'
#' @param method_parameters The method's entry in the configuration.
#' @return A list with `alpha_pc`, `pvalue_method` and `weight_grid_step`.
#' @keywords internal
egidi_method_settings <- function(method_parameters) {
  value <- function(name, default) {
    if (is.null(method_parameters[[name]])) default else unlist(method_parameters[[name]])[[1]]
  }

  # The weak component is the robust mixture prior's, which every shipped
  # configuration derives from the observed replicate. A fixed weak component
  # would make the prior-predictive of the weak component independent of the
  # replicate, which is a different method and is not what this one compares to.
  if (!isTRUE(value("empirical_bayes", TRUE))) {
    stop(
      "The Egidi mixture prior uses the robust mixture prior's empirical Bayes ",
      "weak component, so empirical_bayes must be TRUE.",
      call. = FALSE
    )
  }

  # The conflict p-value is exact for both summary measures - deterministic for
  # the normal one, an enumeration of the sample space for the binary one - so
  # the simulation never needs the Monte Carlo fallback, and accepting the
  # setting here would silently ignore it. It stays reachable through
  # fit_egidi_mixture(), which is where it is useful as a cross-check.
  pvalue_method <- value("pvalue_method", "exact")
  if (!identical(pvalue_method, "exact")) {
    stop(
      "The Egidi mixture prior computes the conflict p-value exactly in the ",
      "simulation, so pvalue_method must be \"exact\"; pass pvalue_method = ",
      "\"mc\" to fit_egidi_mixture() for the simulation fallback.",
      call. = FALSE
    )
  }

  list(
    alpha_pc = value("alpha_pc", 0.05),
    pvalue_method = pvalue_method,
    weight_grid_step = value("weight_grid_step", 0.001)
  )
}

#' GaussianEgidiMixture class
#'
#' @description The empirical mixture prior of Egidi, Pauli and Torelli for a
#' normal summary measure.
#'
#' @details
#' The prior is the robust mixture prior's,
#' \deqn{\pi_\psi(\theta_T) = \psi q(\theta_T) + (1 - \psi) p(\theta_T),}
#' with the same informative component \eqn{p} centred on the source estimate and
#' the same weak component \eqn{q}. Only the weight differs: instead of being
#' prespecified, \eqn{\psi} is the smallest weight on the weak component at which
#' the prior-predictive conflict p-value reaches `alpha_pc`, computed separately
#' for every replicate from that replicate's own target estimate and standard
#' error.
#'
#' The class inherits from [GaussianRMP_RBesT] and supplies the weight it would
#' otherwise read from the configuration. Because the robust mixture prior
#' parameterises its mixture by the weight on the *informative* component, the
#' weight handed over is \eqn{1 - \hat\psi}. Everything after that - the conjugate
#' update, the credible interval, the decision rule, the effective sample sizes -
#' is the inherited code, so the two methods differ only in where the weight comes
#' from.
#'
#' This is an empirically adaptive procedure. The target data are used first to
#' select the weight and then again to update the posterior, which is intentional
#' and is what distinguishes the method from a robust mixture prior with a
#' prespecified weight. `psi_weak` should not be described as a prior probability
#' chosen before the target data were observed.
#'
#' @field alpha_pc Prior-predictive conflict threshold.
#' @field pvalue_method How the conflict p-value is computed.
#' @field weight_grid_step Resolution of the weight scan.
#' @field weight_scan_step Resolution of the coarse stage of the weight scan.
#' @field selection The per-replicate selection, cached so that the scalar and
#'   vectorised paths report the same numbers they priced the prior with.
#' @field quantile_summary_columns Posterior parameters also summarised by
#'   quantile, which for this method is the selected weight.
#' @field method Method name.
#'
#' @export
GaussianEgidiMixture <- R6::R6Class(
  "GaussianEgidiMixture",
  inherit = GaussianRMP_RBesT,
  public = list(
    alpha_pc = NULL,
    pvalue_method = NULL,
    weight_grid_step = NULL,
    weight_scan_step = NULL,
    selection = NULL,
    quantile_summary_columns = "psi_weak",
    method = "egidi_empirical_mixture",

    #' @description Initialize a new GaussianEgidiMixture object.
    #' @param prior A list containing prior information for the analysis.
    initialize = function(prior) {
      settings <- egidi_method_settings(prior$method_parameters)

      # The weight is not known until the target data are observed, which is the
      # state the inherited constructor already has a route for: its empirical
      # Bayes branch defers building the prior. Standing in a missing weight
      # keeps that branch and makes a premature use of it an error rather than a
      # silent number.
      prior$method_parameters$prior_weight <- NA_real_
      prior$method_parameters$empirical_bayes <- TRUE
      super$initialize(prior)

      self$alpha_pc <- settings$alpha_pc
      self$pvalue_method <- settings$pvalue_method
      self$weight_grid_step <- settings$weight_grid_step
      self$weight_scan_step <- min(1, 20 * settings$weight_grid_step)
      self$selection <- egidi_empty_selection()
      self$posterior_parameters <- egidi_posterior_parameters(
        NA_real_, self$selection
      )
    },

    #' @description Select the mixture weight for a replicate and build its prior.
    #'
    #' The weak component's variance is derived from the replicate first, because
    #' it sets the weak component's prior-predictive and so enters the conflict
    #' p-value. The inherited method then re-derives it by the same rule and
    #' assembles the mixture with the selected weight.
    #'
    #' @param target_data A list containing the target data for the analysis.
    empirical_bayes_update = function(target_data) {
      standard_error <- target_data$sample$treatment_effect_standard_error
      weak_variance <- standard_error^2 * target_data$sample_size_per_arm

      self$selection <- egidi_select_weak_weight(
        t_obs = target_data$sample$treatment_effect_estimate,
        s_target = standard_error,
        mu_p = self$info_prior_mean,
        tau_p = sqrt(self$info_prior_variance),
        mu_q = self$vague_prior_mean,
        tau_q = sqrt(weak_variance),
        alpha_pc = self$alpha_pc,
        weight_grid_step = self$weight_grid_step,
        weight_scan_step = self$weight_scan_step
      )
      self$w <- 1 - self$selection$psi_weak

      super$empirical_bayes_update(target_data)
    },

    #' @description Calculate the posterior moments based on the target data.
    #' @param target_data A list containing the target data for the analysis.
    posterior_moments = function(target_data) {
      super$posterior_moments(target_data)
      self$posterior_parameters <- egidi_posterior_parameters(
        informative_posterior_weight = self$wpost,
        selection = self$selection
      )
    },

    #' @description Prior mixture components for each replicate.
    #'
    #' The weight varies by replicate, so the mixture is returned as matrices with
    #' one row each. The component order is the inherited one, informative first,
    #' which is what makes the posterior weight the inherited code reports the
    #' probability of the informative component.
    #'
    #' @param target_data Target data for the analysis.
    #' @param samples Data frame of generated replicates.
    #' @return A list with `weights`, `means` and `sds`.
    vectorised_prior_components = function(target_data, samples) {
      n_replicates <- nrow(samples)
      standard_error <- samples$treatment_effect_standard_error
      weak_variance <- standard_error^2 * target_data$sample_size_per_arm

      self$selection <- egidi_select_weak_weight(
        t_obs = samples$treatment_effect_estimate,
        s_target = standard_error,
        mu_p = self$info_prior_mean,
        tau_p = sqrt(self$info_prior_variance),
        mu_q = self$vague_prior_mean,
        tau_q = sqrt(weak_variance),
        alpha_pc = self$alpha_pc,
        weight_grid_step = self$weight_grid_step,
        weight_scan_step = self$weight_scan_step
      )

      list(
        weights = cbind(1 - self$selection$psi_weak, self$selection$psi_weak),
        means = cbind(rep(self$info_prior_mean, n_replicates),
                      rep(self$vague_prior_mean, n_replicates)),
        sds = cbind(rep(sqrt(self$info_prior_variance), n_replicates),
                    sqrt(weak_variance))
      )
    },

    #' @description Posterior parameters reported by the vectorised path.
    #' @param posterior Posterior mixture from [normal_mixture_posterior()].
    #' @return A data frame with one row per replicate.
    vectorised_posterior_parameters = function(posterior) {
      egidi_posterior_parameters(
        informative_posterior_weight = posterior$weights[, 1],
        selection = self$selection
      )
    }
  )
)

#' TruncatedEgidiMixture class
#'
#' @description The empirical mixture prior of Egidi, Pauli and Torelli for a
#' two-arm binary endpoint.
#'
#' @details
#' The analysis model is the robust mixture prior's: a normal mixture on the rate
#' difference, each component truncated to the range the control rate leaves it,
#' observed through two binomial arms. Only the weight differs.
#'
#' The target statistic is the pair of responder counts, whose sample space is
#' finite, so the conflict p-value is the exact sum of the joint prior-predictive
#' probabilities at or below the observed pair. No conflict statistic is
#' substituted for the counts and nothing is simulated.
#'
#' The component tables are fixed by the arm sizes and the component, so the
#' informative one is built once. The weak component's scale is re-derived from
#' each replicate, so its table is cached against a rounded scale: the weak
#' component is a deliberately diffuse unit-information prior whose scale is a
#' modelling choice, and rounding it by a fraction of a percent cannot move the
#' selected weight, while rebuilding the table for every replicate would dominate
#' the run.
#'
#' @field alpha_pc Prior-predictive conflict threshold.
#' @field pvalue_method How the conflict p-value is computed.
#' @field weight_grid_step Resolution of the weight scan.
#' @field table_scale_tolerance Relative resolution at which the weak component's
#'   scale is cached. Zero rebuilds the table for every replicate.
#' @field selection The per-replicate selection.
#' @field quantile_summary_columns Posterior parameters also summarised by
#'   quantile, which for this method is the selected weight.
#' @field method Method name.
#'
#' @export
TruncatedEgidiMixture <- R6::R6Class(
  "TruncatedEgidiMixture",
  inherit = TruncatedGaussianRMP,
  public = list(
    alpha_pc = NULL,
    pvalue_method = NULL,
    weight_grid_step = NULL,
    table_scale_tolerance = 0.0025,
    selection = NULL,
    quantile_summary_columns = "psi_weak",
    method = "egidi_empirical_mixture",

    #' @description Initialize a new TruncatedEgidiMixture object.
    #' @param prior A list containing prior information for the analysis.
    #' @param mcmc_config The MCMC configuration parameters.
    initialize = function(prior, mcmc_config) {
      settings <- egidi_method_settings(prior$method_parameters)

      prior$method_parameters$prior_weight <- NA_real_
      prior$method_parameters$empirical_bayes <- TRUE
      super$initialize(prior = prior, mcmc_config = mcmc_config)

      self$alpha_pc <- settings$alpha_pc
      self$pvalue_method <- settings$pvalue_method
      self$weight_grid_step <- settings$weight_grid_step
      self$selection <- egidi_empty_selection()
      self$method <- "egidi_empirical_mixture"
      self$posterior_parameters <- egidi_posterior_parameters(
        NA_real_, self$selection
      )
      private$tables <- list()
    },

    #' @description Select the mixture weight for a replicate.
    #' @param target_data The target data for the inference.
    empirical_bayes_update = function(target_data) {
      standard_error <- target_data$sample$treatment_effect_standard_error
      weak_variance <- standard_error^2 * target_data$sample_size_per_arm

      n_control <- as.integer(target_data$sample_size_control)
      n_treatment <- as.integer(target_data$sample_size_treatment)
      y_control <- as.integer(n_control * target_data$sample$sample_control_rate)
      y_treatment <- as.integer(n_treatment * target_data$sample$sample_treatment_rate)

      informative_sd <- sqrt(self$info_prior_variance)
      weak_sd <- sqrt(weak_variance)
      n_nodes <- egidi_binomial_nodes(
        c(informative_sd, weak_sd), n_control, n_treatment
      )

      self$selection <- egidi_select_weak_weight_binomial(
        table_informative = private$table_for(
          self$info_prior_mean, informative_sd, n_control, n_treatment, n_nodes
        ),
        table_weak = private$table_for(
          self$vague_prior_mean, weak_sd, n_control, n_treatment, n_nodes
        ),
        y_control = y_control,
        y_treatment = y_treatment,
        alpha_pc = self$alpha_pc,
        weight_grid_step = self$weight_grid_step
      )
      self$w <- 1 - self$selection$psi_weak

      super$empirical_bayes_update(target_data)
    },

    #' @description Inference.
    #'
    #' The inherited method reports the posterior probability that the treatment
    #' effect came from the informative component, computed over the same
    #' truncated mixture and counts the sampler was given. The selection is
    #' reported alongside it.
    #'
    #' @param target_data Target data object.
    #' @return Indicator whether inference succeeded or not.
    inference = function(target_data) {
      fit_success <- super$inference(target_data)
      self$posterior_parameters <- egidi_posterior_parameters(
        informative_posterior_weight = self$posterior_parameters$prior_weight,
        selection = self$selection
      )
      fit_success
    }
  ),
  private = list(
    tables = NULL,

    #' Cached joint prior-predictive table of one component.
    table_for = function(mu, sd, n_control, n_treatment, n_nodes) {
      rounded <- if (self$table_scale_tolerance > 0) {
        signif(sd, max(1, ceiling(-log10(self$table_scale_tolerance))))
      } else {
        sd
      }
      key <- paste(mu, rounded, n_control, n_treatment, n_nodes, sep = "/")
      if (is.null(private$tables[[key]])) {
        private$tables[[key]] <- egidi_binomial_predictive_table(
          mu = mu, sd = rounded, n_control = n_control,
          n_treatment = n_treatment, n_nodes = n_nodes
        )
      }
      private$tables[[key]]
    }
  )
)
