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


#' Event counts from observed response rates
#'
#' @description Recovers the whole number of responders behind a rate that was
#'   computed as `count / n`. `(count / n) * n` often lands just below `count`
#'   in floating point (7 / 71 * 71 is 6.9999...), so truncating it with
#'   `as.integer()` silently loses an event; the product is rounded instead.
#'   A rate that is not a count divided by `n` is an error rather than a
#'   silently rounded surrogate.
#'
#' @param rate Numeric vector of response rates.
#' @param n Numeric vector of sample sizes, recycled against `rate`.
#' @return An integer vector of event counts.
#' @keywords internal
counts_from_rate <- function(rate, n) {
  counts <- rate * n
  rounded <- round(counts)
  if (any(!is.finite(counts)) || any(abs(counts - rounded) > 1e-8 * pmax(1, n))) {
    stop(
      "Response rate ", paste(format(rate[abs(counts - rounded) > 1e-8 * pmax(1, n)], digits = 15), collapse = ", "),
      " is not a whole number of events out of ", paste(unique(n), collapse = ", "), "."
    )
  }
  as.integer(rounded)
}


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
#'   v. The grid spans that region, clipped to \eqn{[-1, 1]}, with a spacing fine
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


#' Gauss-Legendre nodes and weights on (-1, 1), computed once per size
#'
#' @param n_nodes Number of nodes.
#' @return A list with `nodes` and `weights`.
#' @keywords internal
legendre_rule <- local({
  rules <- list()
  function(n_nodes) {
    key <- as.character(n_nodes)
    if (is.null(rules[[key]])) {
      rules[[key]] <<- statmod::gauss.quad(n_nodes, kind = "legendre")
    }
    rules[[key]]
  }
})


#' Expectation over a Beta-distributed control rate of a function of the
#' treatment rate
#'
#' @description Computes \eqn{E_v[g(\theta + v)]} for each effect
#'   \eqn{\theta}, where \eqn{v \sim Beta(a, b)} is the control rate and
#'   \eqn{g} is the treatment arm's distribution function or density - the
#'   distribution function and density of a difference of independent Beta
#'   variables.
#'
#'   The control rate is integrated in rate space by Gauss-Legendre quadrature
#'   over the Beta's effective support, cut where \eqn{\theta + v} leaves
#'   \eqn{[0, 1]}. There \eqn{g} has a corner, or a jump for a density with a
#'   shape parameter of one, and a rule on a piece that straddled it would
#'   converge slowly; on each smooth piece a few dozen nodes reach an accuracy
#'   a midpoint rule in probability space needs hundreds of thousands of
#'   nodes for.
#'
#' @param effect Treatment effects at which to evaluate the expectation.
#' @param shape1,shape2 Shape parameters of the control rate's Beta.
#' @param treatment_function Function of the treatment rate, vectorised.
#' @param n_nodes Nodes per smooth piece.
#' @param tail Probability left outside the effective support on each side.
#' @return One value per effect.
#' @keywords internal
beta_difference_expectation <- function(effect, shape1, shape2, treatment_function,
                                        n_nodes = 32L, tail = 1e-15) {
  rule <- legendre_rule(n_nodes)
  support <- stats::qbeta(c(tail, 1 - tail), shape1, shape2)
  vapply(effect, function(theta) {
    corners <- pmin(pmax(c(-theta, 1 - theta), support[1]), support[2])
    cuts <- sort(unique(c(support, corners)))
    lower <- cuts[-length(cuts)]
    upper <- cuts[-1]
    kept <- upper > lower
    half <- (upper[kept] - lower[kept]) / 2
    middle <- (upper[kept] + lower[kept]) / 2
    rates <- as.vector(outer(rule$nodes, half) + rep(middle, each = n_nodes))
    weights <- as.vector(outer(rule$weights, half)) * stats::dbeta(rates, shape1, shape2)
    sum(weights * treatment_function(theta + rates)) / sum(weights)
  }, numeric(1))
}


#' A grid posterior as distribution functions
#'
#' @param posterior Output of [grid_posterior()].
#' @return A list of three functions of the treatment effect: `cdf`, `pdf`, and
#'   `sample`, which takes the number of draws.
#' @keywords internal
grid_distribution <- function(posterior) {
  force(posterior)
  list(
    cdf = function(x) grid_posterior_cdf(posterior, x),
    pdf = function(x) grid_posterior_pdf(posterior, x),
    sample = function(n_samples) grid_posterior_sample(posterior, n_samples)
  )
}



#' Posterior of the treatment effect under the binomial power prior
#'
#' @description The binomial conditional power prior: uniform priors on the
#'   source control rate u and the target control rate v, a uniform prior on
#'   the common treatment effect theta over (-min(u, v), 1 - max(u, v)), which
#'   has density 1 / (1 - |u - v|), and the source likelihood raised to the
#'   power gamma.
#'
#'   The rates are discretised on the lattice of [binomial_npp_prior_kernels()]:
#'   the midpoints of N equal cells of \eqn{[0, 1]}, with the treatment effect on the
#'   multiples of the cell width, so that every treatment rate is a lattice
#'   point. The lattice covers the whole unit square, so it follows the
#'   posterior wherever the target data move it, including far into the tails
#'   of the source likelihood when the two studies conflict. Nodes placed on the
#'   quantiles of the source and target control rates' own likelihoods, as an
#'   earlier version of this function used, miss that region: under conflict
#'   the posterior probability of benefit was off by 0.016 and the posterior
#'   mean by up to 0.07 against Stan.
#'
#'   Only the target control rates and treatment rates where the target
#'   likelihood exceeds `1e-20` of its maximum are visited, and every source
#'   control rate, so the cost is N times the number of target lattice points
#'   per arm times the number of treatment effects they reach.
#'
#'   With no target patients the target counts are zero and the result is the
#'   prior.
#'
#' @param power_parameter The power parameter gamma, in \eqn{[0, 1]}.
#' @param n_control_source,n_successes_control_source Source control arm.
#' @param n_treatment_source,n_successes_treatment_source Source treatment arm.
#' @param n_control,n_successes_control Target control arm.
#' @param n_treatment,n_successes_treatment Target treatment arm.
#' @param n_lattice Number of lattice points N on the rates.
#' @param control_rate Target control rate to condition on, or `NULL` to
#'   integrate it out. Conditioning puts the target control rate's whole mass
#'   on the lattice cell that contains it, which confines the treatment effect
#'   to the differences that keep the target treatment rate in \eqn{[0, 1]}.
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
                                           n_lattice = 1000L,
                                           control_rate = NULL) {
  if (!is.numeric(power_parameter) || length(power_parameter) != 1 ||
      is.na(power_parameter) || power_parameter < 0 || power_parameter > 1) {
    stop("The power parameter must be a single number in [0, 1].", call. = FALSE)
  }
  gamma <- power_parameter
  N <- as.integer(n_lattice)
  rates <- (seq_len(N) - 0.5) / N

  # Each arm's likelihood on the lattice, scaled to a maximum of one.
  arm_log_likelihood <- function(n, successes) {
    log_likelihood <- successes * log(rates) + (n - successes) * log1p(-rates)
    log_likelihood - max(log_likelihood)
  }
  source_control <- exp(gamma * arm_log_likelihood(n_control_source, n_successes_control_source))
  source_treatment <- exp(gamma * arm_log_likelihood(n_treatment_source, n_successes_treatment_source))
  target_control <- exp(arm_log_likelihood(n_control, n_successes_control))
  target_treatment <- exp(arm_log_likelihood(n_treatment, n_successes_treatment))

  control_points <- if (is.null(control_rate)) {
    which(target_control > 1e-20)
  } else {
    min(N, max(1L, as.integer(ceiling(control_rate * N))))
  }
  if (!is.null(control_rate)) {
    target_control[] <- 0
    target_control[control_points] <- 1
  }
  treatment_points <- which(target_treatment > 1e-20)
  differences <- seq(min(treatment_points) - max(control_points),
                     max(treatment_points) - min(control_points))

  # The source control rates that carry any discounted likelihood: all of them
  # at a power parameter near 0, a narrow band near 1.
  source_rows <- which(source_control > 1e-300)

  # R x K: the discounted source likelihood at every source control rate i and
  # treatment effect k, zero where the source treatment rate leaves [0, 1].
  source_weight <- source_control[source_rows] *
    lattice_shift_matrix(source_treatment, source_rows, differences)

  # J x K: summed over the source control rate against the prior density of
  # theta given the two control rates, 1 / (N - |i - j|).
  width <- binomial_lattice_width(N)[source_rows, control_points, drop = FALSE]
  kernel <- crossprod(width, source_weight)

  # The target likelihood, zero where the target treatment rate leaves [0, 1].
  likelihood <- target_control[control_points] *
    lattice_shift_matrix(target_treatment, control_points, differences)

  density <- colSums(kernel * likelihood)
  support <- c(min(differences) - 1L, differences, max(differences) + 1L)
  grid_posterior(support / N, c(0, density, 0))
}
