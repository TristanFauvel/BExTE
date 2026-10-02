#' Calculate the variance of a mixture distribution
#'
#' This function computes the variance of a mixture of two distributions.
#'
#' @param w Numeric. The weight of the first distribution in the mixture.
#' @param sigma2A Numeric. The variance of the first distribution.
#' @param muA Numeric. The mean of the first distribution.
#' @param sigma2B Numeric. The variance of the second distribution.
#' @param muB Numeric. The mean of the second distribution.
#'
#' @return Numeric. The total variance of the mixture distribution.
#'
#' @keywords internal
mixture_variance <- function(w, sigma2A, muA, sigma2B, muB) {
  # Weighted sum of the variances
  weighted_var_sum <- w * sigma2A + (1 - w) * sigma2B

  # Weighted sum of the square of the means
  weighted_mean_sq_sum <- w * muA ^ 2 + (1 - w) * muB ^ 2

  # Square of the weighted sum of the means
  mean_weighted_sum_sq <- (w * muA + (1 - w) * muB) ^ 2

  # Total variance of the mixture
  variance <- weighted_var_sum + weighted_mean_sq_sum - mean_weighted_sum_sq

  return(variance)
}


#' GaussianRMP_RBesT class
#'
#' This class represents a Gaussian Robust Mixture Prior model.
#' It inherits from the Model class. Inference is performed using RBesT.
#'
#' @description
#' A class for Gaussian Robust Mixture Prior models using RBesT for inference.
#'
#' @details
#' This class extends the Model_RBesT class and provides methods for
#' initializing the model, updating priors, calculating posterior moments,
#' and converting distributions to RBesT format.
#'
#' @field w The weight of the prior distribution.
#' @field vague_prior_mean The mean of the vague prior distribution.
#' @field vague_prior_variance The variance of the vague prior distribution.
#' @field info_prior_mean The mean of the informative prior distribution.
#' @field info_prior_variance The variance of the informative prior distribution.
#' @field wpost The weight of the posterior distribution.
#' @field vague_posterior_mean The mean of the vague posterior distribution.
#' @field info_posterior_mean The mean of the informative posterior distribution.
#' @field vague_posterior_variance The variance of the vague posterior distribution.
#' @field info_posterior_variance The variance of the informative posterior distribution.
#' @field method Method name
#'
#' @export
GaussianRMP_RBesT <- R6::R6Class(
  "GaussianRMP_RBesT",
  inherit = Model_RBesT,
  public = list(
    w = NULL,
    vague_prior_mean = NULL,
    vague_prior_variance = NULL,
    info_prior_mean = NULL,
    info_prior_variance = NULL,
    wpost = NULL,
    vague_posterior_mean = NULL,
    info_posterior_mean = NULL,
    vague_posterior_variance = NULL,
    info_posterior_variance = NULL,
    method = "RMP",

    #' @description
    #' Initialize a new GaussianRMP_RBesT object.
    #' @param prior A list containing prior information for the analysis.
    initialize = function(prior) {
      if (!(prior$method_parameters$initial_prior[[1]] == "noninformative")) {
        stop("Only implemented for a noninformative initial prior")
      }
      super$initialize(prior)
      self$w <- unlist(prior$method_parameters$prior_weight)
      self$vague_prior_mean <- prior$vague_mean

      self$info_prior_mean <- prior$source$treatment_effect_estimate
      self$info_prior_variance <- prior$source$standard_error ^ 2

      if (prior$method_parameters$empirical_bayes[[1]]) {
        self$empirical_bayes <- TRUE
        self$vague_prior_variance <- NULL
      } else {
        self$empirical_bayes <- FALSE
        self$vague_prior_variance <- prior$source$standard_error ^ 2 *
          prior$source$equivalent_source_sample_size_per_arm # information provided by a single subject per arm in the source study, corresponds to the approach used in Best et al, 2023 (Belimumab)

        self$prior_to_RBesT()

        prior_summary <- summary(self$RBesT_prior)

        self$prior_mean <- prior_summary['mean']
        self$prior_var <- prior_summary['sd']^2
      }

      self$wpost <- NULL
      self$vague_posterior_mean <- NULL
      self$vague_posterior_variance <- NULL
      self$info_posterior_mean <- NULL
      self$info_posterior_variance <- NULL

      self$posterior_parameters <- list(prior_weight = NA)
    },

    #' @description
    #' Update the vague prior variance based on empirical Bayes approach.
    #' @param target_data A list containing the target data for the analysis.
    empirical_bayes_update = function(target_data) {
      if (self$empirical_bayes) {
        self$vague_prior_variance <- (target_data$sample$treatment_effect_standard_error ^
                                        2) * target_data$sample_size_per_arm # sample standard deviation in the target study

        # information provided by a single subject per arm in the target study (as explained in the protocol)
        # Note that in Best et al, 2021 (Mepolizumab), this is the information provided by a single subject in the target study

        info <- c(
          self$w,
          self$info_prior_mean,
          sqrt(self$info_prior_variance)
        )

        vague <- c(
          1 - self$w,
          self$vague_prior_mean,
          sqrt(self$vague_prior_variance)
        )

        # We use the following conditions to avoid bug in RBesT ELIR computation if self$wpost == 0
        if (self$w == 1){
          self$RBesT_prior <- RBesT::mixnorm(
            info = info
          )
        } else if (self$w == 0){
          self$RBesT_prior <- RBesT::mixnorm(
            vague = vague
          )
        } else {
          self$RBesT_prior <- RBesT::mixnorm(
            info = info,
            vague = vague
          )
        }

        prior_summary <- summary(self$RBesT_prior)
        self$prior_mean <- prior_summary['mean']
        self$prior_var <- prior_summary['sd']^2

        RBesT::sigma(self$RBesT_prior) <- target_data$sample$standard_deviation

        self$RBesT_prior_normix <- self$RBesT_prior
      } else {
        if (is.null(self$vague_prior_variance)) {
          stop("The vague prior variance must be defined if empirical_bayes is False") # information provided by a single subject per arm in the source study : Best et al (2023, case study on Belimumab)
        }
      }
    },

    #' @description
    #' Calculate the posterior moments based on the target data.
    #' @param target_data A list containing the target data for the analysis.
    posterior_moments = function(target_data) {
      self$RBesT_posterior <- RBesT::postmix(
        self$RBesT_prior,
        m = target_data$sample$treatment_effect_estimate,
        se = target_data$sample$treatment_effect_standard_error
      )

      inference_results <- summary(self$RBesT_posterior)
      names(inference_results) <- c("mean", "standard_deviation", "cri95L", "median", "cri95U")
      self$posterior_summary <- inference_results

      # The following if statement is used because of a bug in the computation of ELIR with RBesT that requires to define a single component of the RMP if w = 0 or w = 1
      if (self$w == 0){
        self$wpost <- 0
        self$vague_posterior_mean <-  self$RBesT_posterior[2]
        self$vague_posterior_variance <- self$RBesT_posterior[3]^ 2
      } else if (self$w == 1){
        self$wpost <- 1
        self$info_posterior_mean <-  self$RBesT_posterior[2]
        self$info_posterior_variance <- self$RBesT_posterior[3]^ 2
      } else {
        self$wpost <- self$RBesT_posterior[1]
        self$info_posterior_mean <- self$RBesT_posterior[2]
        self$info_posterior_variance <- self$RBesT_posterior[3] ^ 2
        self$vague_posterior_mean <- self$RBesT_posterior[5]
        self$vague_posterior_variance <- self$RBesT_posterior[6]^ 2
      }

      self$posterior_parameters$prior_weight <- self$wpost

      self$post_mean <- self$posterior_summary["mean"]

      self$post_var <- unname(self$posterior_summary["standard_deviation"] ^ 2)
      self$post_median <- self$posterior_summary["median"]
      assert_single_number(self$post_mean)
    },


    #' @description
    #' Convert the prior distribution to the RBesT format.
    #' @param ... Additional arguments.
    prior_to_RBesT = function(...) {
      if (is.null(self$vague_prior_variance)) {
        stop(
          "The vague prior variance must be defined. If empirical_bayes == TRUE, the prior can only be fully specified after the data has been observed."
        )
      }

      info = c(
        self$w,
        self$info_prior_mean,
        sqrt(self$info_prior_variance)
      )

      vague = c(
        1 - self$w,
        self$vague_prior_mean,
        sqrt(self$vague_prior_variance)
      )

      # We use the following conditions to avoid bug in RBesT ELIR computation if self$wpost == 0
      if (self$w == 1){
        self$RBesT_prior <- RBesT::mixnorm(
          info = info
        )
      } else if (self$w == 0){
        self$RBesT_prior <- RBesT::mixnorm(
          vague = vague
        )
      } else {
        self$RBesT_prior <- RBesT::mixnorm(
          info = info,
          vague = vague
        )
      }

      self$RBesT_prior_normix <- self$RBesT_prior
      return(self$RBesT_prior)
    },

    #' @description
    #' Convert the posterior distribution to the RBesT format.
    #' @param target_data Target data for the analysis.
    #' @param ... Additional arguments.
    posterior_to_RBesT = function(target_data, ...) {
      RBesT::sigma(self$RBesT_posterior) = target_data$sample$standard_deviation

      self$RBesT_posterior_normix <- self$RBesT_posterior

      return(self$RBesT_posterior)
    },

    #' @description
    #' Prior mixture components for each replicate.
    #'
    #' Under empirical Bayes the vague component's variance is re-derived from
    #' each replicate, matching `empirical_bayes_update()`, so the prior varies
    #' by row. Otherwise the same two components serve every replicate.
    #'
    #' A degenerate weight collapses the mixture to a single component, exactly
    #' as the scalar path does to work around an RBesT ELIR bug.
    #'
    #' @param target_data Target data for the analysis.
    #' @param samples Data frame of generated replicates.
    #' @return A list with `weights`, `means` and `sds`.
    vectorised_prior_components = function(target_data, samples) {
      n_replicates <- nrow(samples)

      if (self$w == 1) {
        return(list(weights = 1,
                    means = self$info_prior_mean,
                    sds = sqrt(self$info_prior_variance)))
      }

      vague_variance <- if (self$empirical_bayes) {
        samples$treatment_effect_standard_error^2 * target_data$sample_size_per_arm
      } else {
        self$vague_prior_variance
      }

      if (self$w == 0) {
        return(list(weights = matrix(1, nrow = n_replicates, ncol = 1),
                    means = matrix(self$vague_prior_mean, nrow = n_replicates, ncol = 1),
                    sds = matrix(sqrt(rep_len(vague_variance, n_replicates)), nrow = n_replicates, ncol = 1)))
      }

      list(
        weights = cbind(rep(self$w, n_replicates), rep(1 - self$w, n_replicates)),
        means = cbind(rep(self$info_prior_mean, n_replicates),
                      rep(self$vague_prior_mean, n_replicates)),
        sds = cbind(rep(sqrt(self$info_prior_variance), n_replicates),
                    sqrt(rep_len(vague_variance, n_replicates)))
      )
    },

    #' @description
    #' Posterior parameters reported by the vectorised path.
    #'
    #' The scalar path records the posterior weight on the informative
    #' component, which is 0 or 1 when the mixture has collapsed.
    #'
    #' @param posterior Posterior mixture from [normal_mixture_posterior()].
    #' @return A data frame with one `prior_weight` column.
    vectorised_posterior_parameters = function(posterior) {
      prior_weight <- if (self$w == 0) {
        rep(0, nrow(posterior$weights))
      } else if (self$w == 1) {
        rep(1, nrow(posterior$weights))
      } else {
        posterior$weights[, 1]
      }

      data.frame(prior_weight = prior_weight)
    },


    #' @description
    #' Rows of the model summary, with the prior weight and the moments of the
    #' two posterior components. The posterior weight is among the
    #' `posterior_parameters` rows.
    #' @return A data frame with columns `Attribute` and `Value`.
    summary_rows = function() {
      rbind(
        super$summary_rows(),
        summary_row("Prior Weight", self$w),
        summary_row("Vague Posterior Mean", self$vague_posterior_mean),
        summary_row("Vague Posterior Variance", self$vague_posterior_variance),
        summary_row("Informative Posterior Mean", self$info_posterior_mean),
        summary_row("Informative Posterior Variance", self$info_posterior_variance)
      )
    }
  )
)
