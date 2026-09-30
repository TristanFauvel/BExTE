#' Cache of power prior ELIRs
#'
#' @description
#' The ELIR effective sample size of a prior is read off a normal mixture fitted
#' to draws from it. The binomial p-value based power prior changes from one
#' replicate to the next only through its power parameter, so rather than
#' drawing from the prior and fitting a mixture for every replicate, the ELIR is
#' tabulated on a grid of power parameters and interpolated between its nodes.
#'
#' A single fit's ELIR varies by about five per cent from one set of draws to
#' the next, which refitting every replicate averaged away over the replicates.
#' A node is therefore the mean over several fits instead, and each node is drawn
#' under a fixed seed. That makes a node a function of its inputs alone, so the
#' nodes can be shared between the scenarios a worker runs whatever order it
#' runs them in, and filling them leaves the caller's random number stream
#' untouched.
#'
#' The store lives in the package rather than on a model because a model is
#' built afresh for each scenario, the same reason [inference_cache_store] does.
#'
#' @keywords internal
power_prior_elir_cache_store <- new.env(parent = emptyenv())

#' Empty the power prior ELIR cache
#'
#' @description Called by tests, and by any run that must not reuse an earlier
#' run's nodes.
#' @return `NULL`, invisibly.
#' @keywords internal
power_prior_elir_cache_reset <- function() {
  rm(
    list = ls(envir = power_prior_elir_cache_store, all.names = TRUE),
    envir = power_prior_elir_cache_store
  )
  invisible(NULL)
}

#' Number of ELIR nodes held in the cache
#'
#' @return The number of nodes stored.
#' @keywords internal
power_prior_elir_cache_size <- function() {
  length(ls(envir = power_prior_elir_cache_store, all.names = TRUE))
}

#' Evaluate an expression under a fixed seed
#'
#' @description Restores the caller's random number generator state afterwards,
#' or its absence, so that nothing drawn here shifts the draws that follow.
#'
#' @param seed Seed to draw under.
#' @param code Expression to evaluate.
#' @return The value of `code`.
#' @keywords internal
with_fixed_seed <- function(seed, code) {
  had_seed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (had_seed) {
    saved <- get(".Random.seed", envir = globalenv())
  }
  on.exit({
    if (had_seed) {
      assign(".Random.seed", saved, envir = globalenv())
    } else if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }
  })
  set.seed(seed)
  code
}

#' Unit-scale ELIR of a gridded prior, averaged over several mixture fits
#'
#' @description Each fit follows [Model]'s `prior_to_RBesT()`: a normal mixture
#' fitted by `RBesT::automixfit()` to `n_samples` draws from the prior. Its ELIR
#' is taken at a unit reference scale, which the caller rescales.
#'
#' @param prior_grid The prior, as a [grid_posterior()] list.
#' @param n_samples Draws per fit.
#' @param n_fits Number of fits averaged.
#' @param n_components,aic_penalty Mixture fit settings.
#' @param seed Seed the draws are made under.
#' @return The mean unit-scale ELIR over the fits that succeeded, or `NA`.
#' @keywords internal
grid_prior_unit_elir <- function(prior_grid, n_samples, n_fits,
                                 n_components, aic_penalty, seed = 1L) {
  values <- with_fixed_seed(seed, vapply(seq_len(n_fits), function(i) {
    draws <- grid_posterior_sample(prior_grid, n_samples)
    fit <- RBesT::automixfit(
      draws,
      Nc = n_components,
      k = aic_penalty,
      thresh = -Inf,
      verbose = FALSE,
      type = c("norm")
    )
    RBesT::sigma(fit) <- 1
    as.numeric(prior_ess_elir(rbest_model = fit, target_data = NULL))
  }, numeric(1)))

  if (all(is.na(values))) {
    return(NA_real_)
  }
  mean(values, na.rm = TRUE)
}

#' Unit-scale ELIR of a binomial power prior, interpolated in the power parameter
#'
#' @description Linear interpolation between the two grid nodes around
#' `power_parameter`, each computed once per worker by [grid_prior_unit_elir()]
#' and cached. The ELIR is close to linear in the power parameter, so the
#' interpolation error is small against the fits' own.
#'
#' @param model A binomial power prior model, whose `quadrature_prior()` takes
#'   the power parameter.
#' @param power_parameter The power parameter, in [0, 1].
#' @param n_samples Draws per mixture fit.
#' @param step Spacing of the power parameter grid.
#' @param n_fits Number of mixture fits averaged per node.
#' @return The unit-scale ELIR.
#' @keywords internal
binomial_power_prior_unit_elir <- function(model, power_parameter, n_samples,
                                           step = 0.05, n_fits = 10L) {
  if (is.null(n_samples)) {
    stop(
      "The ELIR needs simulation_config$n_samples_mixture_approx to sample the ",
      "prior for the mixture approximation, but it was not provided."
    )
  }
  assert_single_number(power_parameter)
  if (power_parameter < 0 || power_parameter > 1) {
    stop("The power parameter must lie in [0, 1].", call. = FALSE)
  }

  source <- model$prior$source
  identity <- list(
    n_control = as.integer(source$sample_size_control),
    n_successes_control = counts_from_rate(source$control_rate, source$sample_size_control),
    n_treatment = as.integer(source$sample_size_treatment),
    n_successes_treatment = counts_from_rate(source$treatment_rate, source$sample_size_treatment),
    n_samples = as.integer(n_samples),
    n_fits = as.integer(n_fits),
    n_components = model$n_components_mixture_approx,
    aic_penalty = model$aic_penalty_parameter_mixture_approx
  )

  node_value <- function(index) {
    node <- min(1, index * step)
    key <- rlang::hash(c(identity, list(node = node)))
    if (!exists(key, envir = power_prior_elir_cache_store, inherits = FALSE)) {
      assign(
        key,
        grid_prior_unit_elir(
          prior_grid = model$quadrature_prior(power_parameter = node),
          n_samples = n_samples,
          n_fits = n_fits,
          n_components = model$n_components_mixture_approx,
          aic_penalty = model$aic_penalty_parameter_mixture_approx
        ),
        envir = power_prior_elir_cache_store
      )
    }
    get(key, envir = power_prior_elir_cache_store)
  }

  # The small offset keeps a power parameter that is a node up to rounding on
  # that node rather than just below it.
  lower <- floor(power_parameter / step + 1e-9)
  fraction <- power_parameter / step - lower
  if (fraction <= 1e-9 || lower * step >= 1) {
    return(node_value(lower))
  }
  (1 - fraction) * node_value(lower) + fraction * node_value(lower + 1)
}
