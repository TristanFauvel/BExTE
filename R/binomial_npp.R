# Normalized power prior for the binomial model with a shared risk difference.
#
# The model is the one of the binomial conditional power prior: source and
# target control rates u and v, each uniform, and a risk difference theta shared
# by the two studies, uniform over (-min(u, v), 1 - max(u, v)) given the
# control rates, which has density 1 / (1 - |u - v|). The normalized power prior
# raises the source likelihood to a power gamma ~ Beta(p, q) and divides by its
# normalizing constant Z_S(gamma), so that the prior of gamma is the one stated
# (Duan et al., 2006; Neuenschwander et al., 2009).
#
# Integrated over gamma, the normalized power prior is a fixed prior on
# (u, v, theta): the target data only enter the posterior through their
# likelihood. Everything that depends on the source data and on the prior of
# gamma is therefore computed once, on a lattice of response rates, and a target
# dataset costs a single weighted sum over the lattice.
#
# The rates are discretised on the midpoints r_i = (i - 1/2) / N of a uniform
# lattice, and the risk difference on the multiples k / N of its spacing, so
# that every treatment rate r_i + k / N is a lattice point too. The uniform
# prior of theta given the control rates becomes the discrete uniform on the
# N - |i - j| differences that keep both treatment rates on the lattice, which
# is exactly normalised.
#
# The source log likelihood l(u, u + theta) is the only quantity through which
# the source data and gamma interact, so the prior weight of a lattice point,
# integrated over gamma,
#
#   h(l) = integral of pi(gamma) exp(gamma l) / Z_S(gamma) dgamma,
#
# is a function of one scalar. It is computed on a fine grid of l and
# interpolated, as are the first two moments of gamma, h_1 and h_2, which give
# the posterior mean and standard deviation of the power parameter.


#' Store of binomial normalized power prior kernels, one per source and prior
#'
#' @description A kernel takes a few seconds to compute and depends only on the
#'   source counts, the prior of the power parameter and the lattice, so it is
#'   shared by every scenario a worker runs, for the same reason as
#'   [inference_cache_store].
#' @keywords internal
binomial_npp_cache_store <- new.env(parent = emptyenv())

#' Empty the binomial normalized power prior kernel cache
#' @return `NULL`, invisibly.
#' @keywords internal
binomial_npp_cache_reset <- function() {
  rm(list = ls(envir = binomial_npp_cache_store, all.names = TRUE),
     envir = binomial_npp_cache_store)
  invisible(NULL)
}


#' Beta shape parameters from a mean and a standard deviation
#'
#' @description The parametrisation of the prior of the power parameter used by
#'   the normalized power prior. Shapes within numerical noise of one are set to
#'   one, where the Beta density changes behaviour at the boundaries.
#'
#' @param mean Mean, in (0, 1).
#' @param std Standard deviation, in (0, sqrt(mean (1 - mean))).
#' @return A list with `p` and `q`.
#' @keywords internal
npp_beta_shapes <- function(mean, std) {
  assert_single_number(mean)
  assert_single_number(std)
  if (mean <= 0 || mean >= 1) {
    stop("The mean of a Beta distribution must lie strictly between 0 and 1.", call. = FALSE)
  }
  if (std <= 0 || std^2 >= mean * (1 - mean)) {
    stop("The standard deviation of a Beta distribution with mean ", mean,
         " must lie strictly between 0 and ", signif(sqrt(mean * (1 - mean)), 4), ".",
         call. = FALSE)
  }
  omega <- std^2 / (mean * (1 - mean) - std^2)
  p <- mean / omega
  q <- (1 - mean) / omega
  tolerance <- .Machine$double.eps^0.5
  if (isTRUE(all.equal(p, 1, tolerance = tolerance))) p <- 1
  if (isTRUE(all.equal(q, 1, tolerance = tolerance))) q <- 1
  list(p = p, q = q)
}


#' Quadrature rule for an expectation over a Beta-distributed power parameter
#'
#' @description Integrates on the logit scale, gamma = plogis(t), where the
#'   integrand is the Beta density times gamma (1 - gamma). That is smooth and
#'   decays exponentially in both tails whatever the shapes, including the
#'   U-shaped priors whose density is unbounded at 0 and 1, so the trapezoidal
#'   rule converges geometrically. The mass beyond the end points is put on
#'   gamma = 0 and gamma = 1, where the integrands used here are flat to well
#'   below the rule's accuracy.
#'
#' @param p,q Shape parameters of the Beta prior.
#' @param t_limit Half-width of the logit range.
#' @param t_step Spacing on the logit scale.
#' @return A list with `nodes` in [0, 1] and `weights` summing to one.
#' @keywords internal
npp_gamma_rule <- function(p, q, t_limit = 30, t_step = 0.05) {
  t <- seq(-t_limit, t_limit, by = t_step)
  gamma <- stats::plogis(t)
  log_density <- p * stats::plogis(t, log.p = TRUE) +
    q * stats::plogis(-t, log.p = TRUE) - lbeta(p, q)
  weights <- exp(log_density) * t_step
  weights[c(1, length(weights))] <- weights[c(1, length(weights))] / 2

  lower_tail <- stats::pbeta(gamma[1], p, q)
  upper_tail <- stats::pbeta(gamma[length(gamma)], p, q, lower.tail = FALSE)
  nodes <- c(0, gamma, 1)
  weights <- c(lower_tail, weights, upper_tail)
  list(nodes = nodes, weights = weights / sum(weights))
}


#' Log-sum-exp of each row of a matrix
#' @param x A numeric matrix.
#' @return One value per row.
#' @keywords internal
row_log_sum_exp <- function(x) {
  if (ncol(x) == 0) {
    return(rep(-Inf, nrow(x)))
  }
  largest <- apply(x, 1, max)
  largest[!is.finite(largest)] <- 0
  largest + log(rowSums(exp(x - largest)))
}


#' Prior kernels of the binomial normalized power prior
#'
#' @description Computes, on the rate lattice, the normalized power prior
#'   integrated over the power parameter, as a function of the target control
#'   rate and of the risk difference, together with the same kernel weighted by
#'   the power parameter and by its square.
#'
#' @param n_control_source,n_successes_control_source Source control arm.
#' @param n_treatment_source,n_successes_treatment_source Source treatment arm.
#' @param gamma_rule Quadrature rule for the prior of the power parameter, as
#'   returned by [npp_gamma_rule()]: a single node of weight one gives the
#'   conditional power prior with that power parameter.
#' @param n_lattice Number of lattice points N on the rates.
#' @param n_log_likelihood_points Number of points on which the weight functions
#'   of the source log likelihood are tabulated before interpolation.
#' @return A list with `n_lattice`, the `rates`, and the N x (2N - 1) matrices
#'   `kernel`, `kernel_gamma` and `kernel_gamma_squared`, indexed by the target
#'   control rate and the risk difference k / N, k = -(N - 1), ..., N - 1. They
#'   are zero where the target treatment rate would leave [0, 1].
#' @keywords internal
binomial_npp_prior_kernels <- function(n_control_source,
                                       n_successes_control_source,
                                       n_treatment_source,
                                       n_successes_treatment_source,
                                       gamma_rule,
                                       n_lattice = 1000L,
                                       n_log_likelihood_points = 20001L) {
  N <- as.integer(n_lattice)
  rates <- (seq_len(N) - 0.5) / N

  # Source log likelihoods on the lattice, each shifted to a maximum of zero.
  # The shifts are a constant factor of the likelihood, which cancels between
  # exp(gamma l) and Z_S(gamma).
  control_log_likelihood <- n_successes_control_source * log(rates) +
    (n_control_source - n_successes_control_source) * log1p(-rates)
  control_log_likelihood <- control_log_likelihood - max(control_log_likelihood)
  treatment_log_likelihood <- n_successes_treatment_source * log(rates) +
    (n_treatment_source - n_successes_treatment_source) * log1p(-rates)
  treatment_log_likelihood <- treatment_log_likelihood - max(treatment_log_likelihood)

  # N x N: the prior density of theta given the two control rates, 1 / (N - |i - j|).
  width <- 1 / (N - abs(outer(seq_len(N), seq_len(N), "-")))

  # Initial prior mass of each (source control rate i, source treatment rate s),
  # summed over the target control rates j that leave theta = (s - i) / N
  # admissible, i.e. 1 <= j + s - i <= N. Row cumulative sums of `width` give
  # every such sum at once.
  cumulative <- cbind(0, t(apply(width, 1, cumsum)))
  shift <- outer(seq_len(N), seq_len(N), function(i, s) s - i)
  lowest <- pmax(1L, 1L - shift)
  highest <- pmin(N, N - shift)
  row_index <- matrix(seq_len(N), N, N)
  source_mass <- (cumulative[cbind(as.vector(row_index), as.vector(highest) + 1L)] -
                    cumulative[cbind(as.vector(row_index), as.vector(lowest))]) / N^2
  source_mass <- matrix(source_mass, N, N)

  # Z_S(gamma) at every node: sum over (i, s) of the initial prior mass times
  # the discounted source likelihood, a bilinear form in the two arms.
  gamma <- gamma_rule$nodes
  control_factor <- exp(outer(control_log_likelihood, gamma))
  treatment_factor <- exp(outer(treatment_log_likelihood, gamma))
  normalizing_constant <- colSums(control_factor * (source_mass %*% treatment_factor))
  rm(control_factor, treatment_factor)

  # The weights h_m(l) of a lattice point with source log likelihood l, for
  # m = 0, 1, 2, tabulated on a grid even in log(1 - l), where they are smooth.
  lowest_log_likelihood <- min(control_log_likelihood) + min(treatment_log_likelihood)
  table_points <- seq(0, log1p(-lowest_log_likelihood), length.out = n_log_likelihood_points)
  table_log_likelihood <- -expm1(table_points)
  base <- log(gamma_rule$weights) - log(normalizing_constant)
  positive <- gamma > 0
  log_gamma <- ifelse(positive, log(gamma), -Inf)
  log_weight_tables <- lapply(0:2, function(m) {
    node_terms <- base + if (m == 0) 0 else m * log_gamma
    keep <- is.finite(node_terms)
    chunks <- split(seq_along(table_log_likelihood),
                    ceiling(seq_along(table_log_likelihood) / 2000))
    unlist(lapply(chunks, function(rows) {
      row_log_sum_exp(outer(table_log_likelihood[rows], gamma[keep]) +
                        rep(node_terms[keep], each = length(rows)))
    }), use.names = FALSE)
  })

  # N x (2N - 1): the weight of each (source control rate i, risk difference k),
  # zero where the source treatment rate leaves the lattice.
  differences <- seq(-(N - 1L), N - 1L)
  source_treatment <- outer(seq_len(N), differences, "+")
  admissible <- source_treatment >= 1L & source_treatment <= N
  point_log_likelihood <- control_log_likelihood[row(source_treatment)[admissible]] +
    treatment_log_likelihood[source_treatment[admissible]]
  point_coordinate <- log1p(-point_log_likelihood)

  kernels <- lapply(log_weight_tables, function(log_table) {
    source_weight <- matrix(0, N, length(differences))
    source_weight[admissible] <- exp(stats::approx(
      table_points, log_table, xout = point_coordinate, rule = 2
    )$y)
    # Sum over the source control rate, against the prior density of theta
    # given the two control rates: kernel(j, k) = sum_i width(i, j) weight(i, k).
    kernel <- crossprod(width, source_weight)
    # Keep only the target treatment rates on the lattice: 1 <= j + k <= N.
    target_treatment <- outer(seq_len(N), differences, "+")
    kernel[target_treatment < 1L | target_treatment > N] <- 0
    kernel
  })

  list(
    n_lattice = N,
    rates = rates,
    differences = differences,
    kernel = kernels[[1]],
    kernel_gamma = kernels[[2]],
    kernel_gamma_squared = kernels[[3]]
  )
}


#' Cached prior kernels of the binomial normalized power prior
#'
#' @inheritParams binomial_npp_prior_kernels
#' @param p,q Shape parameters of the Beta prior of the power parameter.
#' @return The output of [binomial_npp_prior_kernels()].
#' @keywords internal
binomial_npp_cached_kernels <- function(n_control_source,
                                        n_successes_control_source,
                                        n_treatment_source,
                                        n_successes_treatment_source,
                                        p, q,
                                        n_lattice = 1000L) {
  key <- rlang::hash(list(
    n_control_source = as.integer(n_control_source),
    n_successes_control_source = as.integer(n_successes_control_source),
    n_treatment_source = as.integer(n_treatment_source),
    n_successes_treatment_source = as.integer(n_successes_treatment_source),
    p = p, q = q, n_lattice = as.integer(n_lattice)
  ))
  if (!exists(key, envir = binomial_npp_cache_store, inherits = FALSE)) {
    # A kernel set holds three N x (2N - 1) matrices, 48 MB at N = 1000. A
    # worker runs one prior at a time, so a few are kept and no more.
    held <- ls(envir = binomial_npp_cache_store, all.names = TRUE)
    if (length(held) >= 3) {
      rm(list = held, envir = binomial_npp_cache_store)
    }
    assign(key, binomial_npp_prior_kernels(
      n_control_source = n_control_source,
      n_successes_control_source = n_successes_control_source,
      n_treatment_source = n_treatment_source,
      n_successes_treatment_source = n_successes_treatment_source,
      gamma_rule = npp_gamma_rule(p, q),
      n_lattice = n_lattice
    ), envir = binomial_npp_cache_store)
  }
  get(key, envir = binomial_npp_cache_store)
}


#' Cached prior kernel of the binomial conditional power prior
#'
#' @description The power prior with a fixed power parameter, on the lattice
#'   of [binomial_npp_prior_kernels()], as a function of the target control rate
#'   and the risk difference. [BinomialCPP] reads its posterior off this kernel
#'   with [binomial_npp_posterior()], which costs a fraction of computing it
#'   afresh for every dataset with [binomial_power_prior_posterior()]; the two
#'   give the same posterior.
#'
#' @inheritParams binomial_npp_prior_kernels
#' @param power_parameter The power parameter, in [0, 1].
#' @return A list with `n_lattice`, `rates`, `differences` and `kernel`, as
#'   [binomial_npp_prior_kernels()] returns but without the power parameter's
#'   moments.
#' @keywords internal
binomial_cpp_cached_kernel <- function(n_control_source,
                                       n_successes_control_source,
                                       n_treatment_source,
                                       n_successes_treatment_source,
                                       power_parameter,
                                       n_lattice = 1000L) {
  key <- rlang::hash(list(
    "conditional power prior",
    as.integer(n_control_source), as.integer(n_successes_control_source),
    as.integer(n_treatment_source), as.integer(n_successes_treatment_source),
    power_parameter, as.integer(n_lattice)
  ))
  if (!exists(key, envir = binomial_npp_cache_store, inherits = FALSE)) {
    held <- ls(envir = binomial_npp_cache_store, all.names = TRUE)
    if (length(held) >= 6) {
      rm(list = held, envir = binomial_npp_cache_store)
    }
    N <- as.integer(n_lattice)
    rates <- (seq_len(N) - 0.5) / N
    discounted <- function(n, successes) {
      log_likelihood <- successes * log(rates) + (n - successes) * log1p(-rates)
      exp(power_parameter * (log_likelihood - max(log_likelihood)))
    }
    source_control <- discounted(n_control_source, n_successes_control_source)
    source_treatment <- discounted(n_treatment_source, n_successes_treatment_source)

    differences <- seq(-(N - 1L), N - 1L)
    source_rate <- outer(seq_len(N), differences, "+")
    inside <- source_rate >= 1L & source_rate <= N
    source_weight <- matrix(0, N, length(differences))
    source_weight[inside] <- source_control[row(source_rate)[inside]] *
      source_treatment[source_rate[inside]]

    width <- 1 / (N - abs(outer(seq_len(N), seq_len(N), "-")))
    kernel <- crossprod(width, source_weight)
    kernel[!inside] <- 0

    assign(key, list(n_lattice = N, rates = rates, differences = differences, kernel = kernel),
           envir = binomial_npp_cache_store)
  }
  get(key, envir = binomial_npp_cache_store)
}


#' Posterior of the risk difference under the binomial normalized power prior
#'
#' @description Multiplies the prior kernel by the target likelihood and sums
#'   over the target control rate. Only the lattice points where both target
#'   arms' likelihoods exceed `1e-20` of their maxima are visited. With no target
#'   patients the result is the prior.
#'
#' @param kernels Output of [binomial_npp_prior_kernels()].
#' @param n_control,n_successes_control Target control arm.
#' @param n_treatment,n_successes_treatment Target treatment arm.
#' @return A [grid_posterior()] list with, in addition,
#'   `power_parameter_mean` and `power_parameter_std`, the posterior mean and
#'   standard deviation of the power parameter.
#' @keywords internal
binomial_npp_posterior <- function(kernels,
                                   n_control,
                                   n_successes_control,
                                   n_treatment,
                                   n_successes_treatment) {
  N <- kernels$n_lattice
  rates <- kernels$rates

  arm_likelihood <- function(n, successes) {
    log_likelihood <- successes * log(rates) + (n - successes) * log1p(-rates)
    exp(log_likelihood - max(log_likelihood))
  }
  control <- arm_likelihood(n_control, n_successes_control)
  treatment <- arm_likelihood(n_treatment, n_successes_treatment)

  control_points <- which(control > 1e-20)
  treatment_points <- which(treatment > 1e-20)

  j <- rep(control_points, times = length(treatment_points))
  m <- rep(treatment_points, each = length(control_points))
  k <- m - j
  column <- k + N
  likelihood <- control[j] * treatment[m]

  mass <- likelihood * kernels$kernel[cbind(j, column)]
  total <- sum(mass)
  if (!is.finite(total) || total <= 0) {
    stop("The normalized power prior posterior has no mass on the lattice.", call. = FALSE)
  }
  if (is.null(kernels$kernel_gamma)) {
    gamma_mean <- NA_real_
    gamma_second_moment <- NA_real_
  } else {
    gamma_mean <- sum(likelihood * kernels$kernel_gamma[cbind(j, column)]) / total
    gamma_second_moment <- sum(likelihood * kernels$kernel_gamma_squared[cbind(j, column)]) / total
  }

  by_difference <- rowsum(mass, k, reorder = TRUE)
  observed <- as.integer(rownames(by_difference))
  # One empty lattice point on each side, so that the grid always has two
  # points and the distribution function starts at 0 and ends at 1.
  support <- seq(min(observed) - 1L, max(observed) + 1L)
  density <- numeric(length(support))
  density[match(observed, support)] <- by_difference[, 1]

  posterior <- grid_posterior(support / N, density)
  posterior$power_parameter_mean <- gamma_mean
  posterior$power_parameter_std <- sqrt(max(0, gamma_second_moment - gamma_mean^2))
  posterior
}


#' BinomialNPP class
#'
#' @description The normalized power prior for a binary endpoint, with the
#'   binomial likelihoods of the two arms of each study and a risk difference
#'   shared by the source and target studies, as in [BinomialCPP]. The power
#'   parameter has a Beta prior, specified by its mean and standard deviation as
#'   in [Gaussian_NPP], and is integrated out exactly rather than through a
#'   normal approximation of the likelihood. The posterior is computed on a
#'   lattice of response rates; see [binomial_npp_prior_kernels()].
#'
#' @field power_parameter_mean Mean of the Beta prior on the power parameter.
#' @field power_parameter_std Standard deviation of the Beta prior.
#' @field p Shape parameter of the Beta prior.
#' @field q Shape parameter of the Beta prior.
#' @field n_lattice Number of lattice points on the response rates.
#' @field method Name of the method.
#' @field quadrature_available The posterior is computed by quadrature.
#' @export
BinomialNPP <- R6::R6Class(
  "BinomialNPP",
  inherit = MCMCModel,
  public = list(
    power_parameter_mean = NULL,
    power_parameter_std = NULL,
    p = NULL,
    q = NULL,
    n_lattice = 1000L,
    method = "NPP",
    quadrature_available = TRUE,

    #' @description Initialize a BinomialNPP model.
    #' @param prior The prior object.
    #' @param mcmc_config The MCMC configuration. Only its `engine` is read, and
    #'   only `"quadrature"` is supported: the normalized power prior has no
    #'   Stan program.
    initialize = function(prior, mcmc_config) {
      if (!(prior$method_parameters$initial_prior[[1]] == "noninformative")) {
        stop("Only implemented for a noninformative initial prior")
      }
      if (identical(mcmc_config$engine, "stan")) {
        stop("The binomial normalized power prior is only computed by quadrature; ",
             "set engine: quadrature.", call. = FALSE)
      }
      super$initialize(prior = prior, mcmc_config = mcmc_config)
      self$summary_measure_likelihood <- "binomial"

      self$power_parameter_mean <- prior$method_parameters$power_parameter_mean[[1]]
      self$power_parameter_std <- prior$method_parameters$power_parameter_std[[1]]
      shapes <- npp_beta_shapes(self$power_parameter_mean, self$power_parameter_std)
      self$p <- shapes$p
      self$q <- shapes$q
    },

    #' @description The prior kernels, computed once per worker and shared.
    #' @return The output of [binomial_npp_prior_kernels()].
    kernels = function() {
      source <- self$prior$source
      binomial_npp_cached_kernels(
        n_control_source = as.integer(source$sample_size_control),
        n_successes_control_source = counts_from_rate(source$control_rate, source$sample_size_control),
        n_treatment_source = as.integer(source$sample_size_treatment),
        n_successes_treatment_source = counts_from_rate(source$treatment_rate, source$sample_size_treatment),
        p = self$p,
        q = self$q,
        n_lattice = self$n_lattice
      )
    },

    #' @description The posterior on a grid
    #' @param target_data The target study data.
    #' @return A [grid_posterior()] list.
    quadrature_posterior = function(target_data) {
      binomial_npp_posterior(
        self$kernels(),
        n_control = as.integer(target_data$sample_size_control),
        n_successes_control = counts_from_rate(
          target_data$sample$sample_control_rate, target_data$sample_size_control
        ),
        n_treatment = as.integer(target_data$sample_size_treatment),
        n_successes_treatment = counts_from_rate(
          target_data$sample$sample_treatment_rate, target_data$sample_size_treatment
        )
      )
    },

    #' @description The prior of the treatment effect on a grid.
    #' @return A [grid_posterior()] list.
    quadrature_prior = function() {
      binomial_npp_posterior(self$kernels(), 0L, 0L, 0L, 0L)
    },

    #' @description Record the posterior mean and standard deviation of the
    #' power parameter.
    compute_posterior_parameters = function() {
      self$posterior_parameters <- list(
        power_parameter_mean = self$grid_posterior$power_parameter_mean,
        power_parameter_std = self$grid_posterior$power_parameter_std
      )
    },

    #' @description The prior of the treatment effect given the target control
    #' rate
    #'
    #' The kernel's row for the lattice cell that contains `control_rate`,
    #' which confines the treatment effect to the differences that keep the
    #' target treatment rate in [0, 1].
    #'
    #' @param control_rate The target control rate.
    #' @return A list of three functions of the treatment effect: `cdf`, `pdf`,
    #'   and `sample`, which takes the number of draws.
    prior_given_control_rate = function(control_rate) {
      kernels <- self$kernels()
      N <- kernels$n_lattice
      row <- min(N, max(1L, as.integer(ceiling(control_rate * N))))
      columns <- seq(N + 1L - row, 2L * N - row)
      differences <- kernels$differences[columns]
      support <- c(min(differences) - 1L, differences, max(differences) + 1L)
      grid_distribution(grid_posterior(
        support / N,
        c(0, kernels$kernel[row, columns], 0)
      ))
    },

    #' @description ELIR effective sample size of the prior
    #'
    #' The prior does not depend on the target data, so its unit-scale ELIR is
    #' computed once per worker, as the mean over several mixture fits under a
    #' fixed seed (see [grid_prior_unit_elir()]), and rescaled by the target's
    #' sampling standard deviation.
    #'
    #' @param target_data Target study data.
    #' @param simulation_config Simulation configuration, for
    #'   `n_samples_mixture_approx`.
    #' @return The ELIR effective sample size.
    prior_elir_ess = function(target_data, simulation_config) {
      if (is.null(self$prior_elir_unit_information)) {
        if (is.null(simulation_config$n_samples_mixture_approx)) {
          stop("The ELIR needs simulation_config$n_samples_mixture_approx.", call. = FALSE)
        }
        source <- self$prior$source
        key <- rlang::hash(list(
          "binomial_npp_elir",
          source$sample_size_control, source$sample_size_treatment,
          source$control_rate, source$treatment_rate,
          self$p, self$q, self$n_lattice,
          as.integer(simulation_config$n_samples_mixture_approx),
          self$n_components_mixture_approx, self$aic_penalty_parameter_mixture_approx
        ))
        if (!exists(key, envir = power_prior_elir_cache_store, inherits = FALSE)) {
          assign(key, grid_prior_unit_elir(
            prior_grid = self$quadrature_prior(),
            n_samples = simulation_config$n_samples_mixture_approx,
            n_fits = 10L,
            n_components = self$n_components_mixture_approx,
            aic_penalty = self$aic_penalty_parameter_mixture_approx
          ), envir = power_prior_elir_cache_store)
        }
        self$prior_elir_unit_information <- get(key, envir = power_prior_elir_cache_store)
      }
      self$prior_elir_unit_information * target_data$sample$standard_deviation^2
    }
  )
)
