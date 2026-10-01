# Empirical Bayes power prior for the binomial model with a shared risk
# difference.
#
# Gravestock and Held (2017) set the power parameter to the maximizer of the
# marginal likelihood of the target data under the normalized power prior with
# a fixed power parameter, m(gamma) = Z_T(gamma) / Z_S(gamma), and analyse the
# target data with the conditional power prior at that value. On the lattice of
# binomial_power_prior_posterior(), with
#
#   T(i, k) = sum_j L_T(r_j, k / N) / (N - |i - j|),
#
# which depends on the target data only, and l(i, k) the source log likelihood
# at source control rate r_i and risk difference k / N,
#
#   m(gamma) is proportional to sum_{i, k} T(i, k) exp(gamma l(i, k)) / Z_S(gamma),
#
# and the posterior of the risk difference at gamma is proportional to
# sum_i T(i, k) exp(gamma l(i, k)). T is computed once per dataset; every
# evaluation of m(gamma) after that is a single weighted sum.


#' Initial prior mass of each pair of source rates on the lattice
#'
#' @description The uniform initial prior of the binomial power prior, summed
#'   over the target control rates that leave the risk difference admissible:
#'   entry (i, s) is the mass of the source control rate r_i and the source
#'   treatment rate r_s. It depends on the lattice alone, so it is computed once
#'   per worker.
#'
#' @param n_lattice Number of lattice points N.
#' @return An N x N matrix.
#' @keywords internal
binomial_lattice_source_mass <- function(n_lattice) {
  key <- paste0("source mass ", n_lattice)
  if (!exists(key, envir = binomial_npp_cache_store, inherits = FALSE)) {
    N <- as.integer(n_lattice)
    width <- 1 / (N - abs(outer(seq_len(N), seq_len(N), "-")))
    cumulative <- cbind(0, t(apply(width, 1, cumsum)))
    shift <- outer(seq_len(N), seq_len(N), function(i, s) s - i)
    lowest <- pmax(1L, 1L - shift)
    highest <- pmin(N, N - shift)
    rows <- as.vector(matrix(seq_len(N), N, N))
    mass <- (cumulative[cbind(rows, as.vector(highest) + 1L)] -
               cumulative[cbind(rows, as.vector(lowest))]) / N^2
    assign(key, matrix(mass, N, N), envir = binomial_npp_cache_store)
  }
  get(key, envir = binomial_npp_cache_store)
}


#' Terms of the binomial power prior that depend on the target data
#'
#' @inheritParams binomial_power_prior_posterior
#' @return A list with `n_lattice`, the risk `differences` (in lattice units)
#'   the target data reach, the N x K matrices `target` (T) and
#'   `source_log_likelihood` (l, `-Inf` where the source treatment rate leaves
#'   [0, 1]), and the source arms' log likelihoods on the lattice,
#'   `source_control_log_likelihood` and `source_treatment_log_likelihood`.
#' @keywords internal
binomial_power_prior_target_terms <- function(n_control_source,
                                              n_successes_control_source,
                                              n_treatment_source,
                                              n_successes_treatment_source,
                                              n_control,
                                              n_successes_control,
                                              n_treatment,
                                              n_successes_treatment,
                                              n_lattice = 1000L) {
  N <- as.integer(n_lattice)
  rates <- (seq_len(N) - 0.5) / N
  arm_log_likelihood <- function(n, successes) {
    log_likelihood <- successes * log(rates) + (n - successes) * log1p(-rates)
    log_likelihood - max(log_likelihood)
  }
  source_control <- arm_log_likelihood(n_control_source, n_successes_control_source)
  source_treatment <- arm_log_likelihood(n_treatment_source, n_successes_treatment_source)
  target_control <- exp(arm_log_likelihood(n_control, n_successes_control))
  target_treatment <- exp(arm_log_likelihood(n_treatment, n_successes_treatment))

  control_points <- which(target_control > 1e-20)
  treatment_points <- which(target_treatment > 1e-20)
  differences <- seq(min(treatment_points) - max(control_points),
                     max(treatment_points) - min(control_points))

  # J x K: the target likelihood, zero where the target treatment rate leaves [0, 1].
  target_rate <- outer(control_points, differences, "+")
  inside <- target_rate >= 1L & target_rate <= N
  likelihood <- matrix(0, length(control_points), length(differences))
  likelihood[inside] <- target_control[control_points[row(target_rate)[inside]]] *
    target_treatment[target_rate[inside]]

  # N x K: summed over the target control rate against the prior density of
  # the risk difference given the two control rates, 1 / (N - |i - j|).
  width <- 1 / (N - abs(outer(seq_len(N), control_points, "-")))
  target <- width %*% likelihood

  source_rate <- outer(seq_len(N), differences, "+")
  source_inside <- source_rate >= 1L & source_rate <= N
  source_log_likelihood <- matrix(-Inf, N, length(differences))
  source_log_likelihood[source_inside] <- source_control[row(source_rate)[source_inside]] +
    source_treatment[source_rate[source_inside]]

  list(
    n_lattice = N,
    differences = differences,
    target = target,
    source_log_likelihood = source_log_likelihood,
    source_control_log_likelihood = source_control,
    source_treatment_log_likelihood = source_treatment
  )
}


#' Log marginal likelihood of the target data under the binomial power prior
#'
#' @description Up to a constant that does not depend on the power parameter.
#'   The source log likelihoods are shifted to a maximum of zero; the shift
#'   multiplies the numerator and Z_S(gamma) alike, so it cancels.
#'
#' @param terms Output of [binomial_power_prior_target_terms()].
#' @param power_parameter Power parameters in [0, 1].
#' @return One log marginal likelihood per power parameter.
#' @keywords internal
binomial_power_prior_log_marginal <- function(terms, power_parameter) {
  keep <- terms$target > 0 & is.finite(terms$source_log_likelihood)
  log_target <- log(terms$target[keep])
  log_likelihood <- terms$source_log_likelihood[keep]
  mass <- binomial_lattice_source_mass(terms$n_lattice)
  vapply(power_parameter, function(gamma) {
    exponent <- log_target + gamma * log_likelihood
    largest <- max(exponent)
    numerator <- largest + log(sum(exp(exponent - largest)))
    normalizer <- log(sum(
      exp(gamma * terms$source_control_log_likelihood) *
        (mass %*% exp(gamma * terms$source_treatment_log_likelihood))
    ))
    numerator - normalizer
  }, numeric(1))
}


#' Empirical Bayes power parameter of the binomial power prior
#'
#' @description The maximizer of [binomial_power_prior_log_marginal()] over
#'   [0, 1]: the best of 21 equally spaced values, refined by Brent's method
#'   between its neighbours, with the end points kept as candidates.
#'
#' @param terms Output of [binomial_power_prior_target_terms()].
#' @return The power parameter.
#' @keywords internal
binomial_power_prior_empirical_bayes <- function(terms) {
  grid <- seq(0, 1, by = 0.05)
  values <- binomial_power_prior_log_marginal(terms, grid)
  best <- which.max(values)
  lower <- grid[max(1L, best - 1L)]
  upper <- grid[min(length(grid), best + 1L)]
  refined <- stats::optimize(
    function(gamma) binomial_power_prior_log_marginal(terms, gamma),
    interval = c(lower, upper), maximum = TRUE, tol = 1e-6
  )
  if (refined$objective > values[best]) refined$maximum else grid[best]
}


#' Posterior of the risk difference from the target terms
#'
#' @param terms Output of [binomial_power_prior_target_terms()].
#' @param power_parameter The power parameter, in [0, 1].
#' @return A [grid_posterior()] list, the same as
#'   [binomial_power_prior_posterior()] gives.
#' @keywords internal
binomial_power_prior_terms_posterior <- function(terms, power_parameter) {
  exponent <- power_parameter * terms$source_log_likelihood
  exponent[!is.finite(exponent)] <- -Inf
  largest <- max(exponent[terms$target > 0])
  density <- colSums(terms$target * exp(exponent - largest))
  N <- terms$n_lattice
  differences <- terms$differences
  support <- c(min(differences) - 1L, differences, max(differences) + 1L)
  grid_posterior(support / N, c(0, density, 0))
}


#' Empirical Bayes power parameter of a dataset, cached per worker
#'
#' @description The estimate depends on the source and target counts alone. A
#'   replicate served from the inference cache still re-derives its prior for
#'   the ELIR, so the estimate is kept rather than recomputed.
#' @inheritParams binomial_power_prior_target_terms
#' @return A list with the `power_parameter` and the target `terms`, which are
#'   `NULL` when the estimate came from the cache.
#' @keywords internal
binomial_cached_empirical_bayes <- function(n_control_source,
                                            n_successes_control_source,
                                            n_treatment_source,
                                            n_successes_treatment_source,
                                            n_control,
                                            n_successes_control,
                                            n_treatment,
                                            n_successes_treatment,
                                            n_lattice = 1000L) {
  counts <- as.integer(c(n_control_source, n_successes_control_source,
                         n_treatment_source, n_successes_treatment_source,
                         n_control, n_successes_control,
                         n_treatment, n_successes_treatment, n_lattice))
  key <- paste0("ebpp ", paste(counts, collapse = " "))
  if (exists(key, envir = binomial_npp_cache_store, inherits = FALSE)) {
    return(list(power_parameter = get(key, envir = binomial_npp_cache_store), terms = NULL))
  }
  terms <- binomial_power_prior_target_terms(
    n_control_source, n_successes_control_source,
    n_treatment_source, n_successes_treatment_source,
    n_control, n_successes_control, n_treatment, n_successes_treatment,
    n_lattice = n_lattice
  )
  power_parameter <- binomial_power_prior_empirical_bayes(terms)
  assign(key, power_parameter, envir = binomial_npp_cache_store)
  list(power_parameter = power_parameter, terms = terms)
}


#' BinomialGravestockEBPP class
#'
#' @description The empirical Bayes power prior of Gravestock and Held (2017)
#'   for a binary endpoint: the power parameter maximizes the marginal
#'   likelihood of the target data under the binomial power prior of
#'   [BinomialCPP], and the target data are analysed with that power prior.
#'   Unlike [Gaussian_Gravestock_EBPP], which uses the closed form of a normal
#'   likelihood, the marginal likelihood is that of the binomial likelihoods of
#'   both arms, computed on the lattice of [binomial_power_prior_posterior()].
#'
#' @field empirical_bayes The prior depends on the target data.
#' @field empirical_bayes_from_sample The prior is a function of the
#'   replicate's sample alone.
#' @field fixed_power_parameter The power parameter changes between replicates.
#' @field method Method name.
#' @export
BinomialGravestockEBPP <- R6::R6Class(
  "BinomialGravestockEBPP",
  inherit = BinomialCPP,
  public = list(
    empirical_bayes = TRUE,
    empirical_bayes_from_sample = TRUE,
    fixed_power_parameter = FALSE,
    method = "EBPP",

    #' @description Initialize a BinomialGravestockEBPP model.
    #' @param prior The prior object.
    #' @param mcmc_config The MCMC configuration. Only the quadrature engine is
    #'   supported.
    initialize = function(prior, mcmc_config) {
      if (identical(mcmc_config$engine, "stan")) {
        stop("The binomial empirical Bayes power prior is only computed by quadrature; ",
             "set engine: quadrature.", call. = FALSE)
      }
      super$initialize(prior = prior, mcmc_config = mcmc_config)
      # A placeholder until the first replicate sets it.
      self$power_parameter <- 1
    },

    #' @description Set the power parameter from the replicate's counts.
    #' @param target_data Target study data.
    empirical_bayes_update = function(target_data) {
      data_list <- self$prepare_data(target_data)
      estimate <- binomial_cached_empirical_bayes(
        n_control_source = data_list$n_control_source,
        n_successes_control_source = data_list$successes_control_source,
        n_treatment_source = data_list$n_treatment_source,
        n_successes_treatment_source = data_list$successes_treatment_source,
        n_control = data_list$n_control_target,
        n_successes_control = data_list$successes_control_target,
        n_treatment = data_list$n_treatment_target,
        n_successes_treatment = data_list$successes_treatment_target
      )
      private$terms <- estimate$terms
      self$power_parameter <- estimate$power_parameter
      self$posterior_parameters <- list(power_parameter = estimate$power_parameter)
      # The prior depends on the power parameter just chosen.
      self$prior_grid <- NULL
      self$prior_pdf_approx <- NULL
      self$prior_cdf_approx <- NULL
      invisible(NULL)
    },

    #' @description The posterior on a grid, at the estimated power parameter.
    #' @param target_data The target study data.
    #' @return A [grid_posterior()] list.
    quadrature_posterior = function(target_data) {
      if (!is.null(private$terms)) {
        return(binomial_power_prior_terms_posterior(private$terms, self$power_parameter))
      }
      super$quadrature_posterior(target_data)
    },

    #' @description ELIR effective sample size of the current prior,
    #' interpolated over the power parameter as for the p-value-based power
    #' prior; see [binomial_power_prior_unit_elir()].
    #' @param target_data Target study data.
    #' @param simulation_config Configuration of the simulation study.
    #' @return The ELIR effective sample size.
    prior_elir_ess = function(target_data, simulation_config) {
      unit_information <- binomial_power_prior_unit_elir(
        model = self,
        power_parameter = self$power_parameter,
        n_samples = simulation_config$n_samples_mixture_approx
      )
      unit_information * target_data$sample$standard_deviation^2
    }
  ),
  private = list(
    terms = NULL
  )
)
