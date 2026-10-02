#' Run a vectorised analysis of the replicates in chunks
#'
#' @description A vectorised analysis holds several `n_replicates x
#' n_components` matrices at once, which for a mixture of hundreds of
#' components and ten thousand replicates reaches gigabytes per worker, and
#' limits how many workers a machine can run. Every replicate is analysed on
#' its own, so the analysis can run on consecutive chunks of replicates and the
#' results be concatenated, with the same result and a peak memory bounded by
#' the chunk.
#'
#' @param samples Data frame of generated replicates, one row each.
#' @param analyse Function of a chunk of `samples` returning the list that
#'   [vectorised_normal_mixture_simulation()] returns.
#' @param chunk_size Number of replicates per chunk.
#' @return The list `analyse` returns, over every replicate.
#' @keywords internal
analyse_in_replicate_chunks <- function(samples, analyse, chunk_size = 1000L) {
  n_replicates <- nrow(samples)
  if (n_replicates <= chunk_size) {
    return(analyse(samples))
  }
  starts <- seq.int(1L, n_replicates, by = chunk_size)
  pieces <- lapply(starts, function(start) {
    rows <- start:min(start + chunk_size - 1L, n_replicates)
    analyse(samples[rows, , drop = FALSE])
  })
  combine_replicate_results(pieces)
}


#' Concatenate the results of consecutive chunks of replicates
#'
#' @param pieces List of results, as [vectorised_normal_mixture_simulation()]
#'   returns them, for consecutive chunks of replicates.
#' @return One such list over every replicate: vectors are concatenated, and
#'   matrices and data frames bound by rows. Outputs that were not requested
#'   stay `NULL`.
#' @keywords internal
combine_replicate_results <- function(pieces) {
  fields <- names(pieces[[1]])
  combined <- lapply(fields, function(field) {
    parts <- lapply(pieces, `[[`, field)
    if (all(vapply(parts, is.null, logical(1)))) {
      return(NULL)
    }
    if (is.matrix(parts[[1]]) || is.data.frame(parts[[1]])) {
      do.call(rbind, parts)
    } else {
      do.call(c, parts)
    }
  })
  names(combined) <- fields
  combined
}


#' Run a whole normal-mixture simulation without looping over replicates
#'
#' @description Shared implementation behind the vectorised fast path. Given the
#' prior mixture for every replicate, this reproduces exactly what the replicate
#' loop would have produced: posterior moments, medians, credible intervals,
#' test decisions and effective sample sizes.
#'
#' @param weights Prior component weights, shared across replicates (a vector)
#'   or one row per replicate (a matrix).
#' @param means Prior component means, shaped like `weights`.
#' @param sds Prior component standard deviations, shaped like `weights`.
#' @param samples Data frame of generated replicates, with columns
#'   `treatment_effect_estimate`, `treatment_effect_standard_error` and
#'   `standard_deviation`.
#' @param target_data Target data object, used for its sample size per arm.
#' @param to_return Character vector of requested outputs.
#' @param critical_value Critical value for the test decision.
#' @param theta_0 Null hypothesis value.
#' @param confidence_level Credible interval level.
#' @param null_space Either `"left"` or `"right"`.
#' @param posterior_parameters Optional data frame of per-replicate posterior
#'   parameters to report.
#' @param posterior Optional output from [normal_mixture_posterior()] when the
#'   caller already needed it for method-specific parameter summaries.
#' @param mcmc Whether the calling model samples when it is not on this fast
#'   path, which decides what the MCMC diagnostics report.
#' @return A list shaped like the return value of
#'   `Model$simulation_for_given_treatment_effect()`.
#' @keywords internal
vectorised_normal_mixture_simulation <- function(weights, means, sds,
                                                 samples, target_data,
                                                 to_return,
                                                 critical_value, theta_0,
                                                 confidence_level, null_space,
                                                 posterior_parameters = NULL,
                                                 posterior = NULL,
                                                 mcmc = FALSE) {
  requested <- function(output) output %in% to_return

  estimate <- samples$treatment_effect_estimate
  standard_error <- samples$treatment_effect_standard_error
  n_replicates <- length(estimate)

  if (is.null(posterior)) {
    posterior <- normal_mixture_posterior(
      weights = weights,
      means = means,
      sds = sds,
      estimate = estimate,
      standard_error = standard_error
    )
  }

  alpha <- (1 - confidence_level) / 2
  summaries <- normal_mixture_summary(
    posterior$weights, posterior$means, posterior$sds,
    probs = c(alpha, 0.5, 1 - alpha)
  )

  credible_intervals <- summaries$quantiles[, c(1, 3), drop = FALSE]

  test_decisions <- if (requested("test_decision")) {
    as.numeric(vectorised_test_decision(
      posterior_weights = posterior$weights,
      posterior_means = posterior$means,
      posterior_sds = posterior$sds,
      critical_value = critical_value,
      theta_0 = theta_0,
      null_space = null_space
    ))
  } else {
    NULL
  }

  # The reference scale for effective sample sizes is the per-replicate
  # sampling standard deviation, exactly as the replicate loop sets it. The two
  # ESS definitions come from the same helper the replicate loop uses, applied
  # here to every replicate at once, so the two paths cannot drift apart.
  reference_scale <- samples$standard_deviation

  ess <- normal_reference_ess(
    reference_scale = reference_scale,
    posterior_sd = summaries$sd,
    lower = credible_intervals[, 1],
    upper = credible_intervals[, 2],
    sample_size_per_arm = target_data$sample_size_per_arm
  )

  ess_moments <- if (requested("ess_moment")) ess$moment else NULL
  ess_precisions <- if (requested("ess_precision")) ess$precision else NULL

  ess_elir <- if (requested("ess_elir")) {
    # Passed through unrecycled: a prior shared by every replicate only needs
    # the ELIR integral evaluating once.
    normal_mixture_elir_ess(
      weights = weights,
      means = means,
      sds = sds,
      sigma = reference_scale
    )
  } else {
    NULL
  }

  # No sampler runs on this path, so there are no diagnostics to report. The
  # replicate loop zero-fills them for a model that never samples at all, and
  # estimate_frequentist_operating_characteristics() averages them into
  # required result columns, so those models keep their zeros rather than
  # turning the columns into NA. A model that does sample off this path is a
  # different case: rhat = 0 would read as a chain converged beyond perfectly,
  # and a mean divergence count of 0 as a sampler that never diverged, so it
  # reports the diagnostics as not applicable instead.
  diagnostic <- if (mcmc) NA_real_ else 0

  list(
    test_decisions = test_decisions,
    posterior_means = if (requested("posterior_mean")) summaries$mean else NULL,
    posterior_medians = if (requested("posterior_median")) summaries$quantiles[, 2] else NULL,
    credible_intervals = if (requested("credible_interval")) credible_intervals else NULL,
    posterior_parameters = if (requested("posterior_parameters")) posterior_parameters else NULL,
    ess_moments = ess_moments,
    ess_precisions = ess_precisions,
    ess_elir = ess_elir,
    fit_success = if (requested("fit_success")) rep("Success", n_replicates) else NULL,
    mcmc_ess = if (requested("mcmc_diagnostics")) rep(diagnostic, n_replicates) else NULL,
    rhat = if (requested("mcmc_diagnostics")) rep(diagnostic, n_replicates) else NULL,
    n_divergences = if (requested("mcmc_diagnostics")) rep(diagnostic, n_replicates) else NULL
  )
}

#' Test decision for every replicate at once
#'
#' @description Compares the posterior probability of the alternative
#' hypothesis with `critical_value`, matching `Model$test_decision()`.
#'
#' @param posterior_weights `n_replicates x n_components` posterior weights.
#' @param posterior_means `n_replicates x n_components` posterior means.
#' @param posterior_sds `n_replicates x n_components` posterior standard
#'   deviations.
#' @param critical_value Critical posterior probability.
#' @param theta_0 Null hypothesis value.
#' @param null_space Either `"left"` or `"right"`.
#' @return Logical vector of decisions.
#' @keywords internal
vectorised_test_decision <- function(posterior_weights, posterior_means,
                                     posterior_sds,
                                     critical_value, theta_0, null_space) {
  cdf_at_theta_0 <- rowSums(
    posterior_weights * stats::pnorm(theta_0, posterior_means, posterior_sds)
  )

  if (null_space == "left") {
    return(1 - cdf_at_theta_0 > critical_value)
  }
  cdf_at_theta_0 > critical_value
}

#' Conjugate update of a normal mixture prior across replicates
#'
#' @description Applies the normal-normal conjugate update to every replicate at
#' once. This is the vectorised equivalent of calling [RBesT::postmix()] once per
#' replicate: for a prior component with weight \eqn{w_k}, mean \eqn{\mu_k} and
#' standard deviation \eqn{s_k}, and an observation \eqn{(m_i, se_i)}, the
#' posterior component has variance \eqn{1/(1/s_k^2 + 1/se_i^2)}, mean
#' \eqn{v_{ik}(\mu_k/s_k^2 + m_i/se_i^2)} and weight proportional to
#' \eqn{w_k \, N(m_i; \mu_k, s_k^2 + se_i^2)}.
#'
#' @param weights Prior component weights. Either a vector of length
#'   `n_components` (a prior shared by every replicate) or a
#'   `n_replicates x n_components` matrix (one prior per replicate, as needed by
#'   empirical Bayes methods).
#' @param means Prior component means, shaped like `weights`.
#' @param sds Prior component standard deviations, shaped like `weights`.
#' @param estimate Vector of per-replicate treatment effect estimates.
#' @param standard_error Vector of per-replicate standard errors.
#' @return A list of three `n_replicates x n_components` matrices: `weights`,
#'   `means` and `sds` of the posterior mixture.
#' @export
normal_mixture_posterior <- function(weights, means, sds, estimate, standard_error) {
  n_replicates <- length(estimate)
  standard_error <- rep_len(standard_error, n_replicates)

  if (!is.matrix(weights) && !is.matrix(means) && !is.matrix(sds)) {
    return(shared_normal_mixture_posterior(
      weights = weights,
      means = means,
      sds = sds,
      estimate = estimate,
      standard_error = standard_error
    ))
  }

  weights <- recycle_prior_component(weights, n_replicates)
  means <- recycle_prior_component(means, n_replicates)
  sds <- recycle_prior_component(sds, n_replicates)

  prior_precision <- 1 / sds^2
  data_precision <- 1 / standard_error^2

  posterior_variance <- 1 / (prior_precision + data_precision)
  posterior_mean <- posterior_variance *
    (means * prior_precision + estimate * data_precision)

  # Marginal likelihood of the observation under each component, in log space so
  # that a component with negligible weight cannot underflow to an NaN weight.
  log_weight <- log(weights) +
    stats::dnorm(estimate, means, sqrt(sds^2 + standard_error^2), log = TRUE)
  log_weight <- log_weight - apply(log_weight, 1, max)
  posterior_weight <- exp(log_weight)
  posterior_weight <- posterior_weight / rowSums(posterior_weight)

  list(
    weights = posterior_weight,
    means = posterior_mean,
    sds = sqrt(posterior_variance)
  )
}

#' Conjugate update of a normal mixture prior shared by every replicate
#'
#' @description The same update as [normal_mixture_posterior()], for the common
#' case of one prior serving every replicate. Broadcasting the component values
#' against the observations with [outer()] keeps three constant
#' `n_replicates x n_components` copies of the prior out of memory. For the
#' commensurate quadrature mixture those copies alone run to hundreds of
#' megabytes; the posterior matrices are irreducible and dominate what is left.
#'
#' @param weights Prior component weights, a vector of length `n_components`.
#' @param means Prior component means, shaped like `weights`.
#' @param sds Prior component standard deviations, shaped like `weights`.
#' @param estimate Vector of per-replicate treatment effect estimates.
#' @param standard_error Per-replicate standard errors, already recycled to the
#'   same length as `estimate`.
#' @return A list of three `n_replicates x n_components` matrices: `weights`,
#'   `means` and `sds` of the posterior mixture.
#' @keywords internal
shared_normal_mixture_posterior <- function(weights, means, sds,
                                            estimate, standard_error) {
  n_replicates <- length(estimate)

  prior_precision <- 1 / sds^2
  data_precision <- 1 / standard_error^2

  posterior_variance <- 1 / outer(data_precision, prior_precision, "+")
  posterior_mean <- posterior_variance *
    outer(estimate * data_precision, means * prior_precision, "+")

  # Marginal likelihood of the observation under each component, in log space so
  # that a component with negligible weight cannot underflow to an NaN weight.
  # The density's constant factor is dropped, since the weights are renormalised
  # below.
  marginal_variance <- outer(standard_error^2, sds^2, "+")
  log_weight <- outer(estimate, means, "-")^2 / marginal_variance
  log_weight <- -0.5 * (log_weight + log(marginal_variance)) +
    rep(log(weights), each = n_replicates)
  rm(marginal_variance)

  log_weight <- log_weight - apply(log_weight, 1, max)
  posterior_weight <- exp(log_weight)
  posterior_weight <- posterior_weight / rowSums(posterior_weight)

  list(
    weights = posterior_weight,
    means = posterior_mean,
    sds = sqrt(posterior_variance)
  )
}

#' Mean, standard deviation and quantiles of a normal mixture, per replicate
#'
#' @description Vectorised equivalent of `summary()` on an [RBesT::mixnorm()]
#' object. The mean and standard deviation are closed form. The quantiles invert
#' the mixture CDF by bisection, which runs on every replicate simultaneously;
#' RBesT instead calls `uniroot` once per mixture, at a looser tolerance.
#'
#' @param weights `n_replicates x n_components` matrix of mixture weights.
#' @param means `n_replicates x n_components` matrix of component means.
#' @param sds `n_replicates x n_components` matrix of component standard
#'   deviations.
#' @param probs Probabilities at which to evaluate the quantile function.
#' @return A list with `mean` and `sd` vectors of length `n_replicates`, and a
#'   `n_replicates x length(probs)` matrix of `quantiles`.
#' @export
normal_mixture_summary <- function(weights, means, sds, probs = c(0.025, 0.5, 0.975)) {
  mixture_mean <- rowSums(weights * means)
  # Law of total variance: E[X^2] - E[X]^2 over the mixture components.
  mixture_variance <- rowSums(weights * (sds^2 + means^2)) - mixture_mean^2
  mixture_sd <- sqrt(mixture_variance)

  quantiles <- vapply(
    probs,
    function(p) normal_mixture_quantile(weights, means, sds, p, mixture_mean, mixture_sd),
    numeric(nrow(weights))
  )
  # vapply drops to a vector when there is a single replicate.
  quantiles <- matrix(quantiles, nrow = nrow(weights), ncol = length(probs))

  list(mean = mixture_mean, sd = mixture_sd, quantiles = quantiles)
}

#' Invert a normal mixture CDF for every replicate at once
#'
#' @description Safeguarded Newton iteration on the mixture CDF, which is
#' strictly increasing, with the mixture density as its derivative. Every
#' quantile of a mixture lies between the smallest and the largest quantile of
#' its components, since the mixture CDF is a weighted average of theirs, so
#' that interval brackets the root without evaluating the CDF. Each Newton step
#' that would leave the bracket is replaced by a bisection step, and the bracket
#' shrinks at every iteration, so the iteration converges; from the normal
#' approximation it typically takes six Newton steps, where bisection took
#' about forty. Only the replicates that have not converged are updated.
#'
#' @param weights `n_replicates x n_components` matrix of mixture weights.
#' @param means `n_replicates x n_components` matrix of component means.
#' @param sds `n_replicates x n_components` matrix of component standard
#'   deviations.
#' @param p Single probability at which to evaluate the quantile function.
#' @param mixture_mean Vector of mixture means, used for the starting point.
#' @param mixture_sd Vector of mixture standard deviations, used for the
#'   starting point.
#' @param tolerance Absolute step, or bracket width, at which the iteration
#'   stops.
#' @param max_iterations Iteration cap, far above what convergence needs.
#' @return Vector of quantiles, one per replicate.
#' @keywords internal
normal_mixture_quantile <- function(weights, means, sds, p,
                                    mixture_mean, mixture_sd,
                                    tolerance = 1e-12,
                                    max_iterations = 200L) {
  weights <- as.matrix(weights)
  means <- as.matrix(means)
  sds <- as.matrix(sds)

  # The bracket: the extreme component quantiles, among the components that
  # carry any weight.
  component_quantiles <- means + stats::qnorm(p) * sds
  component_quantiles[weights <= 0] <- NA
  lower <- apply(component_quantiles, 1, min, na.rm = TRUE)
  upper <- apply(component_quantiles, 1, max, na.rm = TRUE)

  x <- pmin(pmax(mixture_mean + stats::qnorm(p) * mixture_sd, lower), upper)
  active <- which(upper - lower > tolerance)
  settled <- setdiff(seq_along(x), active)
  x[settled] <- (lower[settled] + upper[settled]) / 2

  for (i in seq_len(max_iterations)) {
    if (length(active) == 0) {
      break
    }
    w <- weights[active, , drop = FALSE]
    z <- (x[active] - means[active, , drop = FALSE]) / sds[active, , drop = FALSE]
    excess <- rowSums(w * stats::pnorm(z)) - p
    density <- rowSums(w * stats::dnorm(z) / sds[active, , drop = FALSE])

    # The root is above x where the CDF falls short of p, below it otherwise.
    below <- excess < 0
    lower[active] <- ifelse(below, x[active], lower[active])
    upper[active] <- ifelse(below, upper[active], x[active])

    newton <- x[active] - excess / density
    # A Newton step below the tolerance means convergence, even where rounding
    # puts it on the bracket's edge: bisecting there would move away from the
    # root.
    converged <- is.finite(newton) & abs(newton - x[active]) < tolerance
    inside <- is.finite(newton) & newton >= lower[active] & newton <= upper[active]
    candidate <- ifelse(converged | inside, newton, (lower[active] + upper[active]) / 2)

    step <- abs(candidate - x[active])
    x[active] <- candidate
    converged <- converged | step < tolerance | upper[active] - lower[active] < tolerance
    active <- active[!converged]
  }

  x
}

#' ELIR effective sample size of a normal mixture, per replicate
#'
#' @description Vectorised equivalent of `RBesT::ess(mix, method = "elir")`. The
#' ELIR effective sample size is
#' \eqn{\sigma^2 \int p(\theta) \, i(\theta) \, d\theta}, where
#' \eqn{i(\theta) = -\partial^2_\theta \log p(\theta)} is the Fisher information
#' of the prior.
#'
#' RBesT evaluates that integral with Gauss-Hermite quadrature centred on each
#' mixture component, doubling the node count until successive estimates agree
#' and falling back to adaptive quadrature if they never do. That fallback is
#' the usual outcome for a robust mixture prior, whose informative and vague
#' components differ in scale by a factor of around twenty: nodes spaced for the
#' vague component step over the sharp peak the informative one puts in
#' \eqn{i(\theta)}, so the estimate never settles.
#'
#' This function instead integrates \eqn{p\,i} directly, over panels split at
#' every component's centre and tails, with Gauss-Legendre quadrature on each
#' panel. Every component then gets panels matched to its own width, whatever
#' the spread of scales, and the result agrees with RBesT to around 1e-10 while
#' running on all replicates at once.
#'
#' Several cases short-circuit the quadrature. A single-component mixture has
#' constant Fisher information, so its ELIR is exactly
#' \eqn{\sigma^2/\mathrm{variance}}; so does any row whose other components all
#' have weight zero, as when the Egidi mixture selects no weak component. A prior
#' shared by every replicate is integrated once and rescaled, since ELIR is
#' proportional to \eqn{\sigma^2}. A prior that varies across replicates through
#' one component's standard deviation alone, as the empirical Bayes robust
#' mixture's vague component does, is integrated at Chebyshev nodes over the
#' range of that standard deviation and interpolated - see
#' [interpolate_smooth_function()] - to a relative error below 1e-9.
#'
#' @param weights Mixture weights: a vector when the prior is shared by every
#'   replicate, or a `n_replicates x n_components` matrix.
#' @param means Component means, shaped like `weights`.
#' @param sds Component standard deviations, shaped like `weights`.
#' @param sigma Reference scale, either a single value or one value per
#'   replicate.
#' @param n_nodes Number of Gauss-Legendre nodes per panel.
#' @param spread How many standard deviations each component's panels reach.
#' @return Vector of ELIR effective sample sizes, one per replicate.
#' @export
normal_mixture_elir_ess <- function(weights, means, sds, sigma,
                                    n_nodes = 40L, spread = 9) {
  if (!is.matrix(weights)) {
    # The prior is shared by every replicate, so the integral only has to be
    # evaluated once: ELIR is proportional to the squared reference scale.
    unit_scale <- normal_mixture_elir_ess(
      weights = matrix(weights, nrow = 1),
      means = matrix(means, nrow = 1),
      sds = matrix(sds, nrow = 1),
      sigma = 1,
      n_nodes = n_nodes, spread = spread
    )
    return(sigma^2 * unit_scale)
  }

  n_replicates <- nrow(weights)
  sigma <- rep_len(sigma, n_replicates)

  if (ncol(weights) == 1L) {
    return(sigma^2 / sds[, 1]^2)
  }

  # A row with a single component of positive weight is that component alone.
  single <- rowSums(weights > 0) == 1L
  if (any(single)) {
    ess <- numeric(n_replicates)
    rows <- which(single)
    component <- max.col(weights[rows, , drop = FALSE] > 0, ties.method = "first")
    ess[rows] <- sigma[rows]^2 / sds[cbind(rows, component)]^2
    rest <- which(!single)
    if (length(rest) > 0) {
      ess[rest] <- normal_mixture_elir_ess(
        weights = weights[rest, , drop = FALSE],
        means = means[rest, , drop = FALSE],
        sds = sds[rest, , drop = FALSE],
        sigma = sigma[rest],
        n_nodes = n_nodes, spread = spread
      )
    }
    return(ess)
  }

  # A prior that varies across replicates only through one component's
  # standard deviation has a unit-scale ELIR that is a smooth function of it.
  constant <- function(x) all(x == rep(x[1, ], each = n_replicates))
  varying_sd <- which(vapply(
    seq_len(ncol(sds)), function(k) any(sds[, k] != sds[1, k]), logical(1)
  ))
  if (n_replicates > 1L && constant(weights) && constant(means) &&
      length(varying_sd) == 1L) {
    unit_scale <- interpolate_smooth_function(
      function(component_sd) {
        n_points <- length(component_sd)
        point_sds <- matrix(sds[1, ], nrow = n_points, ncol = ncol(sds), byrow = TRUE)
        point_sds[, varying_sd] <- component_sd
        normal_mixture_elir_quadrature(
          weights = weights[rep(1L, n_points), , drop = FALSE],
          means = means[rep(1L, n_points), , drop = FALSE],
          sds = point_sds,
          sigma = 1,
          n_nodes = n_nodes, spread = spread
        )
      },
      sds[, varying_sd]
    )
    return(sigma^2 * unit_scale)
  }

  normal_mixture_elir_quadrature(weights, means, sds, sigma, n_nodes, spread)
}

#' ELIR effective sample size by panelled Gauss-Legendre quadrature
#'
#' @description The quadrature behind [normal_mixture_elir_ess()], for mixtures
#' with at least two components given as matrices with one row per replicate.
#'
#' @inheritParams normal_mixture_elir_ess
#' @return Vector of ELIR effective sample sizes, one per replicate.
#' @keywords internal
normal_mixture_elir_quadrature <- function(weights, means, sds, sigma,
                                           n_nodes = 40L, spread = 9) {
  n_replicates <- nrow(weights)
  sigma <- rep_len(sigma, n_replicates)

  if (n_replicates == 1L && length(unique(means[1, ])) == 1L) {
    information <- centered_normal_mixture_information(
      weights = weights[1, ],
      sds = sds[1, ]
    )
    return(sigma^2 * information)
  }

  breakpoints <- mixture_support_breakpoints(means, sds, spread)
  rule <- statmod::gauss.quad(n_nodes, kind = "legendre")

  expected_information <- numeric(n_replicates)
  for (panel in seq_len(ncol(breakpoints) - 1L)) {
    lower <- breakpoints[, panel]
    upper <- breakpoints[, panel + 1L]
    half_width <- (upper - lower) / 2
    midpoint <- (upper + lower) / 2

    nodes <- midpoint + outer(half_width, rule$nodes)
    integrand <- normal_mixture_density_information(weights, means, sds, nodes)
    expected_information <- expected_information +
      half_width * drop(integrand %*% rule$weights)
  }

  sigma^2 * expected_information
}


#' Fisher information of a centred normal scale mixture
#'
#' @description All components of the power-prior mixtures have the same mean.
#' In that case the expected Fisher information can be integrated directly as
#' `integral p(x) score(x)^2 dx`. This avoids constructing three panels per
#' component and turns the ELIR calculation for a thousand-component
#' quadrature mixture from quadratic work into a single adaptive integral.
#'
#' @param weights Component weights.
#' @param sds Component standard deviations.
#' @return Expected Fisher information for unit reference scale.
#' @keywords internal
centered_normal_mixture_information <- function(weights, sds) {
  weights <- weights / sum(weights)
  log_weights <- log(weights)
  precisions <- 1 / sds^2

  integrand <- function(x) {
    vapply(x, function(value) {
      log_density <- log_weights + stats::dnorm(
        value,
        mean = 0,
        sd = sds,
        log = TRUE
      )
      largest <- max(log_density)

      if (!is.finite(largest)) {
        return(0)
      }

      scaled_density <- exp(log_density - largest)
      normaliser <- sum(scaled_density)
      density <- exp(largest) * normaliser
      score <- value * sum(scaled_density * precisions) / normaliser

      density * score^2
    }, numeric(1))
  }

  2 * stats::integrate(
    integrand,
    lower = 0,
    upper = Inf,
    rel.tol = 1e-8,
    subdivisions = 500L
  )$value
}

#' Density times Fisher information of a normal mixture at a grid of points
#'
#' @description Returns \eqn{p(x)\,i(x)}, the integrand of the ELIR expectation,
#' with \eqn{i(x) = -\partial^2_x \log p(x)}. Both factors come out of the same
#' log-sum-exp pass, which keeps a component with negligible responsibility from
#' underflowing.
#'
#' @param weights `n_replicates x n_components` matrix of mixture weights.
#' @param means `n_replicates x n_components` matrix of component means.
#' @param sds `n_replicates x n_components` matrix of component standard
#'   deviations.
#' @param x `n_replicates x n_points` matrix of evaluation points.
#' @return A `n_replicates x n_points` matrix of \eqn{p(x)\,i(x)}.
#' @keywords internal
normal_mixture_density_information <- function(weights, means, sds, x) {
  n_components <- ncol(weights)
  dims <- dim(x)

  # Component log densities, stacked as (replicate x point) slices.
  log_density <- vector("list", n_components)
  for (k in seq_len(n_components)) {
    log_density[[k]] <- log(weights[, k]) +
      stats::dnorm(x, means[, k], sds[, k], log = TRUE)
  }

  largest <- Reduce(pmax, log_density)
  scaled <- lapply(log_density, function(l) exp(l - largest))
  normaliser <- Reduce(`+`, scaled)

  # score = d/dx log p, curvature = sum_k omega_k (phi_k'' / phi_k)
  score <- matrix(0, dims[1], dims[2])
  curvature <- matrix(0, dims[1], dims[2])
  for (k in seq_len(n_components)) {
    omega <- scaled[[k]] / normaliser
    standardised <- (x - means[, k]) / sds[, k]^2
    score <- score - omega * standardised
    curvature <- curvature + omega * (standardised^2 - 1 / sds[, k]^2)
  }

  density <- exp(largest) * normaliser
  density * (score^2 - curvature)
}

#' Integration breakpoints covering every component's own scale
#'
#' @description A mixture whose components differ widely in scale cannot be
#' integrated on a single grid: a rule fine enough for the broad component steps
#' straight over the narrow one. Splitting the range at each component's centre
#' and tails gives every component at least one panel matched to its own width.
#'
#' @param means `n_replicates x n_components` matrix of component means.
#' @param sds `n_replicates x n_components` matrix of component standard
#'   deviations.
#' @param spread How many standard deviations each component should reach.
#' @return A `n_replicates x (3 * n_components)` matrix of breakpoints, sorted
#'   within each row. Repeated values give empty panels, which contribute
#'   nothing.
#' @keywords internal
mixture_support_breakpoints <- function(means, sds, spread = 9) {
  sort_rows(cbind(means - spread * sds, means, means + spread * sds))
}

#' Sort every row of a matrix
#'
#' @description The same as `t(apply(m, 1, sort, na.last = TRUE))`, from one
#' call to [order()] on the whole matrix rather than one call to [sort()] per
#' row, which on ten thousand rows is over a hundred times faster.
#'
#' @param m A numeric matrix.
#' @return `m` with each row sorted increasingly and its missing values last.
#' @keywords internal
sort_rows <- function(m) {
  matrix(m[order(row(m), m, na.last = TRUE)], nrow = nrow(m), byrow = TRUE)
}

#' Expand a prior specification to one row per replicate
#'
#' @param x A vector of component values shared by every replicate, or a matrix
#'   with one row per replicate.
#' @param n_replicates Number of replicates.
#' @return A `n_replicates x n_components` matrix.
#' @keywords internal
recycle_prior_component <- function(x, n_replicates) {
  if (is.matrix(x)) {
    return(x)
  }
  matrix(x, nrow = n_replicates, ncol = length(x), byrow = TRUE)
}

#' Gauss quadrature rule for a discrete measure
#'
#' @description The `n_nodes`-point Gauss rule of the measure
#' \eqn{\sum_k w_k \delta_{x_k}}: the rule that integrates every polynomial of
#' degree below `2 * n_nodes` exactly against it. It is built by the Lanczos
#' process on `diag(nodes)` started from `sqrt(weights)`, which yields the
#' measure's Jacobi matrix; the eigenvalues of that matrix are the rule's nodes
#' and the squared first components of its eigenvectors the weights (Golub and
#' Welsch, 1969). Every Lanczos vector is orthogonalised twice against all the
#' previous ones, which keeps the recurrence stable where the plain three-term
#' one loses orthogonality within a few dozen steps.
#'
#' @param nodes Atoms of the measure.
#' @param weights Positive masses of the atoms.
#' @param n_nodes Number of nodes wanted. A measure with fewer distinct atoms
#'   gets a rule with as many nodes as it has atoms, which is then exact.
#' @return A list with the rule's `nodes` and `weights`; the weights sum to
#'   `sum(weights)`.
#' @keywords internal
gauss_rule_for_discrete_measure <- function(nodes, weights, n_nodes) {
  total <- sum(weights)
  n_nodes <- min(n_nodes, length(nodes))
  basis <- matrix(0, length(nodes), n_nodes)
  diagonal <- numeric(n_nodes)
  off_diagonal <- numeric(n_nodes)
  basis[, 1] <- sqrt(weights / total)
  scale <- max(abs(nodes))

  for (j in seq_len(n_nodes)) {
    residual <- nodes * basis[, j]
    diagonal[j] <- sum(basis[, j] * residual)
    previous <- basis[, seq_len(j), drop = FALSE]
    for (pass in 1:2) {
      residual <- residual - previous %*% crossprod(previous, residual)
    }
    if (j == n_nodes) {
      break
    }
    off_diagonal[j] <- sqrt(sum(residual^2))
    # The Krylov space is exhausted: the measure has only j distinct atoms,
    # and the rule on them is already exact.
    if (off_diagonal[j] <= 1e-13 * scale) {
      n_nodes <- j
      break
    }
    basis[, j + 1] <- residual / off_diagonal[j]
  }

  jacobi <- diag(diagonal[seq_len(n_nodes)], n_nodes)
  if (n_nodes > 1) {
    band <- off_diagonal[seq_len(n_nodes - 1)]
    jacobi[cbind(seq_len(n_nodes - 1), 2:n_nodes)] <- band
    jacobi[cbind(2:n_nodes, seq_len(n_nodes - 1))] <- band
  }
  decomposition <- eigen(jacobi, symmetric = TRUE)

  list(
    nodes = decomposition$values,
    weights = total * decomposition$vectors[1, ]^2
  )
}

#' Compress a normal scale mixture into a few components
#'
#' @description A normal mixture whose components all share one mean is a
#' distribution over the component variance `v`, and the conjugate update of
#' [normal_mixture_posterior()] depends on each component through `v` alone.
#' Every posterior summary is then an integral against that distribution, and
#' a Gauss rule for it with a few dozen nodes computes them as accurately as
#' the hundreds of components it replaces.
#'
#' The rule is built in \eqn{r = \sqrt{c / (v + c)}}, where `c` is a typical
#' squared standard error of the observations. In that variable the marginal
#' likelihood, the shrinkage factor and the posterior variance are all analytic
#' over the whole range of `v`, including the near-flat components whose
#' variance runs to 1e150, so the Gauss rule converges geometrically: 24 nodes
#' reproduce the 1728-component commensurate power prior to rounding error.
#' Rules built in `log(v)`, or with the likelihood's square-root factor folded
#' into the weights, converge far more slowly or stall around 1e-9.
#'
#' @param weights Component weights.
#' @param variances Component variances.
#' @param reference_variance The constant `c` above.
#' @param n_nodes Number of components wanted.
#' @return A list with the compressed `weights` and `variances`, or the input
#'   unchanged when it has no more than `n_nodes` components.
#' @keywords internal
compress_normal_scale_mixture <- function(weights, variances,
                                          reference_variance, n_nodes) {
  if (length(weights) <= n_nodes) {
    return(list(weights = weights, variances = variances))
  }
  scale <- sqrt(reference_variance / (variances + reference_variance))
  rule <- gauss_rule_for_discrete_measure(scale, weights, n_nodes)
  # Gauss nodes lie inside the atoms' range; clamping only undoes rounding.
  node <- pmin(pmax(rule$nodes, min(scale)), max(scale))
  list(
    weights = rule$weights,
    variances = reference_variance * (1 - node^2) / node^2
  )
}

#' Interpolate a smooth, expensive function of a positive scalar
#'
#' @description Evaluates `f` at Chebyshev-Lobatto nodes in `log(x)` over the
#' range of `x` and interpolates barycentrically between them, which converges
#' geometrically for a function analytic in `log(x)`. The interpolant is checked
#' against `f` halfway between the nodes; the nodes are doubled, reusing every
#' evaluation, until the largest relative error there is below `tolerance`.
#' When `x` has no more distinct values than the nodes would take, `f` is
#' evaluated at those values directly instead.
#'
#' @param f Vectorised function of positive numbers.
#' @param x Positive values at which `f` is wanted.
#' @param n_nodes Number of nodes to start from.
#' @param tolerance Largest relative error accepted at the check points.
#' @return `f` at `x`, interpolated where that is cheaper than evaluating it.
#' @keywords internal
interpolate_smooth_function <- function(f, x, n_nodes = 33L, tolerance = 1e-9) {
  distinct <- unique(x)
  # Checking an interpolant costs about as many evaluations as it has nodes.
  directly <- function() f(distinct)[match(x, distinct)]
  if (length(distinct) <= 2L * n_nodes) {
    return(directly())
  }
  lobatto <- function(n) cos(pi * seq(0, n - 1) / (n - 1))
  lower <- log(min(x))
  upper <- log(max(x))
  to_x <- function(z) exp((lower + upper) / 2 + (upper - lower) / 2 * z)

  node_z <- lobatto(n_nodes)
  node_values <- f(to_x(node_z))
  repeat {
    # The next rule's extra nodes lie halfway between these, in angle, so they
    # check this interpolant and are then reused by the next one.
    finer_z <- lobatto(2L * n_nodes - 1L)
    extra <- seq(2L, 2L * n_nodes - 2L, by = 2L)
    extra_values <- f(to_x(finer_z[extra]))
    estimate <- chebyshev_lobatto_interpolate(node_z, node_values, finer_z[extra])
    error <- max(abs(estimate - extra_values) / pmax(abs(extra_values), .Machine$double.xmin))
    if (is.finite(error) && error <= tolerance) {
      z <- (log(x) - (lower + upper) / 2) / ((upper - lower) / 2)
      return(chebyshev_lobatto_interpolate(node_z, node_values, pmin(pmax(z, -1), 1)))
    }
    values <- numeric(2L * n_nodes - 1L)
    values[extra] <- extra_values
    values[-extra] <- node_values
    node_z <- finer_z
    node_values <- values
    n_nodes <- 2L * n_nodes - 1L
    if (length(distinct) <= 2L * n_nodes) {
      return(directly())
    }
  }
}

#' Barycentric interpolation at Chebyshev-Lobatto nodes
#'
#' @param nodes The nodes `cos(pi * k / (n - 1))`, `k = 0, ..., n - 1`.
#' @param values Function values at the nodes.
#' @param z Points in `[-1, 1]` to interpolate at.
#' @return The interpolant at `z`.
#' @keywords internal
chebyshev_lobatto_interpolate <- function(nodes, values, z) {
  n <- length(nodes)
  weights <- (-1)^(seq_len(n) - 1L)
  weights[c(1L, n)] <- weights[c(1L, n)] / 2
  difference <- outer(z, nodes, "-")
  exact <- difference == 0
  difference[exact] <- 1
  terms <- matrix(weights, nrow = length(z), ncol = n, byrow = TRUE) / difference
  result <- drop(terms %*% values) / rowSums(terms)
  hit <- which(rowSums(exact) > 0)
  result[hit] <- values[max.col(exact[hit, , drop = FALSE], ties.method = "first")]
  result
}

#' Find a root of every row's function within its bracket
#'
#' @description Regula falsi with the Illinois modification, run on every row
#' at once. Each row keeps an interval whose ends give its function opposite
#' signs, so the root is never lost, and whenever the same end survives twice
#' in a row its function value is halved for the next interpolation, which
#' restores superlinear convergence where plain regula falsi would stall. A
#' point the interpolation cannot place strictly inside the interval, as with
#' an infinite end, is replaced by the midpoint. A row stops when its interval
#' is narrower than `tolerance` times the larger of one and its magnitude, or
#' when its function is exactly zero, which collapses the interval onto the
#' root.
#'
#' @param f Function of the points and the indices of the rows they belong
#'   to, returning one value per point.
#' @param lower,upper Ends of each row's interval.
#' @param f_lower,f_upper The function at those ends, of opposite signs or
#'   zero.
#' @param tolerance Relative width at which a row stops.
#' @param max_iterations Iteration cap, far above what convergence needs.
#' @return A list with the final `lower` and `upper` ends, the function's sign
#'   there as `f_lower` and `f_upper` (its magnitude is rescaled by the
#'   Illinois step), and `root`, the midpoint of the final interval.
#' @keywords internal
vectorised_bracketed_root <- function(f, lower, upper, f_lower, f_upper,
                                      tolerance = 1e-13,
                                      max_iterations = 100L) {
  a <- lower
  b <- upper
  fa <- f_lower
  fb <- f_upper
  # The end kept by the previous step: -1 for the lower, +1 for the upper.
  kept <- integer(length(a))

  on_lower <- fa == 0
  b[on_lower] <- a[on_lower]
  fb[on_lower] <- 0
  on_upper <- fb == 0 & !on_lower
  a[on_upper] <- b[on_upper]
  fa[on_upper] <- 0

  width_left <- function(i) {
    b[i] - a[i] > tolerance * pmax(1, abs(a[i]), abs(b[i]))
  }
  active <- which(fa != 0 & fb != 0)
  active <- active[width_left(active)]

  for (iteration in seq_len(max_iterations)) {
    if (length(active) == 0) {
      break
    }
    A <- a[active]
    B <- b[active]
    FA <- fa[active]
    FB <- fb[active]

    x <- (A * FB - B * FA) / (FB - FA)
    outside <- !is.finite(x) | x <= A | x >= B
    x[outside] <- (A[outside] + B[outside]) / 2

    fx <- f(x, active)
    root <- fx == 0
    root[is.na(root)] <- FALSE
    like_lower <- !root & sign(fx) == sign(FA)
    like_lower[is.na(like_lower)] <- FALSE
    like_upper <- !root & !like_lower

    # The lower end moves: if it moved last time too, the upper end has
    # survived twice, so its weight in the interpolation is halved.
    moved <- active[like_lower]
    halve <- moved[kept[moved] == -1L]
    fb[halve] <- fb[halve] / 2
    a[moved] <- x[like_lower]
    fa[moved] <- fx[like_lower]
    kept[moved] <- -1L

    moved <- active[like_upper]
    halve <- moved[kept[moved] == 1L]
    fa[halve] <- fa[halve] / 2
    b[moved] <- x[like_upper]
    fb[moved] <- fx[like_upper]
    kept[moved] <- 1L

    found <- active[root]
    a[found] <- x[root]
    b[found] <- x[root]
    fa[found] <- 0
    fb[found] <- 0

    active <- active[!root]
    active <- active[width_left(active)]
  }

  list(lower = a, upper = b, f_lower = fa, f_upper = fb, root = (a + b) / 2)
}
