#' @title DesignPrior Class
#' @description A class representing the design prior for Bayesian borrowing.
#' @field design_prior_type Type of design prior.
#' @field RBesT_model RBesT version of the model.
#' @export
DesignPrior <- R6::R6Class(
  "DesignPrior",
  public = list(
    design_prior_type = NULL,
    RBesT_model = NULL,

    #' @description Creates a new instance of DesignPrior.
    #' @param design_prior_type The type of design prior.
    #' @param model The model object.
    #' @param source_data The source data object.
    #' @param case_study_config Case study configuration
    #' @param simulation_config Simulation configuration
    #' @param mcmc_config MCMC configuration
    #' @param case_study Case study name
    #' @param target_control_rate The control response rate of the simulated
    #'   trials, or `NULL`. Under a binomial likelihood the treatment effect is a
    #'   difference in response rates, and the simulated trials, whose control
    #'   rate is fixed, can only have an effect in
    #'   `(-target_control_rate, 1 - target_control_rate)`; the design prior is
    #'   then taken given that control rate - see `given_control_rate()`.
    #' @return A new instance of DesignPrior.
    create = function(design_prior_type,
                      model,
                      source_data,
                      case_study_config,
                      simulation_config,
                      mcmc_config,
                      case_study,
                      target_control_rate = NULL) {
      if (design_prior_type == "ui_design_prior") {
        design_prior <- UnitInformationDesignPrior$new(
          source_data = source_data,
          case_study_config = case_study_config,
          case_study = case_study,
          simulation_config = simulation_config,
          mcmc_config = mcmc_config
        )
      } else if (design_prior_type == "analysis_prior") {
        if (model$empirical_bayes) {
          stop("Analysis prior cannot be used as a design prior for methods that rely on empirical Bayes.")
        }

        design_prior <- AnalysisPriorDesignPrior$new(
          model = model,
          case_study_config = case_study_config,
          simulation_config = simulation_config,
          mcmc_config = mcmc_config
        )
      } else if (design_prior_type == "source_posterior") {
        design_prior <- SourcePosteriorDesignPrior$new(
          source_data = source_data,
          case_study_config = case_study_config,
          simulation_config = simulation_config,
          mcmc_config = mcmc_config
        )
      } else {
        stop("Not implemented for other types of design prior.")
      }

      if (!is.null(target_control_rate) &&
          identical(case_study_config$summary_measure_likelihood, "binomial")) {
        design_prior <- design_prior$given_control_rate(target_control_rate)
      }
      return(design_prior)
    },

    #' @description The design prior given the target control rate
    #'
    #' A difference in response rates is confined to
    #' `(-control_rate, 1 - control_rate)` once the control rate is known. A
    #' design prior defined on the treatment effect alone has no joint
    #' distribution with the control rate to condition, so it is truncated to
    #' that range and renormalised. Subclasses that can condition exactly
    #' override this.
    #'
    #' @param control_rate The target control rate.
    #' @return A [FunctionalDesignPrior].
    given_control_rate = function(control_rate) {
      truncated_design_prior(self, lower = -control_rate, upper = 1 - control_rate)
    },

    #' @description Samples from the design prior.
    #' @param n_samples The number of samples to generate.
    sample = function(n_samples) {
      stop("The subclass must implement a sample() method")
    },

    #' @description Computes the cumulative distribution function (CDF) of the design prior.
    #' @param x The value at which to evaluate the CDF.
    cdf = function(x) {
      stop("The subclass must implement a cdf() method")
    },

    #' @description Computes the PDF of the design prior.
    #' @param x The value at which to evaluate the PDF.
    pdf = function(x) {
      stop("The subclass must implement a pdf() method")
    }
  )
)


#' @title FunctionalDesignPrior class
#' @description A design prior given by its distribution functions, as the
#'   design priors conditioned on the target control rate are.
#' @field cdf_function Distribution function of the treatment effect.
#' @field pdf_function Density of the treatment effect.
#' @field sample_function Function of the number of draws returning draws.
#' @keywords internal
FunctionalDesignPrior <- R6::R6Class(
  "FunctionalDesignPrior",
  inherit = DesignPrior,
  public = list(
    cdf_function = NULL,
    pdf_function = NULL,
    sample_function = NULL,

    #' @description Creates a design prior from its distribution functions.
    #' @param cdf,pdf,sample The distribution function, density and sampler.
    #' @param design_prior_type The type of design prior it stands for.
    initialize = function(cdf, pdf, sample, design_prior_type) {
      self$cdf_function <- cdf
      self$pdf_function <- pdf
      self$sample_function <- sample
      self$design_prior_type <- design_prior_type
    },

    #' @description Samples from the design prior.
    #' @param n_samples The number of samples to generate.
    sample = function(n_samples) self$sample_function(n_samples),

    #' @description The distribution function of the design prior.
    #' @param x The value at which to evaluate it.
    cdf = function(x) self$cdf_function(x),

    #' @description The density of the design prior.
    #' @param x The value at which to evaluate it.
    pdf = function(x) self$pdf_function(x)
  )
)


#' A design prior truncated to an interval and renormalised
#'
#' @param design_prior The design prior to truncate.
#' @param lower,upper The interval.
#' @return A [FunctionalDesignPrior].
#' @keywords internal
truncated_design_prior <- function(design_prior, lower, upper) {
  mass_below <- design_prior$cdf(lower)
  mass <- design_prior$cdf(upper) - mass_below
  if (!is.finite(mass) || mass <= 0) {
    stop("The design prior has no mass between ", lower, " and ", upper, ".", call. = FALSE)
  }

  FunctionalDesignPrior$new(
    cdf = function(x) {
      (design_prior$cdf(pmin(pmax(x, lower), upper)) - mass_below) / mass
    },
    pdf = function(x) {
      ifelse(x > lower & x < upper, design_prior$pdf(x) / mass, 0)
    },
    sample = function(n_samples) {
      # Rejection from the untruncated prior, drawing enough each round for the
      # mass kept.
      kept <- numeric(0)
      while (length(kept) < n_samples) {
        draws <- design_prior$sample(ceiling(1.2 * (n_samples - length(kept)) / mass) + 10)
        kept <- c(kept, draws[draws > lower & draws < upper])
      }
      kept[seq_len(n_samples)]
    },
    design_prior_type = design_prior$design_prior_type
  )
}


binomial_product_integral <- function(x,
                                      alpha_control,
                                      beta_control,
                                      alpha_treatment,
                                      beta_treatment) {
  epsilon <- 1e-8
  lower_limit <- max(epsilon, -x + epsilon)
  upper_limit <- min(1 - epsilon, 1 - x - epsilon)

  # Handle cases where lower_limit > upper_limit
  if (lower_limit >= upper_limit) {
    return(0)
  }

  # Perform integration with error handling
  result <- tryCatch({
    integrate(
      function(y) {
        # Ensure y is within [0, 1] to avoid non-finite values
        valid_range <- (y >= 0) &
          (y <= 1) & ((y + x) >= 0) & ((y + x) <= 1)
        # Return 0 for out-of-bound values
        ifelse(
          valid_range,
          dbeta(y, alpha_control, beta_control) * dbeta(y + x, alpha_treatment, beta_treatment),
          0
        )
      },
      lower = lower_limit,
      upper = upper_limit,
      subdivisions = 1000,
      rel.tol = .Machine$double.eps ^ 0.25
    )$value
  }, error = function(e) {
    warning(paste("Integration failed at x =", x, ":", e$message))
    futile.logger::flog.error(paste("Integration failed at x =", x, ":", e$message))
    return(NA)
  })
  return(result)
}

#' @title UnitInformationDesignPrior class
#' @description A class representing the unit information design prior for Bayesian borrowing.
#' @field parameters Parameters for the prior
#' @field summary_measure_likelihood Treatment effect distribution
#' @export
UnitInformationDesignPrior <- R6::R6Class(
  "UnitInformationDesignPrior",
  inherit = DesignPrior,
  public = list(
    parameters = NULL,
    summary_measure_likelihood = NULL,

    #' @description Initializes a new instance of UnitInformationDesignPrior.
    #' @param source_data The source data object.
    #' @param case_study_config Case study configuration.
    #' @param case_study Case study name
    #' @param simulation_config Simulation config
    #' @param mcmc_config MCMC configuration
    initialize = function(source_data,
                          case_study_config,
                          case_study,
                          simulation_config,
                          mcmc_config = NULL) {
      summary_measure_likelihood <- source_data$summary_measure_likelihood
      self$summary_measure_likelihood <- summary_measure_likelihood

      if (summary_measure_likelihood == "normal") {
        # Ideally the variance should depend on the target study variance, but we don't know it, and assyle that it is the same as the source study variance
        variance <- (
          source_data$standard_error ^ 2 * source_data$equivalent_source_sample_size_per_arm
        )
        self$parameters <- list(
          mean = source_data$treatment_effect_estimate,
          variance = variance,
          sd = sqrt(variance)
        ) # information provided by a single subject per arm in the source study
      } else if (summary_measure_likelihood == "binomial") {
        # Start by fitting a separate analysis model on the source data
        method_parameters <- list(initial_prior = "noninformative", empirical_bayes = FALSE)

        if (is.null(mcmc_config)) {
          stop("MCMC config is not provided.")
        }

        separate_model <- Model$new()
        separate_model <- separate_model$create(
          case_study_config = case_study_config,
          method = "separate",
          method_parameters = method_parameters,
          source_data = source_data,
          mcmc_config = mcmc_config
        )


        # The rationale is the following:
        # 1. Define a target data object with the same properties as the source study
        # 2. Perform a separate analysis
        # 3. Approximate the resulting posterior distribution with a mixture distribution
        # 4. Scale the parameters of the distribution to get a Unit Information distribution
        target_data <- TargetDataFactory$new()
        target_data <- target_data$create(
          source_data = source_data,
          case_study_config = case_study_config,
          target_sample_size_per_arm = source_data$equivalent_source_sample_size_per_arm,
          control_drift = 0, # The actual value does matter here as we set the treatment effect estimate after
          treatment_drift = 0, # The actual value does matter here as we set the treatment effect estimate after
          summary_measure_likelihood = case_study_config$summary_measure_likelihood,
          target_to_source_std_ratio = 1
        )

        # The target data object used for the analysis has the same properties as the source data, but centered in theta0.
        target_data$sample_size_treatment <- source_data$sample_size_treatment
        target_data$sample_size_control <- source_data$sample_size_control
        target_data$sample$sample_treatment_rate <- source_data$treatment_rate
        target_data$sample$sample_control_rate <- source_data$control_rate
        target_data$sample$sample_size_per_arm <- source_data$equivalent_source_sample_size_per_arm
        target_data$sample$treatment_effect_estimate <- case_study_config$theta_0
        target_data$sample$treatment_effect_standard_error <- source_data$standard_error

        # Perform inference using a separate analysis of the source study
        separate_model$inference(target_data)

        #  Convert the posterior to a mixture distribution and compute the prior ESS
        # The shape parameters are rescaled below, so this is the fit on the
        # response rate scale rather than the one on the treatment effect scale.
        mixture_approximation <- separate_model$posterior_beta_mixture(
          target_data = target_data,
          simulation_config = simulation_config
        )
        ESS <- RBesT::ess(mixture_approximation, method = "moment")

        # Extract the weights, a and b parameters
        weights <- mixture_approximation[1, ]
        a_params <- mixture_approximation[2, ]
        b_params <- mixture_approximation[3, ]

        # Adjust the a and b parameters by dividing by lambda
        a_params_new <- a_params / ESS
        b_params_new <- b_params / ESS


        # Create the new mixture of Beta distributions with adjusted parameters
        components_new <- lapply(1:length(weights), function(i) {
          c(weights[i], a_params_new[i], b_params_new[i])
        })

        # Construct the new mixture
        ui_mixture <- do.call(RBesT::mixbeta, components_new)

        self$RBesT_model <- ui_mixture

        # Check that the resulting distribution has an ESS of 1
        #RBesT::ess(ui_mixture, method = "moment")
      } else {
        stop("Other distributions not supported")
      }

      self$design_prior_type <- "ui_design_prior"
    },

    #' @description Samples from the unit information design prior.
    #' @param n_samples The number of samples to generate.
    sample = function(n_samples) {
      if (self$summary_measure_likelihood == "normal") {
        return(rnorm(n_samples, self$parameters$mean, self$parameters$sd))
      } else if (self$summary_measure_likelihood == "binomial") {
        transformed_samples <- RBesT::rmix(self$RBesT_model, n = n_samples)
        return(2 * transformed_samples - 1)
      } else {
        stop("Not implemented for other distributions.")
      }
    },

    #' @description Computes the cumulative distribution function (CDF) of the unit information design prior.
    #' @param x The value at which to evaluate the CDF.
    cdf = function(x) {
      if (self$summary_measure_likelihood == "normal") {
        return(pnorm(x, self$parameters$mean, self$parameters$sd))
      } else if (self$summary_measure_likelihood == "binomial") {
        result <- numeric(length(x))
        result[x >= 1] <- 1
        interior <- x > -1 & x < 1
        result[interior] <- RBesT::pmix(
          self$RBesT_model,
          q = (x[interior] + 1) / 2
        )
        return(result)
      } else {
        stop("Not implemented for other distributions.")
      }
    },

    #' @description Computes the cumulative distribution function (CDF) of the unit information design prior.
    #' @param x The value at which to evaluate the CDF.
    pdf = function(x) {
      if (self$summary_measure_likelihood == "normal") {
        return(dnorm(x, self$parameters$mean, self$parameters$sd))
      } else if (self$summary_measure_likelihood == "binomial") {
        result <- numeric(length(x))
        interior <- x > -1 & x < 1
        result[interior] <- RBesT::dmix(
          self$RBesT_model,
          x = (x[interior] + 1) / 2,
          log = FALSE
        ) / 2
        return(result)
      } else {
        stop("Not implemented for other distributions.")
      }
    }
  )
)

#' @title SourcePosteriorDesignPrior class
#' @description A class representing the source posterior design prior for Bayesian borrowing.
#' @field parameters Parameters
#' @field summary_measure_likelihood Treatment effect distribution
#' @field n_successes_control Number of successes in the control arm
#' @field n_successes_treatment Number of successes in the treatment arm
#' @field n_control Number of participants in the control arm
#' @field n_treatment Number of participants in the treatment arm
#' @export
SourcePosteriorDesignPrior <- R6::R6Class(
  "SourcePosteriorDesignPrior",
  inherit = DesignPrior,
  public = list(
    parameters = NULL,
    summary_measure_likelihood = NULL,
    n_successes_control = NULL,
    n_successes_treatment = NULL,
    n_control = NULL,
    n_treatment = NULL,

    #' @description Initializes a new instance of SourcePosteriorDesignPrior.
    #' @param source_data The source data object.
    #' @param case_study_config Case study configuration
    #' @param simulation_config Simulation configuration
    #' @param mcmc_config MCMC configuration
    initialize = function(source_data,
                          case_study_config,
                          simulation_config,
                          mcmc_config = NULL) {
      summary_measure_likelihood <- source_data$summary_measure_likelihood
      self$summary_measure_likelihood <- summary_measure_likelihood
      self$parameters <- list(
        mean = source_data$treatment_effect_estimate,
        variance = source_data$standard_error ^ 2,
        sd = source_data$standard_error
      )

      if (self$summary_measure_likelihood == "binomial") {
        self$n_successes_control <- as.integer(round(
          source_data$control_rate * source_data$sample_size_control
        ))
        self$n_successes_treatment <- as.integer(round(
          source_data$treatment_rate * source_data$sample_size_treatment
        ))
        self$n_control <- as.integer(source_data$sample_size_control)
        self$n_treatment <- as.integer(source_data$sample_size_treatment)
      }

      self$design_prior_type <- "source_posterior"
    },

    #' @description Samples from the source posterior design prior.
    #' @param n_samples The number of samples to generate.
    sample = function(n_samples) {
      if (self$summary_measure_likelihood == "normal") {
        return(rnorm(n_samples, self$parameters$mean, self$parameters$sd))
      } else if (self$summary_measure_likelihood == "binomial") {
        control_rate <- stats::rbeta(
          n_samples,
          shape1 = 1 + self$n_successes_control,
          shape2 = 1 + self$n_control - self$n_successes_control
        )
        treatment_rate <- stats::rbeta(
          n_samples,
          shape1 = 1 + self$n_successes_treatment,
          shape2 = 1 + self$n_treatment - self$n_successes_treatment
        )
        return(treatment_rate - control_rate)
      } else {
        stop("Not implemented for other distributions.")
      }
    },

    #' @description Computes the cumulative distribution function (CDF) of the source posterior design prior.
    #' @param x The value at which to evaluate the CDF.
    cdf = function(x) {
      if (self$summary_measure_likelihood == "normal") {
        return(pnorm(x, self$parameters$mean, self$parameters$sd))
      } else if (self$summary_measure_likelihood == "binomial") {
        return(integrate(self$pdf, lower = -1, upper = x)$value)
      } else {
        stop("Not implemented for other distributions.")
      }
    },

    #' @description The source posterior given the target control rate
    #'
    #' Under a binomial likelihood the source posterior is independent Beta
    #' posteriors on the two arms' response rates, so given the control rate
    #' the effect is the treatment rate, from its source posterior, less that
    #' rate. Otherwise the inherited truncation applies.
    #'
    #' @param control_rate The target control rate.
    #' @return A [FunctionalDesignPrior].
    given_control_rate = function(control_rate) {
      if (self$summary_measure_likelihood != "binomial") {
        return(super$given_control_rate(control_rate))
      }
      force(control_rate)
      shape1 <- 1 + self$n_successes_treatment
      shape2 <- 1 + self$n_treatment - self$n_successes_treatment
      FunctionalDesignPrior$new(
        cdf = function(x) stats::pbeta(x + control_rate, shape1, shape2),
        pdf = function(x) stats::dbeta(x + control_rate, shape1, shape2),
        sample = function(n_samples) stats::rbeta(n_samples, shape1, shape2) - control_rate,
        design_prior_type = self$design_prior_type
      )
    },

    #' @description Computes the cumulative distribution function (PDF) of the source posterior design prior.
    #' @param x The value at which to evaluate the PDF.
    pdf = function(x) {
      if (self$summary_measure_likelihood == "normal") {
        return(dnorm(x, self$parameters$mean, self$parameters$sd))
      } else if (self$summary_measure_likelihood == "binomial") {
        # PDF for each arm
        result <- sapply(x, function(x) {
          binomial_product_integral(
            x,
            alpha_control = 1 + self$n_successes_control,
            beta_control = 1 + self$n_control - self$n_successes_control,
            alpha_treatment = 1 + self$n_successes_treatment,
            beta_treatment = 1 + self$n_treatment - self$n_successes_treatment
          )
        })
      } else {
        stop("Not implemented for other distributions.")
      }
    }
  )
)

#' @title AnalysisPriorDesignPrior class
#' @description A class representing the analysis prior design prior for Bayesian borrowing.
#' @field model Model used to define the analysis prior
#' @export
AnalysisPriorDesignPrior <- R6::R6Class(
  "AnalysisPriorDesignPrior",
  inherit = DesignPrior,
  public = list(
    model = NULL,

    #' @description Initializes a new instance of AnalysisPriorDesignPrior.
    #' @param model The model object.
    #' @param case_study_config Case study configuration
    #' @param simulation_config Simulation configuration
    #' @param mcmc_config MCMC configuration
    initialize = function(model,
                          case_study_config,
                          simulation_config,
                          mcmc_config) {
      if (model$empirical_bayes == TRUE) {
        stop(
          "It is not possible to define an analysis design prior for a method that uses empirical Bayes."
        )
      }

      model$prior_to_RBesT(simulation_config$n_samples_mixture_approx)
      self$model <- model
      self$design_prior_type <- "analysis_prior"
    },

    #' @description Samples from the analysis prior design prior.
    #' @param n_samples The number of samples to generate.
    sample = function(n_samples) {
      return(self$model$sample_prior(n_samples))
    },

    #' @description The analysis prior given the target control rate
    #'
    #' The model's own prior given the control rate when it defines one, as
    #' the binomial models do; otherwise the analysis prior is truncated to the
    #' range the control rate leaves the effect.
    #'
    #' @param control_rate The target control rate.
    #' @return A [FunctionalDesignPrior].
    given_control_rate = function(control_rate) {
      if (!is.function(self$model$prior_given_control_rate)) {
        return(super$given_control_rate(control_rate))
      }
      conditional <- self$model$prior_given_control_rate(control_rate)
      FunctionalDesignPrior$new(
        cdf = conditional$cdf,
        pdf = conditional$pdf,
        sample = conditional$sample,
        design_prior_type = self$design_prior_type
      )
    },

    #' @description Computes the cumulative distribution function (CDF) of the analysis prior design prior.
    #' @param x The value at which to evaluate the CDF.
    cdf = function(x) {
      return(self$model$prior_cdf(x))
    },

    #' @description Computes the PDF of the analysis prior design prior.
    #' @param x The value at which to evaluate the PDF.
    pdf = function(x) {
      return(self$model$prior_pdf(x))
    }
  )
)
