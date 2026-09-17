#' Default starting values for the KL calibration search
#'
#' @description The objective is not convex in the `Beta` shape parameters: the
#' compatible and the maximum-tolerable-discrepancy terms pull the prior in
#' opposite directions, and which of them dominates depends on where the search
#' starts. These five starts bracket the shapes the answer takes in practice -
#' the uniform prior, a symmetric unimodal one, and the three corners where one
#' shape is above one and the other below.
#'
#' @keywords internal
NPP_KL_DEFAULT_STARTS <- list(
  c(1, 1),
  c(2, 2),
  c(2, 0.5),
  c(0.5, 2),
  c(0.5, 0.5)
)

#' Default bounds on the calibrated Beta shape parameters
#'
#' @description The lower bound keeps the density integrable by quadrature - a
#' shape much below this puts so much mass in the endpoint singularity that the
#' Gauss-Jacobi rule needs impractically many nodes - and the upper bound stops
#' the search running off to a degenerate point mass when one of the two KL
#' terms can be driven to zero on its own.
#'
#' @keywords internal
NPP_KL_DEFAULT_BOUNDS <- c(0.05, 100)

#' Benefit direction implied by the null space
#'
#' @description A case study records which direction of the treatment effect is
#' beneficial only through `null_space`: `"left"` means the null hypothesis is
#' the half line below `theta_0`, so the trial succeeds when the effect is
#' large, and `"right"` is its mirror. The maximum tolerable discrepancy has to
#' be taken on the side that moves the target towards the null, so it needs that
#' direction as a sign. The same mapping is written as an alternative hypothesis
#' by [alternative_from_null_space()].
#'
#' @param null_space Either `"left"` or `"right"`.
#' @return `1` when larger treatment effects are beneficial, `-1` otherwise.
#' @keywords internal
benefit_sign_from_null_space <- function(null_space) {
  if (identical(null_space, "left")) {
    return(1)
  }
  if (identical(null_space, "right")) {
    return(-1)
  }
  stop(
    "null_space must be either 'left' or 'right', but it is ",
    format(null_space),
    ". The benefit direction cannot be derived otherwise."
  )
}

#' Check the inputs of the KL calibration
#'
#' @description Every one of these makes the calibration criterion undefined
#' rather than merely inaccurate, so they are all rejected before any quadrature
#' rule is built. Each message names the offending input and its value: the
#' calibration runs once per scenario, deep inside a simulation, and a bare
#' "invalid argument" there is expensive to trace back.
#'
#' @param theta_source Source treatment effect estimate.
#' @param se_source Standard error of the source estimate.
#' @param se_target_expected Expected standard error of the target estimate.
#' @param theta_null Boundary of the null hypothesis space.
#' @param benefit_sign Either `1` or `-1`.
#' @param d_mtd Maximum tolerable discrepancy.
#' @param lambda_kl Weight on the compatible term.
#' @param c_target Shape of the two reference Beta distributions.
#' @param beta_parameter_bounds Bounds on the calibrated shape parameters.
#' @return `NULL`, invisibly.
#' @keywords internal
npp_kl_validate_inputs <- function(theta_source,
                                   se_source,
                                   se_target_expected,
                                   theta_null,
                                   benefit_sign,
                                   d_mtd,
                                   lambda_kl,
                                   c_target,
                                   beta_parameter_bounds) {
  finite_scalar <- function(x) {
    is.numeric(x) && length(x) == 1L && is.finite(x)
  }

  if (!finite_scalar(theta_source)) {
    stop("theta_source must be a single finite number, but it is ",
         format(theta_source), ".")
  }
  if (!finite_scalar(theta_null)) {
    stop("theta_null must be a single finite number, but it is ",
         format(theta_null), ".")
  }
  if (!finite_scalar(se_source) || se_source <= 0) {
    stop("se_source must be a single positive number, but it is ",
         format(se_source),
         ". The source prior variance se_source^2 / gamma is undefined otherwise.")
  }
  if (!finite_scalar(se_target_expected) || se_target_expected <= 0) {
    stop("se_target_expected must be a single positive number, but it is ",
         format(se_target_expected),
         ". The hypothetical target likelihood is degenerate otherwise.")
  }
  if (!finite_scalar(d_mtd) || d_mtd <= 0) {
    stop("d_mtd must be a single positive number, but it is ",
         format(d_mtd),
         ". A discrepancy of zero makes the maximum tolerable discrepancy",
         " scenario identical to the compatible one, so the two KL terms",
         " would pull the same posterior towards opposite references.")
  }
  if (!finite_scalar(c_target) || c_target <= 1) {
    stop("c_target must be a single number greater than one, but it is ",
         format(c_target),
         ". Beta(c, 1) and Beta(1, c) do not favour full or no borrowing otherwise.")
  }
  if (!finite_scalar(lambda_kl) || lambda_kl < 0 || lambda_kl > 1) {
    stop("lambda_kl must be a single number in [0, 1], but it is ",
         format(lambda_kl), ".")
  }
  if (!finite_scalar(benefit_sign) || !(benefit_sign %in% c(-1, 1))) {
    stop("benefit_sign must be either 1 or -1, but it is ",
         format(benefit_sign),
         ". It says which side of the source estimate the maximum tolerable",
         " discrepancy is taken on.")
  }
  if (!is.numeric(beta_parameter_bounds) ||
      length(beta_parameter_bounds) != 2L ||
      !all(is.finite(beta_parameter_bounds)) ||
      beta_parameter_bounds[1] <= 0 ||
      beta_parameter_bounds[2] <= beta_parameter_bounds[1]) {
    stop("beta_parameter_bounds must be two increasing positive numbers, but it is ",
         paste(format(beta_parameter_bounds), collapse = ", "), ".")
  }

  invisible(NULL)
}

#' Quadrature rule for a Beta measure on the unit interval
#'
#' @description The calibration integrates against `Beta(a, b)` densities whose
#' shape parameters go as low as 0.05, so the integrand has an algebraic
#' singularity at each endpoint. Gauss-Jacobi integrates
#' \eqn{\gamma^{a-1}(1-\gamma)^{b-1}} exactly, leaving only the smooth remainder
#' to the rule, which is the same argument [npp_prior_mixture()] makes for the
#' prior mixture. Substituting \eqn{\gamma = (1 + x)/2} maps
#' `statmod::gauss.quad()`'s interval onto the unit interval and turns its weight
#' function \eqn{(1-x)^\alpha (1+x)^\beta} into the Beta kernel with
#' \eqn{\alpha = b - 1} and \eqn{\beta = a - 1}, at the cost of the constant
#' \eqn{2^{1-a-b}}.
#'
#' Dividing that by the Beta function leaves weights that are the Beta measure
#' itself, so they sum to one; they are returned on the log scale because the
#' likelihood they are combined with is evaluated there.
#'
#' @param alpha_gamma First shape parameter of the Beta prior.
#' @param beta_gamma Second shape parameter of the Beta prior.
#' @param n_nodes Number of quadrature nodes.
#' @return A list with `nodes`, strictly inside the unit interval, and
#'   `log_weights`, the log of the Beta measure each node carries.
#' @keywords internal
npp_kl_beta_quadrature <- function(alpha_gamma, beta_gamma, n_nodes = 80L) {
  rule <- statmod::gauss.quad(
    n_nodes,
    kind = "jacobi",
    alpha = beta_gamma - 1,
    beta = alpha_gamma - 1
  )

  nodes <- (1 + rule$nodes) / 2

  # log of 2^(1 - a - b) * w / beta(a, b), the Beta measure carried by each node.
  log_weights <- log(rule$weights) +
    (1 - alpha_gamma - beta_gamma) * log(2) -
    lbeta(alpha_gamma, beta_gamma)

  list(nodes = nodes, log_weights = log_weights)
}

#' Log-sum-exp
#'
#' @param x Numeric vector.
#' @return `log(sum(exp(x)))`, computed without overflowing.
#' @keywords internal
npp_kl_log_sum_exp <- function(x) {
  largest <- max(x)
  if (!is.finite(largest)) {
    return(largest)
  }
  largest + log(sum(exp(x - largest)))
}

#' Discretised marginal posterior of the discounting parameter
#'
#' @description For a hypothetical target estimate `x`, the marginal posterior of
#' the discounting parameter is
#' \deqn{p(\gamma \mid x) \propto N(x; \hat\theta_S, s_T^2 + s_S^2/\gamma)
#'   \, \mathrm{Beta}(\gamma; a, b).}
#' Evaluated on the quadrature nodes this becomes a discrete distribution, whose
#' masses are the normalised products of the Beta measure and the normal
#' likelihood. Normalising through [npp_kl_log_sum_exp()] keeps the very small
#' likelihoods reached at the maximum tolerable discrepancy from underflowing.
#'
#' This is a hypothetical posterior, used only to calibrate `a` and `b`. It is
#' not the posterior of any simulated replicate.
#'
#' @param x Hypothetical target treatment effect estimate.
#' @param theta_source Source treatment effect estimate.
#' @param se_source Standard error of the source estimate.
#' @param se_target_expected Expected standard error of the target estimate.
#' @param alpha_gamma First shape parameter of the Beta prior.
#' @param beta_gamma Second shape parameter of the Beta prior.
#' @param rule A rule from [npp_kl_beta_quadrature()].
#' @return A list with the quadrature `nodes`, the posterior `masses` at those
#'   nodes, which sum to one, and `log_density`, the log posterior density there.
#' @keywords internal
npp_kl_posterior_masses <- function(x,
                                    theta_source,
                                    se_source,
                                    se_target_expected,
                                    alpha_gamma,
                                    beta_gamma,
                                    rule) {
  log_likelihood <- stats::dnorm(
    x,
    mean = theta_source,
    sd = sqrt(se_target_expected^2 + se_source^2 / rule$nodes),
    log = TRUE
  )

  log_unnormalised_mass <- rule$log_weights + log_likelihood
  log_norm_const <- npp_kl_log_sum_exp(log_unnormalised_mass)

  list(
    nodes = rule$nodes,
    masses = exp(log_unnormalised_mass - log_norm_const),
    log_density = log_likelihood +
      stats::dbeta(rule$nodes, alpha_gamma, beta_gamma, log = TRUE) -
      log_norm_const
  )
}

#' Kullback-Leibler divergence from a discretised posterior to a Beta reference
#'
#' @description Computes \eqn{\int_0^1 p(\gamma)[\log p(\gamma) - \log q(\gamma)]
#' d\gamma} with `p` the hypothetical posterior and `q` one of the two reference
#' Beta distributions. The integral is taken in the direction written here, not
#' the reverse one: it penalises posterior mass placed where the reference has
#' little, which is what "the posterior should look like full borrowing" means.
#'
#' Quadrature enters through the posterior masses rather than through a separate
#' set of weights, because those masses already carry the rule.
#'
#' @param posterior A list from [npp_kl_posterior_masses()].
#' @param reference_shape1 First shape parameter of the reference Beta.
#' @param reference_shape2 Second shape parameter of the reference Beta.
#' @return A single number, or `Inf` when the integrand is not finite anywhere
#'   the posterior puts mass.
#' @keywords internal
npp_kl_divergence <- function(posterior, reference_shape1, reference_shape2) {
  log_reference <- stats::dbeta(
    posterior$nodes, reference_shape1, reference_shape2, log = TRUE
  )

  contributions <- posterior$masses * (posterior$log_density - log_reference)

  # A node carrying no posterior mass contributes nothing, whatever the log
  # densities do there: p log p tends to zero. Without this an underflowed mass
  # multiplied by an infinite log reference would turn the whole sum into NaN.
  contributions[posterior$masses == 0] <- 0

  if (!all(is.finite(contributions))) {
    return(Inf)
  }

  sum(contributions)
}

#' The KL calibration objective
#'
#' @description Weighted sum of the divergence from the compatible posterior to
#' `Beta(c, 1)`, which concentrates near full borrowing, and from the maximum
#' tolerable discrepancy posterior to `Beta(1, c)`, which concentrates near no
#' borrowing. The shape parameters are passed on the log scale so the optimiser
#' works unconstrained in a space where they are automatically positive.
#'
#' Any non-finite value is reported as `Inf` rather than propagated, so that a
#' shape the quadrature cannot handle ends the line search instead of stopping
#' the run.
#'
#' @param eta Length-two numeric vector, `log(a)` and `log(b)`.
#' @param theta_target_compatible Hypothetical estimate under compatibility.
#' @param theta_target_mtd Hypothetical estimate at the maximum tolerable
#'   discrepancy.
#' @param theta_source Source treatment effect estimate.
#' @param se_source Standard error of the source estimate.
#' @param se_target_expected Expected standard error of the target estimate.
#' @param lambda_kl Weight on the compatible term.
#' @param c_target Shape of the two reference Beta distributions.
#' @param n_nodes Number of quadrature nodes.
#' @return A single number, possibly `Inf`.
#' @keywords internal
npp_kl_objective <- function(eta,
                             theta_target_compatible,
                             theta_target_mtd,
                             theta_source,
                             se_source,
                             se_target_expected,
                             lambda_kl,
                             c_target,
                             n_nodes = 80L) {
  if (!all(is.finite(eta))) {
    return(Inf)
  }

  alpha_gamma <- exp(eta[1])
  beta_gamma <- exp(eta[2])

  rule <- tryCatch(
    npp_kl_beta_quadrature(alpha_gamma, beta_gamma, n_nodes = n_nodes),
    error = function(condition) NULL
  )
  if (is.null(rule) || !all(is.finite(rule$log_weights))) {
    return(Inf)
  }

  posterior_at <- function(x) {
    npp_kl_posterior_masses(
      x = x,
      theta_source = theta_source,
      se_source = se_source,
      se_target_expected = se_target_expected,
      alpha_gamma = alpha_gamma,
      beta_gamma = beta_gamma,
      rule = rule
    )
  }

  compatible_term <- npp_kl_divergence(
    posterior_at(theta_target_compatible), c_target, 1
  )
  mtd_term <- npp_kl_divergence(
    posterior_at(theta_target_mtd), 1, c_target
  )

  value <- lambda_kl * compatible_term + (1 - lambda_kl) * mtd_term

  if (!is.finite(value)) {
    return(Inf)
  }

  value
}

#' One run of the calibration optimiser
#'
#' @description Factored out of [calibrate_npp_kl()] so that a single starting
#' value can be exercised, and made to fail, on its own.
#'
#' L-BFGS-B works on the log shapes inside the log of the configured bounds,
#' which is why the bounds are guaranteed to hold exactly rather than
#' approximately. It is deterministic, so two calibrations with the same inputs
#' return the same answer.
#'
#' @param start Length-two numeric vector of starting shape parameters, on the
#'   natural scale.
#' @param objective A function of `eta`, as [npp_kl_objective()].
#' @param beta_parameter_bounds Bounds on the shape parameters.
#' @return A list with `alpha_gamma`, `beta_gamma`, `objective_value`,
#'   `converged` and `message`. A start the optimiser cannot use at all is
#'   reported as not converged with an infinite objective rather than raised.
#' @keywords internal
npp_kl_optimise_from <- function(start, objective, beta_parameter_bounds) {
  failure <- function(message) {
    list(
      alpha_gamma = NA_real_,
      beta_gamma = NA_real_,
      objective_value = Inf,
      converged = FALSE,
      message = message
    )
  }

  bounded_start <- pmin(pmax(start, beta_parameter_bounds[1]),
                        beta_parameter_bounds[2])

  fit <- tryCatch(
    stats::optim(
      par = log(bounded_start),
      fn = objective,
      method = "L-BFGS-B",
      lower = log(beta_parameter_bounds[1]),
      upper = log(beta_parameter_bounds[2])
    ),
    error = function(condition) condition
  )

  if (inherits(fit, "condition")) {
    return(failure(conditionMessage(fit)))
  }
  if (!is.finite(fit$value)) {
    return(failure("The objective was not finite at the optimiser's answer."))
  }

  list(
    alpha_gamma = exp(fit$par[1]),
    beta_gamma = exp(fit$par[2]),
    objective_value = fit$value,
    converged = identical(fit$convergence, 0L) ||
      identical(fit$convergence, 0),
    message = if (is.null(fit$message)) NA_character_ else fit$message
  )
}

#' Cache of KL calibrations
#'
#' @description
#' The calibration depends on the design - the source estimate and its standard
#' error, the expected target standard error, the null boundary, and the four
#' criterion settings - and on nothing that varies between replicates. Scenarios
#' that share those inputs therefore share an answer, and a simulation sweeps
#' many of them: on a continuous endpoint the whole drift axis collapses onto a
#' single calibration.
#'
#' The store lives in the package rather than on a model because a model is
#' built afresh for each scenario, the same reason [inference_cache_store] does.
#'
#' @keywords internal
npp_kl_cache_store <- new.env(parent = emptyenv())

#' Empty the KL calibration cache
#'
#' @description Called by tests, and by any run that must not reuse an earlier
#' run's calibrations.
#' @return `NULL`, invisibly.
#' @export
npp_kl_calibration_cache_reset <- function() {
  rm(
    list = ls(envir = npp_kl_cache_store, all.names = TRUE),
    envir = npp_kl_cache_store
  )
  invisible(NULL)
}

#' Number of calibrations held in the cache
#'
#' @return The number of distinct calibrations stored.
#' @export
npp_kl_calibration_cache_size <- function() {
  length(ls(envir = npp_kl_cache_store, all.names = TRUE))
}

#' Calibrate the normalised power prior by a KL criterion
#'
#' @description
#' Chooses the `Beta(a, b)` prior on the discounting parameter of the normalised
#' power prior so that the prior is informative about *when* to borrow rather
#' than about *how much*. Two hypothetical target estimates stand for the two
#' situations the prior has to tell apart:
#' \describe{
#'   \item{compatibility}{the target estimate falls exactly on the source
#'     estimate, and the discounting parameter should concentrate near one;}
#'   \item{maximum tolerable discrepancy}{the target estimate falls
#'     `d_mtd` away from it, towards the null, and the discounting parameter
#'     should concentrate near zero.}
#' }
#' Writing \eqn{p_0} and \eqn{p_{MTD}} for the marginal posteriors of the
#' discounting parameter these two imply, the calibration minimises
#' \deqn{K(a, b) = \lambda \, \mathrm{KL}[p_0 \| \mathrm{Beta}(c, 1)] +
#'   (1 - \lambda) \, \mathrm{KL}[p_{MTD} \| \mathrm{Beta}(1, c)].}
#'
#' Both hypothetical posteriors are formed from the *expected* target standard
#' error, the one the design implies, not from any realised estimate. The
#' calibration therefore belongs to the scenario and is computed once for it,
#' before any replicate is generated; every replicate of that scenario is then
#' analysed under the same prior, and only the target estimate and its standard
#' error vary between them.
#'
#' @param theta_source Source treatment effect estimate.
#' @param se_source Standard error of the source estimate. Must be positive.
#' @param se_target_expected Standard error the target design implies for its
#'   treatment effect estimate. Must be positive.
#' @param theta_null Boundary of the null hypothesis space, the `theta_0` of the
#'   case study.
#' @param benefit_sign `1` when larger treatment effects are beneficial, `-1`
#'   when smaller ones are. [benefit_sign_from_null_space()] derives it from a
#'   case study's `null_space`.
#' @param d_mtd Maximum tolerable discrepancy. `NULL`, the default, applies the
#'   rule `d_mtd_multiplier * abs(theta_source - theta_null)`; a number
#'   overrides that rule, and `d_mtd_multiplier` is then not applied.
#' @param d_mtd_multiplier Multiplier used by the default rule.
#' @param lambda_kl Weight on the compatible term, in `[0, 1]`.
#' @param c_target Shape of the two reference Beta distributions. Must exceed
#'   one.
#' @param beta_parameter_bounds Bounds on the calibrated shape parameters.
#' @param optimizer_starts List of length-two starting values, on the natural
#'   scale. The search keeps the converged answer with the smallest objective.
#' @param n_nodes Number of Gauss-Jacobi nodes used for every integral.
#' @return A list with the calibrated `alpha_gamma` and `beta_gamma`, the
#'   `objective_value` they attain, `optimizer_converged` and
#'   `optimizer_message`, the two hypothetical estimates
#'   `theta_target_compatible` and `theta_target_mtd`, the `d_mtd`,
#'   `d_mtd_multiplier`, `lambda_kl`, `c_target` and `se_target_expected` used,
#'   and a `calibration_id` identifying the calibration unit.
#' @export
calibrate_npp_kl <- function(theta_source,
                             se_source,
                             se_target_expected,
                             theta_null = 0,
                             benefit_sign = 1,
                             d_mtd = NULL,
                             d_mtd_multiplier = 1,
                             lambda_kl = 0.5,
                             c_target = 10,
                             beta_parameter_bounds = NPP_KL_DEFAULT_BOUNDS,
                             optimizer_starts = NPP_KL_DEFAULT_STARTS,
                             n_nodes = 80L) {
  if (is.null(d_mtd)) {
    if (!is.numeric(d_mtd_multiplier) || length(d_mtd_multiplier) != 1L ||
        !is.finite(d_mtd_multiplier) || d_mtd_multiplier <= 0) {
      stop("d_mtd_multiplier must be a single positive number, but it is ",
           format(d_mtd_multiplier), ".")
    }
    d_mtd <- d_mtd_multiplier * abs(theta_source - theta_null)
  }

  npp_kl_validate_inputs(
    theta_source = theta_source,
    se_source = se_source,
    se_target_expected = se_target_expected,
    theta_null = theta_null,
    benefit_sign = benefit_sign,
    d_mtd = d_mtd,
    lambda_kl = lambda_kl,
    c_target = c_target,
    beta_parameter_bounds = beta_parameter_bounds
  )

  if (length(optimizer_starts) == 0L) {
    stop("optimizer_starts must hold at least one starting value.")
  }

  theta_target_compatible <- theta_source
  theta_target_mtd <- theta_source - benefit_sign * d_mtd

  # Everything the objective reads, and nothing else. Two scenarios agreeing on
  # all of it have the same answer, whatever else differs between them.
  calibration_id <- rlang::hash(list(
    theta_source = theta_source,
    se_source = se_source,
    se_target_expected = se_target_expected,
    theta_null = theta_null,
    benefit_sign = benefit_sign,
    d_mtd = d_mtd,
    lambda_kl = lambda_kl,
    c_target = c_target,
    beta_parameter_bounds = beta_parameter_bounds,
    optimizer_starts = optimizer_starts,
    n_nodes = n_nodes
  ))

  if (exists(calibration_id, envir = npp_kl_cache_store, inherits = FALSE)) {
    return(get(calibration_id, envir = npp_kl_cache_store, inherits = FALSE))
  }

  objective <- function(eta) {
    npp_kl_objective(
      eta = eta,
      theta_target_compatible = theta_target_compatible,
      theta_target_mtd = theta_target_mtd,
      theta_source = theta_source,
      se_source = se_source,
      se_target_expected = se_target_expected,
      lambda_kl = lambda_kl,
      c_target = c_target,
      n_nodes = n_nodes
    )
  }

  # A start that raises is passed over rather than allowed to end the
  # calibration: the search exists precisely because any one start may be
  # unusable, and the answer is decided by the ones that are.
  attempts <- lapply(optimizer_starts, function(start) {
    tryCatch(
      npp_kl_optimise_from(
        start = start,
        objective = objective,
        beta_parameter_bounds = beta_parameter_bounds
      ),
      error = function(condition) {
        list(
          alpha_gamma = NA_real_,
          beta_gamma = NA_real_,
          objective_value = Inf,
          converged = FALSE,
          message = conditionMessage(condition)
        )
      }
    )
  })

  converged <- Filter(function(attempt) {
    attempt$converged && is.finite(attempt$objective_value)
  }, attempts)

  if (length(converged) == 0L) {
    stop(
      "The KL calibration failed from every one of the ", length(attempts),
      " starting values. The last optimiser message was: ",
      attempts[[length(attempts)]]$message,
      ". Inputs were theta_source = ", format(theta_source),
      ", se_source = ", format(se_source),
      ", se_target_expected = ", format(se_target_expected),
      ", d_mtd = ", format(d_mtd),
      ", lambda_kl = ", format(lambda_kl),
      ", c_target = ", format(c_target), "."
    )
  }

  objective_values <- vapply(converged, function(attempt) {
    attempt$objective_value
  }, numeric(1))
  best <- converged[[which.min(objective_values)]]

  calibration <- list(
    alpha_gamma = best$alpha_gamma,
    beta_gamma = best$beta_gamma,
    objective_value = best$objective_value,
    optimizer_converged = TRUE,
    optimizer_message = best$message,
    theta_target_compatible = theta_target_compatible,
    theta_target_mtd = theta_target_mtd,
    d_mtd = d_mtd,
    d_mtd_multiplier = d_mtd_multiplier,
    lambda_kl = lambda_kl,
    c_target = c_target,
    se_target_expected = se_target_expected,
    calibration_id = calibration_id
  )

  assign(calibration_id, calibration, envir = npp_kl_cache_store)

  calibration
}

#' Prior mean and standard deviation of a Beta distribution
#'
#' @param alpha_gamma First shape parameter.
#' @param beta_gamma Second shape parameter.
#' @return A list with `mean` and `sd`.
#' @keywords internal
npp_kl_beta_moments <- function(alpha_gamma, beta_gamma) {
  total <- alpha_gamma + beta_gamma
  list(
    mean = alpha_gamma / total,
    sd = sqrt(alpha_gamma * beta_gamma / (total^2 * (total + 1)))
  )
}

#' The calibration columns reported with every replicate
#'
#' @description These are constant within a scenario: the prior is calibrated
#' once from the design and reused for every replicate. They are repeated for
#' each replicate anyway because the reporting layer averages every column of
#' the posterior parameters over the replicates
#' (`estimate_frequentist_operating_characteristics()`), so a constant column
#' arrives in the results as that constant.
#'
#' `calibration_id` is deliberately absent: that averaging would turn a
#' character column into `NA`. The calibration unit is identifiable in the
#' results from `alpha_gamma`, `beta_gamma`, `d_mtd` and `se_target_expected`.
#'
#' @param calibration A list from [calibrate_npp_kl()].
#' @param n_replicates Number of rows to produce.
#' @return A data frame of `n_replicates` identical rows.
#' @keywords internal
npp_kl_calibration_columns <- function(calibration, n_replicates) {
  moments <- npp_kl_beta_moments(calibration$alpha_gamma, calibration$beta_gamma)

  data.frame(
    alpha_gamma = rep(calibration$alpha_gamma, n_replicates),
    beta_gamma = rep(calibration$beta_gamma, n_replicates),
    prior_gamma_mean = rep(moments$mean, n_replicates),
    prior_gamma_sd = rep(moments$sd, n_replicates),
    d_mtd = rep(calibration$d_mtd, n_replicates),
    se_target_expected = rep(calibration$se_target_expected, n_replicates),
    kl_objective_value = rep(calibration$objective_value, n_replicates),
    calibration_converged = rep(
      as.numeric(isTRUE(calibration$optimizer_converged)), n_replicates
    )
  )
}
