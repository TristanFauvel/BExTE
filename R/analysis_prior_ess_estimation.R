#' Calculate the moment-based Effective Sample Size (ESS) for a Gaussian mixture.
#'
#' @description This function calculates the moment-based ESS for a Gaussian mixture distribution.
#' It takes a mixture object and an optional prior reference scale as input and returns the ESS.
#'
#' @param mix A mixture object.
#' @return The moment-based ESS for the Gaussian mixture.
#' @keywords internal
gaussian_mix_moment_ess <- function(mix) {
  sigma <- RBesT::sigma(mix)
  if (is.null(sigma)) {
    stop("Reference scale is NULL, must be a number for ESS estimation")
  }

  ## simple and conservative moment matching
  smix <- summary(mix)
  res <- sigma ^ 2 / smix["sd"] ^ 2
  return(unname(res))
}

#' Calculate the precision-based Effective Sample Size (ESS) for a Gaussian mixture.
#'
#' @description This function calculates the precision-based ESS for a Gaussian mixture distribution.
#' It takes a mixture object and an optional prior reference scale as input and returns the ESS.
#'
#' @param mix A mixture object.
#' @param level Level of the credible interval used for precision matching.
#' @return The precision-based ESS for the Gaussian mixture.
#' @keywords internal
gaussian_mix_precision_ess <- function(mix, level = 0.95) {
  # Precision-based matching method for ESS estimation, for Gaussian mixtures only.
  sigma <- RBesT::sigma(mix)
  if (is.null(sigma)) {
    stop("Reference scale is NULL, must be a number of ESS estimation")
  }

  alpha <- (1 - level) / 2
  bounds <- if (level == 0.95) {
    smix <- summary(mix)
    as.numeric(smix[c(grep("2.5%", names(smix)), grep("97.5%", names(smix)))])
  } else {
    RBesT::qmix(mix, c(alpha, 1 - alpha))
  }
  half_width <- (bounds[2] - bounds[1]) / 2
  sd <- half_width / stats::qnorm(1 - alpha)

  res <- sigma ^ 2 / sd ^ 2
  return(unname(res))
}

#' Calculate the prior moment-based Effective Sample Size (ESS) for a Bayesian model.
#'
#' @description This function calculates the prior moment-based ESS for a Bayesian model using the RBesT package.
#' It takes a RBesT model object and target data as input and returns the prior moment-based ESS.
#'
#' @param rbest_model A RBesT model object.
#' @param target_data Target data containing sample information.
#' @return The prior moment-based ESS for the Bayesian model.
#' @keywords internal
prior_moment_ess <- function(rbest_model, target_data) {
  if (is.null(rbest_model)) {
    stop("The posterior is NULL")
  }

  posterior_moment_ess <- RBesT::ess(rbest_model,
                                     method = "moment",
                                     sigma = RBesT::sigma(rbest_model))

  return(posterior_moment_ess - target_effective_arm_size(target_data))
}

#' Calculate the prior precision-based Effective Sample Size (ESS) for a Bayesian model.
#'
#' @description This function calculates the prior precision-based ESS for a Bayesian model using the RBesT package.
#' It takes a RBesT model object and target data as input and returns the prior precision-based ESS.
#'
#' @param rbest_model A RBesT model object.
#' @param target_data Target data containing sample information.
#' @param level Level of the credible interval used for precision matching.
#' @return The prior precision-based ESS for the Bayesian model.
#' @keywords internal
prior_precision_ess <- function(rbest_model, target_data, level = 0.95) {
  if (target_data$summary_measure_likelihood == "normal") {
    posterior_precision_ess <- gaussian_mix_precision_ess(rbest_model, level = level)
  } else if (target_data$summary_measure_likelihood == "binomial") {
    posterior_precision_ess <- gaussian_mix_precision_ess(rbest_model, level = level)
  }
  return(posterior_precision_ess - target_effective_arm_size(target_data))
}


#' Calculate the priorEffective Sample Size (ESS) based on ELIR for a Bayesian model.
#'
#' @description This function calculates the ELIR for a Bayesian model using the RBesT package.
#' It takes a RBesT model object and target data as input and returns the prior moment-based ESS.
#'
#' @param rbest_model A RBesT model object.
#' @param target_data Target data containing sample information.
#' @return The prior moment-based ESS for the Bayesian model.
#' @keywords internal
prior_ess_elir <- function(rbest_model, target_data) {
  if (is.null(rbest_model)) {
    stop("The prior is NULL")
  }

  return(tryCatch({
    elir <- RBesT::ess(rbest_model, method = "elir", sigma = RBesT::sigma(rbest_model))
    return(elir)
  }, error = function(e) {
    model_summary <- summary(rbest_model)
    if (model_summary['sd'] == "Inf"){
      return(0)
    } else {
      # When an error occurs, print the error and return NA
      message("An error occurred: ", e$message)
      return(NA)
    }
  }))
}


#' Effective sample sizes of a posterior summarised against a normal reference
#'
#' @description Both effective sample sizes reported per replicate compare the
#' posterior against a normal reference of known scale. The moment version uses
#' the posterior variance directly; the precision version uses the variance a
#' normal distribution would need in order to have the same credible interval
#' width at `level`. Both are expressed relative to the target study, by
#' subtracting its per-arm sample size.
#'
#' Models whose posterior summary is available exactly, or already computed,
#' evaluate these definitions directly rather than fitting a mixture to samples
#' drawn from the posterior.
#'
#' @param reference_scale Reference scale, i.e. the sampling standard deviation
#'   of the target study.
#' @param posterior_sd Standard deviation of the posterior treatment effect.
#' @param lower Lower bound of the credible interval.
#' @param upper Upper bound of the credible interval.
#' @param sample_size_per_arm Equivalent sample size per arm of the target
#'   study (see `effective_arm_size()`), the unit the ESS is counted in.
#' @param level Level of the credible interval.
#' @return A list with the `moment` and `precision` effective sample sizes.
#' @keywords internal
normal_reference_ess <- function(reference_scale,
                                 posterior_sd,
                                 lower,
                                 upper,
                                 sample_size_per_arm,
                                 level = 0.95) {
  implied_sd <- ((upper - lower) / 2) / stats::qnorm((1 + level) / 2)

  return(list(
    moment = reference_scale^2 / posterior_sd^2 - sample_size_per_arm,
    precision = reference_scale^2 / implied_sd^2 - sample_size_per_arm
  ))
}
