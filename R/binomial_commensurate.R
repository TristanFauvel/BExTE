# Commensurate priors for the binomial model.
#
# The source and target studies have their own risk differences, theta_S and
# theta_T, and their own control rates, u and v, all with uniform initial
# priors (uniform response rates in each arm). The source likelihood, raised
# to the power gamma and normalised, gives the source power posterior
#
#   p_gamma(theta_S), with normalising constant Z_S(gamma), which factorises
#   over the two source arms under the uniform initial prior.
#
# The target effect is linked to the source one by the commensurability
# parameter tau:
#
#   theta_T | theta_S, tau, v ~ N(theta_S, 1 / tau) truncated to (-v, 1 - v),
#
# renormalised for every (v, theta_S, tau), as the robust mixture prior is.
# For the commensurate power prior gamma | tau ~ Beta(g(tau), 1), as in the
# normal case (Hobbs et al., 2011); for the commensurate prior gamma = 1.
#
# Integrated over theta_S, gamma and tau, this is a fixed prior on (v,
# theta_T), tabulated on the lattice of binomial_npp_prior_kernels(), so the
# posterior of a dataset is a single weighted sum: see BinomialLatticePrior.
#
# The variance of the commensurability kernel and the tau nodes are those of
# the normal-likelihood models, commensurate_tau_quadrature(): only how the
# source and target data enter differs.


#' Source power posterior of the risk difference, integrated over gamma
#'
#' @description For each commensurability node, the source power posterior
#'   p_gamma(theta_S) averaged over gamma | tau ~ Beta(g(tau), 1), and the same
#'   average weighted by gamma and by gamma^2. Because p_gamma(d) is a sum over
#'   the source control rate of exp(gamma l) / Z_S(gamma), with l the source
#'   log likelihood, the average is a sum of h(l) over the source control rate,
#'   where h is a function of one scalar, tabulated once per distinct shape
#'   g(tau) and interpolated (as in [binomial_npp_prior_kernels()]).
#'
#' @param source_counts List of the four source counts.
#' @param shapes Beta shape g(tau) of each node, or `NULL` for gamma = 1.
#' @param n_lattice Number of lattice points N.
#' @param n_log_likelihood_points Points of the h tables.
#' @return A list with `differences` (in lattice units, all of
#'   -(N - 1), ..., N - 1) and the (2N - 1) x n matrices `density`,
#'   `gamma_first` and `gamma_second`, one column per node; the last two are
#'   `NULL` for gamma = 1.
#' @keywords internal
binomial_source_power_posteriors <- function(source_counts, shapes, n_lattice,
                                             n_log_likelihood_points = 4001L) {
  N <- as.integer(n_lattice)
  rates <- (seq_len(N) - 0.5) / N
  arm_log_likelihood <- function(n, successes) {
    log_likelihood <- successes * log(rates) + (n - successes) * log1p(-rates)
    log_likelihood - max(log_likelihood)
  }
  control <- arm_log_likelihood(source_counts$n_control_source,
                                source_counts$n_successes_control_source)
  treatment <- arm_log_likelihood(source_counts$n_treatment_source,
                                  source_counts$n_successes_treatment_source)

  differences <- seq(-(N - 1L), N - 1L)
  source_rate <- outer(seq_len(N), differences, "+")
  inside <- source_rate >= 1L & source_rate <= N
  point_log_likelihood <- matrix(-Inf, N, length(differences))
  point_log_likelihood[inside] <- control[row(source_rate)[inside]] +
    treatment[source_rate[inside]]

  if (is.null(shapes)) {
    density <- colSums(exp(point_log_likelihood))
    return(list(
      differences = differences,
      density = matrix(density / sum(density), ncol = 1),
      gamma_first = NULL,
      gamma_second = NULL
    ))
  }

  # Interpolation coordinates of every admissible point in the h tables, which
  # are tabulated evenly in log(1 - l), where they are smooth.
  lowest <- min(point_log_likelihood[inside])
  table_points <- seq(0, log1p(-lowest), length.out = n_log_likelihood_points)
  table_log_likelihood <- -expm1(table_points)
  coordinate <- log1p(-point_log_likelihood[inside])
  position <- findInterval(coordinate, table_points, all.inside = TRUE)
  fraction <- (coordinate - table_points[position]) /
    (table_points[position + 1L] - table_points[position])

  distinct <- unique(shapes)
  columns <- lapply(distinct, function(shape) {
    rule <- npp_gamma_rule(shape, 1)
    gamma <- rule$nodes
    # Z_S(gamma), up to a constant: the two source arms integrate separately.
    log_normalizer <- log(colSums(exp(outer(control, gamma)))) +
      log(colSums(exp(outer(treatment, gamma))))
    base <- log(rule$weights) - log_normalizer
    log_gamma <- ifelse(gamma > 0, log(gamma), -Inf)
    lapply(0:2, function(m) {
      terms <- base + if (m == 0) 0 else m * log_gamma
      keep <- is.finite(terms)
      log_table <- row_log_sum_exp(outer(table_log_likelihood, gamma[keep]) +
                                     rep(terms[keep], each = length(table_log_likelihood)))
      # Interpolated in log h, then summed over the source control rate.
      values <- matrix(0, N, length(differences))
      values[inside] <- exp((1 - fraction) * log_table[position] +
                              fraction * log_table[position + 1L])
      colSums(values)
    })
  })
  pick <- function(m) {
    out <- vapply(match(shapes, distinct), function(index) columns[[index]][[m]],
                  numeric(length(differences)))
    matrix(out, nrow = length(differences))
  }
  list(
    differences = differences,
    density = pick(1L),
    gamma_first = pick(2L),
    gamma_second = pick(3L)
  )
}


#' Prior kernels of the binomial commensurate priors
#'
#' @description The prior of the target control rate and risk difference,
#'   integrated over the source risk difference, the power parameter and the
#'   commensurability parameter, on the lattice, with the kernels weighted by
#'   the commensurability parameter and by the power parameter, and by their
#'   squares, for their posterior moments.
#'
#' @param source_counts List of the four source counts.
#' @param tau_rule Output of [commensurate_tau_quadrature()].
#' @param borrows_power_parameter `TRUE` for the commensurate power prior,
#'   `FALSE` for the commensurate prior (gamma = 1).
#' @param tau_moments_exist Output of [commensurate_tau_moments_exist()].
#' @param n_lattice Number of lattice points N.
#' @return A list with `n_lattice`, `rates`, `differences`, `kernel` and
#'   `moments`, as [binomial_npp_posterior()] reads them.
#' @keywords internal
binomial_commensurate_prior_kernels <- function(source_counts,
                                                tau_rule,
                                                borrows_power_parameter,
                                                tau_moments_exist,
                                                n_lattice = 1000L) {
  N <- as.integer(n_lattice)
  shapes <- if (borrows_power_parameter) g_function(tau_rule$log_tau) else NULL
  source <- binomial_source_power_posteriors(source_counts, shapes, N)
  differences <- source$differences
  n_differences <- length(differences)
  weights <- tau_rule$weights / sum(tau_rule$weights)
  # The kernel's variance, 1 / tau, in units of the lattice spacing squared.
  variance <- tau_rule$inverse_tau * N^2

  # Admissible target effects for each target control rate j: 1 <= j + t <= N.
  target_rate <- outer(seq_len(N), differences, "+")
  admissible <- target_rate >= 1L & target_rate <= N

  # One kernel for the prior, and one per moment that is reported.
  n_outputs <- if (borrows_power_parameter) 5L else 3L
  outputs <- replicate(n_outputs, matrix(0, N, n_differences), simplify = FALSE)

  add <- function(index, amount) {
    outputs[[index]] <<- outputs[[index]] + amount
  }

  for (node in seq_along(weights)) {
    if (weights[node] <= 0) next
    densities <- list(source$density[, if (borrows_power_parameter) node else 1L])
    if (borrows_power_parameter) {
      densities[[2]] <- source$gamma_first[, node]
      densities[[3]] <- source$gamma_second[, node]
    }
    # The source effects that carry mass at this node.
    support <- which(densities[[1]] > 1e-300 * max(densities[[1]]))

    spread <- sqrt(variance[node])
    if (!is.finite(spread) || spread > 50 * N) {
      # The kernel is flat across the unit interval: given the target control
      # rate, the target effect is uniform over its N admissible values.
      blocks <- lapply(densities, function(density) {
        admissible * (sum(density[support]) / N)
      })
    } else if (spread < 0.2) {
      # Narrower than a fifth of the lattice spacing: theta_T = theta_S, kept
      # where it is admissible for the target control rate and renormalised
      # there (each source effect is admissible or not; nothing to spread).
      blocks <- lapply(densities, function(density) {
        admissible * rep(density, each = N)
      })
    } else {
      # Discrete normal kernel between source effect d and target effect t,
      # within twelve standard deviations, renormalised over the admissible
      # target effects of each target control rate.
      reach <- min(2L * N, as.integer(ceiling(12 * spread)))
      offsets <- seq(-(2L * N), 2L * N)
      kernel <- exp(-0.5 * offsets^2 / variance[node])
      kernel[abs(offsets) > reach] <- 0
      # kernel[i] sits at offset i - 2N - 1, so the kernel summed over every
      # offset up to o is cumulative[o + 2N + 2].
      cumulative <- c(0, cumsum(kernel))
      at <- function(offset) cumulative[offset + 2L * N + 2L]
      d <- differences[support]
      # Normaliser for (j, d): sum over t from 1 - j to N - j of kernel(t - d).
      upper <- outer(seq_len(N), d, function(j, dd) pmin(N - j - dd, 2L * N))
      lower <- outer(seq_len(N), d, function(j, dd) pmax(-j - dd, -(2L * N) - 1L))
      normaliser <- matrix(at(upper) - at(lower), nrow = N)
      # A kernel that leaves no mass on the admissible effects (more than about
      # 38 standard deviations away) contributes nothing; a denormal normaliser
      # would otherwise give an infinite weight, and Inf * 0 = NaN downstream.
      reciprocal <- ifelse(normaliser > 1e-280, 1 / normaliser, 0)
      targets <- seq(max(-(N - 1L), min(d) - reach), min(N - 1L, max(d) + reach))
      transfer <- matrix(kernel[outer(d, targets, function(dd, tt) tt - dd) + 2L * N + 1L],
                         nrow = length(d))
      columns <- targets + N
      blocks <- lapply(densities, function(density) {
        block <- matrix(0, N, n_differences)
        block[, columns] <- (reciprocal * rep(density[support], each = N)) %*% transfer
        block * admissible
      })
    }

    w <- weights[node]
    add(1L, w * blocks[[1]])
    add(2L, w * tau_rule$tau[node] * blocks[[1]])
    add(3L, w * tau_rule$tau[node]^2 * blocks[[1]])
    if (borrows_power_parameter) {
      add(4L, w * blocks[[2]])
      add(5L, w * blocks[[3]])
    }
  }

  moments <- list(heterogeneity_parameter = list(
    first = if (tau_moments_exist[["mean"]]) outputs[[2]] else NULL,
    second = if (tau_moments_exist[["sd"]]) outputs[[3]] else NULL
  ))
  if (borrows_power_parameter) {
    moments$power_parameter <- list(first = outputs[[4]], second = outputs[[5]])
  }
  list(
    n_lattice = N,
    rates = (seq_len(N) - 0.5) / N,
    differences = differences,
    kernel = outputs[[1]],
    moments = moments
  )
}


#' BinomialCommensuratePowerPrior class
#'
#' @description The commensurate power prior of [GaussianCommensuratePowerPrior]
#'   for a binary endpoint, with the binomial likelihoods of both arms of each
#'   study instead of a normal approximation of the risk difference; see the
#'   comment at the top of `R/binomial_commensurate.R` for the model. The
#'   posterior is computed on the lattice of [BinomialLatticePrior].
#'
#' @field method Method name.
#' @field heterogeneity_prior_family Family of the prior on the
#'   commensurability parameter.
#' @field borrows_power_parameter Whether the source likelihood is discounted
#'   by a power parameter.
#' @field n_tau_nodes Quadrature nodes on the commensurability parameter, before
#'   the adjustments of [commensurate_tau_quadrature()].
#' @export
BinomialCommensuratePowerPrior <- R6::R6Class(
  "BinomialCommensuratePowerPrior",
  inherit = BinomialLatticePrior,
  public = list(
    method = "commensurate_power_prior",
    heterogeneity_prior_family = NULL,
    borrows_power_parameter = TRUE,
    n_tau_nodes = 48L,

    #' @description Initialize the model.
    #' @param prior The prior object.
    #' @param mcmc_config The MCMC configuration; only the quadrature engine is
    #'   supported.
    initialize = function(prior, mcmc_config) {
      super$initialize(prior = prior, mcmc_config = mcmc_config)
      self$heterogeneity_prior_family <- prior$method_parameters$heterogeneity_prior$family
    },

    #' @description The prior kernels, computed once per worker and shared.
    #' @return The output of [binomial_commensurate_prior_kernels()].
    kernels = function() {
      lattice_kernel_cached(
        list("binomial commensurate", self$kernel_key(), self$n_lattice),
        function() {
          binomial_commensurate_prior_kernels(
            source_counts = self$source_counts(),
            tau_rule = commensurate_tau_quadrature(self, self$n_tau_nodes),
            borrows_power_parameter = self$borrows_power_parameter,
            tau_moments_exist = commensurate_tau_moments_exist(
              self$heterogeneity_prior_family,
              self$prior$method_parameters$heterogeneity_prior
            ),
            n_lattice = self$n_lattice
          )
        }
      )
    },

    #' @description What identifies the prior.
    #' @return A list.
    kernel_key = function() {
      c(self$source_counts(), list(
        heterogeneity_prior = self$prior$method_parameters$heterogeneity_prior,
        borrows_power_parameter = self$borrows_power_parameter,
        n_tau_nodes = self$n_tau_nodes
      ))
    },

    #' @description Record the posterior moments of the commensurability
    #' parameter and, for the commensurate power prior, of the power parameter.
    compute_posterior_parameters = function() {
      parameters <- list(
        heterogeneity_parameter_mean = self$grid_posterior$heterogeneity_parameter_mean,
        heterogeneity_parameter_std = self$grid_posterior$heterogeneity_parameter_std
      )
      if (self$borrows_power_parameter) {
        parameters$power_parameter_mean <- self$grid_posterior$power_parameter_mean
        parameters$power_parameter_std <- self$grid_posterior$power_parameter_std
      }
      self$posterior_parameters <- parameters
    }
  )
)


#' BinomialCommensuratePrior class
#'
#' @description The commensurate prior for a binary endpoint: the commensurate
#'   power prior of [BinomialCommensuratePowerPrior] with the power parameter
#'   fixed at one, as [GaussianCommensuratePrior] is of
#'   [GaussianCommensuratePowerPrior].
#'
#' @field method Method name.
#' @field borrows_power_parameter Always `FALSE`.
#' @export
BinomialCommensuratePrior <- R6::R6Class(
  "BinomialCommensuratePrior",
  inherit = BinomialCommensuratePowerPrior,
  public = list(
    method = "commensurate_prior",
    borrows_power_parameter = FALSE
  )
)
