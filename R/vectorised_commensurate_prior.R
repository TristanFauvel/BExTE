#' Discretise the commensurate power prior as a normal mixture
#'
#' @description Conditional on the commensurability precision `tau` and power
#' parameter `gamma`, the treatment-effect prior is normal. Quadrature over
#' those two parameters therefore turns the continuous prior into a finite
#' normal mixture. The shared conjugate-mixture kernel can update that mixture
#' for every simulated target estimate at once, avoiding a separate Stan fit
#' for each replicate.
#'
#' All three families are integrated the same way, through their quantile
#' representation on a Gauss-Legendre rule over the probability scale. For the
#' inverse-gamma family this remains stable for shapes as small as 0.001,
#' for which direct density quadrature is dominated by an endpoint
#' singularity.
#'
#' @param model A [GaussianCommensuratePowerPrior] or
#'   [GaussianCommensuratePrior] object. The latter fixes the power parameter
#'   at one, which collapses the second quadrature dimension: the mixture is
#'   then one normal component per `tau` node rather than `n_gamma` of them.
#' @param n_tau Number of quadrature nodes for the commensurability parameter.
#'   Two families multiply it, because their quantile functions are too steep
#'   for the default: an inverse gamma with a shape below 0.01 by four, and a
#'   log-Cauchy by `ceiling(scale / 10)`. With those, every configured prior's
#'   posterior summaries agree with a 3072-node rule to within 5e-5 over target
#'   estimates from 0 to 2.
#' @param n_gamma Number of conditional power-parameter nodes per `tau` node.
#'   Ignored when the model does not borrow a power parameter. Against a rule
#'   twice as fine in both dimensions, 12 nodes keep every configured prior's
#'   posterior quantiles within 0.2% of a posterior standard deviation on the
#'   Botox, Belimumab, Mepolizumab and Teriflunomide designs, the same order as
#'   the error left by the `tau` rule; 24 nodes halve that difference at twice
#'   the cost of every replicate.
#' @return A list containing normal-mixture `weights`, `means` and `sds`, plus
#'   the `tau` and `power_parameter` value represented by each component.
#'   `power_parameter` is `NULL` when the model does not have one.
#' @keywords internal
commensurate_prior_mixture <- function(model, n_tau = 48L, n_gamma = 12L) {
  tau_rule <- commensurate_tau_quadrature(model, n_tau)
  source_standard_error <- model$prior$source$standard_error

  if (!isTRUE(model$borrows_power_parameter)) {
    # gamma == 1, so the source contributes its whole likelihood and the
    # component variance loses the 1 / gamma factor. Integrating over tau
    # alone is all that remains.
    weights <- tau_rule$weights / sum(tau_rule$weights)

    return(list(
      weights = weights,
      means = rep(
        model$prior$source$treatment_effect_estimate,
        length(weights)
      ),
      sds = sqrt(tau_rule$inverse_tau + source_standard_error^2),
      tau = tau_rule$tau,
      power_parameter = NULL
    ))
  }

  gamma_rule <- statmod::gauss.quad(n_gamma, kind = "legendre")
  uniform_node <- (gamma_rule$nodes + 1) / 2
  uniform_weight <- gamma_rule$weights / 2

  beta_shape <- g_function(tau_rule$log_tau)
  power_parameter <- as.vector(outer(
    uniform_node,
    1 / beta_shape,
    function(probability, inverse_shape) {
      exp(log(probability) * inverse_shape)
    }
  ))

  tau <- rep(tau_rule$tau, each = n_gamma)
  inverse_tau <- rep(tau_rule$inverse_tau, each = n_gamma)
  weights <- as.vector(outer(uniform_weight, tau_rule$weights))
  weights <- weights / sum(weights)

  component_variance <- inverse_tau +
    source_standard_error^2 / power_parameter

  list(
    weights = weights,
    means = rep(
      model$prior$source$treatment_effect_estimate,
      length(weights)
    ),
    sds = sqrt(component_variance),
    tau = tau,
    power_parameter = power_parameter
  )
}


#' Quadrature rule for the commensurability parameter
#'
#' @param model A [GaussianCommensuratePowerPrior] or
#'   [GaussianCommensuratePrior] object.
#' @param n_nodes Number of nodes.
#' @return A list with `tau`, `inverse_tau`, `log_tau` and `weights`.
#' @keywords internal
commensurate_tau_quadrature <- function(model, n_nodes) {
  prior <- model$prior$method_parameters$heterogeneity_prior

  if (model$heterogeneity_prior_family == "inverse_gamma") {
    alpha <- prior$alpha
    beta <- prior$beta

    # Below a shape of 0.01 the quantile function steepens faster than the
    # default rule can follow. Measured as the worst posterior-summary error
    # over target estimates from 0 to 2, against a 3072-node rule: 48 nodes
    # give 4e-5 at a shape of 0.01 but 3e-3 at 1/1000, where 192 bring it
    # back to 2e-5.
    if (alpha < 0.01) {
      n_nodes <- 4L * n_nodes
    }

    # 1 / tau^2 ~ Gamma(alpha, rate = beta). Integrating its quantile
    # representation avoids evaluating the sharply singular density at zero.
    rule <- statmod::gauss.quad(n_nodes, kind = "legendre")
    probability <- (rule$nodes + 1) / 2
    inverse_tau_squared <- stats::qgamma(
      probability,
      shape = alpha,
      rate = beta
    )
    inverse_tau <- sqrt(inverse_tau_squared)
    log_tau <- -0.5 * log(inverse_tau_squared)
    log_limit <- log(.Machine$double.xmax) / 2

    return(list(
      tau = exp(pmin(log_tau, log_limit)),
      inverse_tau = inverse_tau,
      log_tau = log_tau,
      weights = rule$weights / 2
    ))
  }

  if (model$heterogeneity_prior_family == "half_normal") {
    # The quantile representation, as for the other two families. The
    # equivalent Gauss-Laguerre rule on tau^2 / (2 * sigma^2) ~ Gamma(1/2, 1)
    # integrates tau^2 exactly, because tau^2 is linear in the Laguerre
    # variable, but only reaches O(1 / n_nodes) on tau itself, whose square
    # root has an unbounded derivative at the origin. Neither more nodes nor a
    # longer range repairs that: it left the ELIR effective sample size 1.2%
    # out at 48 nodes and still 0.3% out at 384.
    rule <- statmod::gauss.quad(n_nodes, kind = "legendre")
    probability <- (rule$nodes + 1) / 2
    tau <- prior$std_dev * stats::qnorm((1 + probability) / 2)

    return(list(
      tau = tau,
      inverse_tau = 1 / tau,
      log_tau = log(tau),
      weights = rule$weights / 2
    ))
  }

  if (model$heterogeneity_prior_family == "cauchy") {
    # Near its centre the Cauchy quantile function spaces the nodes on
    # log(tau) in proportion to the scale. The node count was validated at a
    # scale of 10; wider priors get proportionally more nodes to keep that
    # spacing. At the Cauchy(0, 30) of Hobbs et al. (2011), 48 nodes left the
    # posterior summaries 3e-3 out, and 144 bring them to 2e-5.
    n_nodes <- n_nodes * max(1L, as.integer(ceiling(prior$scale / 10)))
    rule <- statmod::gauss.quad(n_nodes, kind = "legendre")
    probability <- (rule$nodes + 1) / 2
    log_tau <- stats::qcauchy(
      probability,
      location = prior$location,
      scale = prior$scale
    )

    # A scale of 10 already reaches beyond the floating-point range at
    # the outer quadrature nodes. Those values are limiting zero/infinite
    # precisions; clipping only their representation keeps the likelihood and
    # normal-mixture calculations finite.
    log_limit <- log(.Machine$double.xmax) / 2

    return(list(
      tau = exp(pmin(log_tau, log_limit)),
      inverse_tau = exp(pmin(-log_tau, log_limit)),
      log_tau = log_tau,
      weights = rule$weights / 2
    ))
  }

  stop(
    "Heterogeneity prior not implemented: ",
    model$heterogeneity_prior_family,
    call. = FALSE
  )
}


#' Which posterior moments of the commensurability parameter exist
#'
#' @description The target marginal likelihood approaches a positive constant
#'   as `tau` goes to infinity, so it does not repair a divergent positive
#'   moment of the prior: the posterior mean and standard deviation of `tau`
#'   exist exactly when the prior's do. Where they do not, both inference paths
#'   report `Inf` rather than a finite, run-dependent truncation - the
#'   quadrature because its outer nodes are clipped, Stan because its draws are
#'   a sample.
#'
#' @param heterogeneity_prior_family Name of the prior family.
#' @param heterogeneity_prior Prior parameters.
#' @return A logical vector with elements `mean` and `sd`.
#' @keywords internal
commensurate_tau_moments_exist <- function(heterogeneity_prior_family,
                                           heterogeneity_prior) {
  switch(
    heterogeneity_prior_family,
    # A log-Cauchy has no positive moment at all.
    cauchy = c(mean = FALSE, sd = FALSE),
    # tau^2 ~ InvGamma(alpha): E[tau] needs alpha > 1/2, E[tau^2] alpha > 1.
    inverse_gamma = c(
      mean = heterogeneity_prior$alpha > 0.5,
      sd = heterogeneity_prior$alpha > 1
    ),
    half_normal = c(mean = TRUE, sd = TRUE),
    stop(
      "Heterogeneity prior not implemented: ", heterogeneity_prior_family,
      call. = FALSE
    )
  )
}


#' Summarise borrowing parameters from quadrature weights
#'
#' @param posterior_weights Matrix with one posterior mixture per row.
#' @param mixture Output from [commensurate_prior_mixture()].
#' @param heterogeneity_prior_family Name of the prior family.
#' @param heterogeneity_prior Prior parameters.
#' @param borrows_power_parameter Whether the model has a power parameter. When
#'   it does not, the two power-parameter columns are absent rather than
#'   constant: the plain commensurate prior has no such parameter to report,
#'   and a column of ones would read as an estimate.
#' @return A data frame of posterior means and standard deviations.
#' @keywords internal
commensurate_parameter_summary <- function(posterior_weights, mixture,
                                           heterogeneity_prior_family,
                                           heterogeneity_prior,
                                           borrows_power_parameter = TRUE) {
  weighted_summary <- function(values) {
    mean_value <- drop(posterior_weights %*% values)
    second_moment <- drop(posterior_weights %*% values^2)
    list(
      mean = mean_value,
      sd = sqrt(pmax(second_moment - mean_value^2, 0))
    )
  }

  tau <- weighted_summary(mixture$tau)

  exists <- commensurate_tau_moments_exist(
    heterogeneity_prior_family,
    heterogeneity_prior
  )
  if (!exists[["mean"]]) {
    tau$mean[] <- Inf
  }
  if (!exists[["sd"]]) {
    tau$sd[] <- Inf
  }

  summary <- data.frame(
    heterogeneity_parameter_mean = tau$mean,
    heterogeneity_parameter_std = tau$sd
  )

  if (!borrows_power_parameter) {
    return(summary)
  }

  power <- weighted_summary(mixture$power_parameter)
  summary$power_parameter_mean <- power$mean
  summary$power_parameter_std <- power$sd

  summary
}


#' Compress the commensurate quadrature mixture, checking it against the full one
#'
#' @description Every component of [commensurate_prior_mixture()] is centred on
#' the source estimate, so the mixture is a distribution over the component
#' variance and [compress_normal_scale_mixture()] can replace its hundreds of
#' components with a few dozen. The posterior moments of `tau` and of the power
#' parameter are not functions of the variance alone; each is the ratio of an
#' integral against the variance distribution weighted by that parameter to the
#' marginal likelihood, and gets its own compressed rule.
#'
#' The compression is accepted only once it reproduces the full mixture on a
#' probe of the replicates at the extremes and quartiles of the estimate and of
#' its standard error: every posterior summary, the posterior probability at
#' `theta_0` and the borrowing-parameter summaries, to within `tolerance`
#' (relative, for the parameter summaries). The node count is doubled until it
#' does, and the full mixture is kept if no compression smaller than it passes,
#' or if it has fewer than four times `n_nodes` components to begin with.
#'
#' @param mixture Output from [commensurate_prior_mixture()].
#' @param samples Data frame of generated replicates.
#' @param theta_0 Null hypothesis value.
#' @param confidence_level Credible interval level.
#' @param heterogeneity_prior_family Name of the prior family.
#' @param heterogeneity_prior Prior parameters.
#' @param n_nodes Number of components the search starts from.
#' @param tolerance Largest discrepancy accepted on the probe.
#' @return A list with the compressed `weights`, `means` and `sds`, the rules
#'   [compressed_commensurate_parameter_summary()] reads, and the node count;
#'   or `NULL` when the full mixture should be used.
#' @keywords internal
compress_commensurate_mixture <- function(mixture, samples, theta_0,
                                          confidence_level,
                                          heterogeneity_prior_family,
                                          heterogeneity_prior,
                                          n_nodes = 32L,
                                          tolerance = 1e-10) {
  source_mean <- mixture$means[1]
  if (any(mixture$means != source_mean)) {
    return(NULL)
  }
  # Checking a compression costs about as much as analysing a few hundred
  # replicates on the full mixture, which a mixture this small does not repay.
  if (length(mixture$weights) < 4L * n_nodes) {
    return(NULL)
  }

  estimate <- samples$treatment_effect_estimate
  standard_error <- samples$treatment_effect_standard_error
  reference_variance <- stats::median(standard_error^2)
  variances <- mixture$sds^2

  tau_exists <- commensurate_tau_moments_exist(
    heterogeneity_prior_family,
    heterogeneity_prior
  )
  moment_values <- list()
  if (tau_exists[["mean"]]) moment_values$tau_1 <- mixture$tau
  if (tau_exists[["sd"]]) moment_values$tau_2 <- mixture$tau^2
  if (!is.null(mixture$power_parameter)) {
    moment_values$power_parameter_1 <- mixture$power_parameter
    moment_values$power_parameter_2 <- mixture$power_parameter^2
  }
  if (!all(vapply(moment_values, function(v) all(is.finite(v)), logical(1)))) {
    return(NULL)
  }

  probe <- summary_probe_rows(estimate, standard_error)
  alpha <- (1 - confidence_level) / 2
  probe_summary <- function(weights, means, sds, parameters) {
    posterior <- normal_mixture_posterior(
      weights, means, sds, estimate[probe], standard_error[probe]
    )
    summary <- normal_mixture_summary(
      posterior$weights, posterior$means, posterior$sds,
      probs = c(alpha, 0.5, 1 - alpha)
    )
    cdf <- rowSums(
      posterior$weights * stats::pnorm(theta_0, posterior$means, posterior$sds)
    )
    list(
      posterior = cbind(summary$quantiles, summary$mean, cdf),
      parameters = as.matrix(parameters(posterior))
    )
  }

  exact <- probe_summary(
    mixture$weights, mixture$means, mixture$sds,
    function(posterior) {
      commensurate_parameter_summary(
        posterior_weights = posterior$weights,
        mixture = mixture,
        heterogeneity_prior_family = heterogeneity_prior_family,
        heterogeneity_prior = heterogeneity_prior,
        borrows_power_parameter = !is.null(mixture$power_parameter)
      )
    }
  )

  while (n_nodes < length(mixture$weights)) {
    main <- compress_normal_scale_mixture(
      mixture$weights, variances, reference_variance, n_nodes
    )
    moment_rules <- lapply(moment_values, function(values) {
      scale <- max(values)
      rule <- compress_normal_scale_mixture(
        mixture$weights * values / scale, variances, reference_variance, n_nodes
      )
      rule$scale <- scale
      rule
    })
    compressed <- list(
      weights = main$weights,
      means = rep(source_mean, length(main$weights)),
      sds = sqrt(main$variances),
      variances = main$variances,
      source_mean = source_mean,
      moment_rules = moment_rules,
      tau_exists = tau_exists,
      borrows_power_parameter = !is.null(mixture$power_parameter),
      n_nodes = n_nodes
    )

    candidate <- probe_summary(
      compressed$weights, compressed$means, compressed$sds,
      function(posterior) {
        compressed_commensurate_parameter_summary(
          compressed, estimate[probe], standard_error[probe]
        )
      }
    )

    posterior_error <- max(abs(candidate$posterior - exact$posterior))
    finite <- is.finite(exact$parameters)
    parameter_error <- max(
      0,
      abs(candidate$parameters[finite] - exact$parameters[finite]) /
        pmax(1, abs(exact$parameters[finite]))
    )
    same_infinite <- identical(
      is.finite(candidate$parameters), finite
    )
    if (is.finite(posterior_error) && posterior_error <= tolerance &&
        parameter_error <= tolerance && same_infinite) {
      return(compressed)
    }
    n_nodes <- 2L * n_nodes
  }

  NULL
}


#' Replicates that span the range of the observations
#'
#' @param estimate Treatment effect estimates.
#' @param standard_error Their standard errors.
#' @return Row indices of the replicates at the extremes, deciles and
#'   quartiles of each.
#' @keywords internal
summary_probe_rows <- function(estimate, standard_error) {
  probs <- c(0, 0.1, 0.25, 0.5, 0.75, 0.9, 1)
  at_quantiles <- function(x) {
    ordered <- order(x)
    ordered[unique(1L + round(probs * (length(x) - 1L)))]
  }
  unique(c(at_quantiles(estimate), at_quantiles(standard_error)))
}


#' Borrowing-parameter summaries from a compressed commensurate mixture
#'
#' @description The compressed counterpart of [commensurate_parameter_summary()]:
#' each posterior moment is the integral of the marginal likelihood against
#' its own compressed rule, divided by the same integral against the main one.
#'
#' @param compressed Output from [compress_commensurate_mixture()].
#' @param estimate Treatment effect estimates.
#' @param standard_error Their standard errors.
#' @return A data frame shaped like the output of
#'   [commensurate_parameter_summary()].
#' @keywords internal
compressed_commensurate_parameter_summary <- function(compressed, estimate,
                                                      standard_error) {
  n_replicates <- length(estimate)
  squared_deviation <- (estimate - compressed$source_mean)^2

  # Log marginal likelihood of each observation under a component of each
  # variance, up to a constant that cancels in the ratios below.
  log_likelihood <- function(variances) {
    total <- outer(standard_error^2, variances, "+")
    -0.5 * (log(total) + squared_deviation / total)
  }

  log_normaliser <- log_likelihood(compressed$variances) +
    rep(log(compressed$weights), each = n_replicates)
  shift <- apply(log_normaliser, 1, max)
  normaliser <- rowSums(exp(log_normaliser - shift))

  moment <- function(name) {
    rule <- compressed$moment_rules[[name]]
    rule$scale * drop(exp(log_likelihood(rule$variances) - shift) %*% rule$weights) /
      normaliser
  }
  summarise <- function(name, mean_exists = TRUE, sd_exists = TRUE) {
    first <- if (mean_exists) moment(paste0(name, "_1")) else rep(Inf, n_replicates)
    sd <- if (sd_exists) {
      sqrt(pmax(moment(paste0(name, "_2")) - first^2, 0))
    } else {
      rep(Inf, n_replicates)
    }
    list(mean = first, sd = sd)
  }

  tau <- summarise(
    "tau",
    compressed$tau_exists[["mean"]],
    compressed$tau_exists[["sd"]]
  )
  summary <- data.frame(
    heterogeneity_parameter_mean = tau$mean,
    heterogeneity_parameter_std = tau$sd
  )

  if (!compressed$borrows_power_parameter) {
    return(summary)
  }

  power <- summarise("power_parameter")
  summary$power_parameter_mean <- power$mean
  summary$power_parameter_std <- power$sd

  summary
}


#' Recompute, on the full mixture, test decisions too close to call
#'
#' @description The compressed mixture reproduces the posterior probability of
#' the alternative to within its tolerance, so a replicate whose probability
#' lies within `margin` of the critical value could in principle be decided
#' differently. Those few are decided again on the full mixture, so that the
#' compression cannot change a decision.
#'
#' @param test_decisions Decisions taken on the compressed mixture.
#' @param posterior Compressed posterior, from [normal_mixture_posterior()].
#' @param mixture Full prior mixture.
#' @param estimate Treatment effect estimates.
#' @param standard_error Their standard errors.
#' @param critical_value Critical posterior probability.
#' @param theta_0 Null hypothesis value.
#' @param null_space Either `"left"` or `"right"`.
#' @param margin Distance from the critical value within which a decision is
#'   recomputed.
#' @return The decisions, with the borderline ones taken on the full mixture.
#' @keywords internal
recheck_borderline_decisions <- function(test_decisions, posterior, mixture,
                                         estimate, standard_error,
                                         critical_value, theta_0, null_space,
                                         margin = 1e-8) {
  cdf <- rowSums(
    posterior$weights * stats::pnorm(theta_0, posterior$means, posterior$sds)
  )
  probability <- if (null_space == "left") 1 - cdf else cdf
  borderline <- which(abs(probability - critical_value) < margin)
  if (length(borderline) == 0) {
    return(test_decisions)
  }
  exact <- normal_mixture_posterior(
    mixture$weights, mixture$means, mixture$sds,
    estimate[borderline], standard_error[borderline]
  )
  test_decisions[borderline] <- as.numeric(vectorised_test_decision(
    posterior_weights = exact$weights,
    posterior_means = exact$means,
    posterior_sds = exact$sds,
    critical_value = critical_value,
    theta_0 = theta_0,
    null_space = null_space
  ))
  test_decisions
}
