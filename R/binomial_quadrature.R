# Exact posteriors of a difference in response rates, by deterministic quadrature.
#
# The binomial models that borrow the treatment effect have only two or three
# continuous parameters: the target control rate v and the treatment effect
# theta, plus the source control rate u for the power prior. Their posteriors are
# therefore computed here on a grid, to quadrature accuracy, rather than sampled.
#
# The target control rate is integrated on quantile midpoints of its posterior
# under a uniform prior, Beta(s_c + 1, n_c - s_c + 1), as BinomialConjugate does:
# the binomial likelihood of the control arm is then carried by the node
# placement, and every remaining factor is a smooth function of v. The treatment
# arm likelihood, as a function of theta, is the Beta(s_t + 1, n_t - s_t + 1)
# density at v + theta, which is zero outside [0, 1] and so also enforces
# 0 <= v + theta <= 1. What distinguishes the models is the prior density of
# theta given v, relative to the uniform one on (-v, 1 - v).


#' Quantile midpoints of a Beta distribution
#'
#' @description Averaging a function over these nodes integrates it against the
#'   Beta density by the midpoint rule in probability space, which follows the
#'   mass of the distribution without any tuning.
#'
#' @param shape1,shape2 Shape parameters of the Beta distribution.
#' @param n_nodes Number of nodes.
#' @return A numeric vector of `n_nodes` nodes in (0, 1).
#' @keywords internal
beta_quadrature_nodes <- function(shape1, shape2, n_nodes) {
  stats::qbeta((seq_len(n_nodes) - 0.5) / n_nodes, shape1, shape2)
}


#' Grid of treatment effects covering a binomial posterior
#'
#' @description The posterior of the difference in response rates only has mass
#'   where the treatment arm likelihood does, i.e. where theta + v falls in the
#'   bulk of Beta(treatment_shape1, treatment_shape2) for some control rate node
#'   v. The grid spans that region, clipped to [-1, 1], with a spacing fine
#'   enough to resolve the narrowest of `scales`.
#'
#' @param treatment_shape1,treatment_shape2 Shape parameters of the treatment
#'   arm likelihood, as a Beta density in the treatment rate.
#' @param control_nodes Quadrature nodes on the target control rate.
#' @param scales Standard deviations of every factor the grid must resolve.
#' @param points_per_scale Grid points per narrowest standard deviation.
#' @param min_points,max_points Bounds on the number of grid points.
#' @param tail Tail probability left outside the grid on each side.
#' @return An increasing numeric vector of treatment effects.
#' @keywords internal
binomial_effect_grid <- function(treatment_shape1,
                                 treatment_shape2,
                                 control_nodes,
                                 scales,
                                 points_per_scale = 20,
                                 min_points = 401L,
                                 max_points = 20001L,
                                 tail = 1e-12) {
  treatment_range <- stats::qbeta(c(tail, 1 - tail), treatment_shape1, treatment_shape2)
  lower <- max(-1, treatment_range[[1]] - max(control_nodes))
  upper <- min(1, treatment_range[[2]] - min(control_nodes))

  scales <- scales[is.finite(scales) & scales > 0]
  spacing <- if (length(scales) == 0) Inf else min(scales) / points_per_scale
  n_points <- ceiling((upper - lower) / spacing) + 1
  n_points <- as.integer(min(max(n_points, min_points), max_points))

  seq(lower, upper, length.out = n_points)
}


#' Standard deviation of a Beta distribution
#'
#' @param shape1,shape2 Shape parameters.
#' @return The standard deviation.
#' @keywords internal
beta_sd <- function(shape1, shape2) {
  sqrt(beta_variance(shape1, shape2))
}


#' Summarise a density tabulated on a grid
#'
#' @description Normalises the density by the trapezoidal rule and accumulates
#'   it into the distribution function, from which the moments, quantiles and
#'   draws are read. Between grid points the density and the distribution
#'   function are interpolated linearly.
#'
#' @param grid Increasing grid of treatment effects.
#' @param density Unnormalised density on `grid`.
#' @return A list with `grid`, the normalised `density`, the `cdf` at the grid
#'   points, and the posterior `mean` and `variance`.
#' @keywords internal
grid_posterior <- function(grid, density) {
  if (length(grid) != length(density) || length(grid) < 2) {
    stop("The grid and the density must be vectors of the same length, at least 2.",
         call. = FALSE)
  }
  density[!is.finite(density) | density < 0] <- 0

  widths <- diff(grid)
  increments <- widths * (density[-1] + density[-length(density)]) / 2
  total <- sum(increments)
  if (!is.finite(total) || total <= 0) {
    stop("The posterior density has no mass on the quadrature grid.", call. = FALSE)
  }

  density <- density / total
  cdf <- c(0, cumsum(increments)) / total

  first_moment <- grid * density
  mean <- sum(widths * (first_moment[-1] + first_moment[-length(grid)]) / 2)
  second_moment <- (grid - mean)^2 * density
  variance <- sum(widths * (second_moment[-1] + second_moment[-length(grid)]) / 2)

  list(grid = grid, density = density, cdf = cdf, mean = mean, variance = variance)
}


#' Distribution function of a grid posterior
#'
#' @param posterior Output of [grid_posterior()].
#' @param x Points at which to evaluate it.
#' @return The distribution function at `x`.
#' @keywords internal
grid_posterior_cdf <- function(posterior, x) {
  stats::approx(posterior$grid, posterior$cdf, xout = x, yleft = 0, yright = 1)$y
}


#' Density of a grid posterior
#'
#' @param posterior Output of [grid_posterior()].
#' @param x Points at which to evaluate it.
#' @return The density at `x`.
#' @keywords internal
grid_posterior_pdf <- function(posterior, x) {
  stats::approx(posterior$grid, posterior$density, xout = x, yleft = 0, yright = 0)$y
}


#' Quantiles of a grid posterior
#'
#' @description Inverts the piecewise linear distribution function. Its flat
#'   stretches, where the density underflowed to zero, are dropped first, so the
#'   inverse is well defined.
#'
#' @param posterior Output of [grid_posterior()].
#' @param probability Probabilities.
#' @return The quantiles.
#' @keywords internal
grid_posterior_quantile <- function(posterior, probability) {
  increasing <- c(TRUE, diff(posterior$cdf) > 0)
  stats::approx(
    posterior$cdf[increasing],
    posterior$grid[increasing],
    xout = probability,
    rule = 2
  )$y
}


#' Draw from a grid posterior
#'
#' @param posterior Output of [grid_posterior()].
#' @param n_samples Number of draws.
#' @return A vector of draws, by inversion of the distribution function.
#' @keywords internal
grid_posterior_sample <- function(posterior, n_samples) {
  grid_posterior_quantile(posterior, stats::runif(n_samples))
}


#' Posterior of the treatment effect under a truncated normal mixture prior
#'
#' @description The binomial robust mixture prior: the target control rate v is
#'   uniform and, given v, the treatment effect has the mixture prior
#'   sum_k w_k N(theta | mu_k, sd_k^2) / Z_k(v), each component truncated to
#'   (-v, 1 - v), where Z_k(v) = Phi_k(1 - v) - Phi_k(-v). Because the prior
#'   factor separates into a function of theta and a function of v for each
#'   component, the integral over v is one matrix product.
#'
#'   With no target patients the counts are zero and the result is the prior.
#'
#' @param weights,means,sds Parallel vectors describing the mixture.
#' @param n_control,n_successes_control Control arm size and responders.
#' @param n_treatment,n_successes_treatment Treatment arm size and responders.
#' @param n_control_nodes Number of quadrature nodes on the control rate.
#' @param points_per_scale Treatment effect grid points per narrowest standard
#'   deviation, passed to [binomial_effect_grid()].
#' @return A [grid_posterior()] list, with `component_weights`, the posterior
#'   probability of each mixture component.
#' @keywords internal
truncated_normal_mixture_binomial_posterior <- function(weights, means, sds,
                                                        n_control,
                                                        n_successes_control,
                                                        n_treatment,
                                                        n_successes_treatment,
                                                        n_control_nodes = 512L,
                                                        points_per_scale = 20) {
  if (length(weights) != length(means) || length(weights) != length(sds)) {
    stop("The mixture components must be given as parallel vectors.", call. = FALSE)
  }

  control_nodes <- beta_quadrature_nodes(
    n_successes_control + 1, n_control - n_successes_control + 1, n_control_nodes
  )
  treatment_shape1 <- n_successes_treatment + 1
  treatment_shape2 <- n_treatment - n_successes_treatment + 1

  grid <- binomial_effect_grid(
    treatment_shape1, treatment_shape2, control_nodes,
    scales = c(
      sds,
      beta_sd(treatment_shape1, treatment_shape2),
      beta_sd(n_successes_control + 1, n_control - n_successes_control + 1)
    ),
    points_per_scale = points_per_scale
  )

  # G x M: the treatment arm likelihood at every (theta, v) pair.
  treatment_likelihood <- matrix(
    stats::dbeta(outer(grid, control_nodes, "+"), treatment_shape1, treatment_shape2),
    nrow = length(grid)
  )

  # M x K: the reciprocal truncation constant of each component at each node.
  # Where a component has no mass on (-v, 1 - v) it contributes nothing.
  normalisers <- vapply(seq_along(weights), function(k) {
    stats::pnorm(1 - control_nodes, means[k], sds[k]) -
      stats::pnorm(-control_nodes, means[k], sds[k])
  }, numeric(length(control_nodes)))
  normalisers <- matrix(normalisers, nrow = length(control_nodes))
  reciprocal <- ifelse(normalisers > 0, 1 / normalisers, 0)

  inner <- treatment_likelihood %*% reciprocal / length(control_nodes)
  kernels <- vapply(seq_along(weights), function(k) {
    stats::dnorm(grid, means[k], sds[k])
  }, numeric(length(grid)))
  kernels <- matrix(kernels, nrow = length(grid))

  components <- sweep(inner * kernels, 2, weights, "*")
  posterior <- grid_posterior(grid, rowSums(components))

  widths <- diff(grid)
  component_mass <- colSums(
    widths * (components[-1, , drop = FALSE] + components[-length(grid), , drop = FALSE]) / 2
  )
  posterior$component_weights <- component_mass / sum(component_mass)

  posterior
}


#' Posterior of the treatment effect under the binomial power prior
#'
#' @description The binomial conditional power prior: uniform priors on the
#'   source control rate u and the target control rate v, a uniform prior on
#'   the common treatment effect theta over (-min(u, v), 1 - max(u, v)), which
#'   has density 1 / (1 - |u - v|), and the source likelihood raised to the
#'   power gamma. Raised to gamma, the source binomial likelihoods are Beta
#'   kernels, Beta(gamma s + 1, gamma (n - s) + 1), in the control and treatment
#'   rates, so u is integrated on quantile nodes of the first and the second is
#'   evaluated at u + theta. The double sum over u and v is a matrix product.
#'
#'   With no target patients the target counts are zero and the result is the
#'   prior.
#'
#' @param power_parameter The power parameter gamma, in [0, 1].
#' @param n_control_source,n_successes_control_source Source control arm.
#' @param n_treatment_source,n_successes_treatment_source Source treatment arm.
#' @param n_control,n_successes_control Target control arm.
#' @param n_treatment,n_successes_treatment Target treatment arm.
#' @param n_control_nodes Nodes on the target control rate.
#' @param n_source_nodes Nodes on the source control rate.
#' @param points_per_scale Treatment effect grid points per narrowest standard
#'   deviation, passed to [binomial_effect_grid()].
#' @return A [grid_posterior()] list.
#' @keywords internal
binomial_power_prior_posterior <- function(power_parameter,
                                           n_control_source,
                                           n_successes_control_source,
                                           n_treatment_source,
                                           n_successes_treatment_source,
                                           n_control,
                                           n_successes_control,
                                           n_treatment,
                                           n_successes_treatment,
                                           n_control_nodes = 512L,
                                           n_source_nodes = 512L,
                                           points_per_scale = 20) {
  if (!is.numeric(power_parameter) || length(power_parameter) != 1 ||
      is.na(power_parameter) || power_parameter < 0 || power_parameter > 1) {
    stop("The power parameter must be a single number in [0, 1].", call. = FALSE)
  }
  gamma <- power_parameter

  source_control_shape1 <- gamma * n_successes_control_source + 1
  source_control_shape2 <- gamma * (n_control_source - n_successes_control_source) + 1
  source_treatment_shape1 <- gamma * n_successes_treatment_source + 1
  source_treatment_shape2 <- gamma * (n_treatment_source - n_successes_treatment_source) + 1

  target_control_shape1 <- n_successes_control + 1
  target_control_shape2 <- n_control - n_successes_control + 1
  treatment_shape1 <- n_successes_treatment + 1
  treatment_shape2 <- n_treatment - n_successes_treatment + 1

  source_nodes <- beta_quadrature_nodes(source_control_shape1, source_control_shape2, n_source_nodes)
  control_nodes <- beta_quadrature_nodes(target_control_shape1, target_control_shape2, n_control_nodes)

  grid <- binomial_effect_grid(
    treatment_shape1, treatment_shape2, control_nodes,
    scales = c(
      beta_sd(treatment_shape1, treatment_shape2),
      beta_sd(target_control_shape1, target_control_shape2),
      beta_sd(source_treatment_shape1, source_treatment_shape2),
      beta_sd(source_control_shape1, source_control_shape2)
    ),
    points_per_scale = points_per_scale
  )

  # G x U and G x M: the source and target treatment arm factors.
  source_factor <- matrix(
    stats::dbeta(outer(grid, source_nodes, "+"), source_treatment_shape1, source_treatment_shape2),
    nrow = length(grid)
  )
  target_factor <- matrix(
    stats::dbeta(outer(grid, control_nodes, "+"), treatment_shape1, treatment_shape2),
    nrow = length(grid)
  )
  # U x M: the density of the uniform prior on theta given both control rates.
  width_density <- 1 / (1 - abs(outer(source_nodes, control_nodes, "-")))

  density <- rowSums((source_factor %*% width_density) * target_factor) /
    (length(source_nodes) * length(control_nodes))

  grid_posterior(grid, density)
}
