#' Borrowing priors
#'
#' @description Each function builds the prior of one borrowing method from
#'   the source data. Pass the result to [posterior()] to analyse a target
#'   study, or to [oc_frequentist()] and [oc_bayesian()] to plan one.
#'
#'   - `separate_prior()` ignores the source study.
#'   - `pooling_prior()` treats the source patients as target patients.
#'   - `power_prior()` discounts the source likelihood by a fixed power `a0`
#'     (Ibrahim and Chen, 2000).
#'   - `npp()` puts a Beta prior on the power (normalised power prior, Duan,
#'     Ye and Smith, 2006).
#'   - `npp_kl()` is an NPP whose Beta prior is calibrated to the target
#'     design, by a Kullback-Leibler criterion.
#'   - `rmp()` mixes the source posterior with a vague component (robust
#'     mixture prior, Schmidli et al., 2014).
#'   - `egidi_mixture()` is a robust mixture prior whose weight comes from the
#'     prior-data conflict in the target data (Egidi, Pauli and Torelli, 2022).
#'   - `commensurate_prior()` and `commensurate_power_prior()` shrink the
#'     target effect towards the source effect, by an amount learnt from the
#'     data (Hobbs et al., 2011).
#'   - `eb_power_prior()` chooses the power by empirical Bayes (Gravestock and
#'     Held, 2017).
#'   - `pvalue_power_prior()` sets the power from the p-value of a test of
#'     equivalence between the studies.
#'   - `pdccpp()` calibrates the power to control the type I error rate.
#'   - `test_then_pool()` pools the studies only if a test does not find them
#'     different (Viele et al., 2014).
#'
#' @param source Source data, from [source_data()].
#' @param a0 Power on the source likelihood, between 0 (no borrowing) and 1
#'   (full pooling).
#' @param a0_mean,a0_sd Mean and standard deviation of the Beta prior on the
#'   power.
#' @param lambda Weight of the "compatible studies" scenario in the
#'   calibration criterion, between 0 and 1.
#' @param c_target Shape of the reference Beta distributions the calibration
#'   aims at.
#' @param d_mtd_multiplier The maximum tolerable difference between the
#'   studies, as a multiple of the distance from the source effect to
#'   `theta_0`.
#' @param weight Prior weight of the informative (source) component.
#' @param empirical_bayes Whether to centre the vague component on the
#'   observed target data.
#' @param alpha_pc Level of the prior-data conflict test.
#' @param pvalue_method How to compute the conflict p-value.
#' @param weight_grid_step Step of the grid of mixture weights.
#' @param heterogeneity_prior Prior on the heterogeneity between the studies,
#'   a list with `family` (`"inverse_gamma"`, `"half_normal"` or `"cauchy"`)
#'   and its parameters, for example
#'   `list(family = "half_normal", std_dev = 1)`.
#' @param shape Shape parameter `k` of the map from p-value to power.
#' @param equivalence_margin Equivalence margin of the test between the
#'   studies, on the treatment effect scale.
#' @param desired_tie Type I error rate the power is calibrated to.
#' @param significance_level Level of the test between the studies.
#' @param n_iter Number of Monte Carlo draws in the calibration.
#' @param type For `test_then_pool()`: `"difference"` tests for a difference
#'   between the studies, `"equivalence"` tests for their equivalence.
#'
#' @return An object of class `bexte_prior`, with a subclass that names the
#'   method (for example `bexte_npp`).
#'
#' @references
#' Duan, Y., Ye, K. and Smith, E. P. (2006). Evaluating water quality using
#' power priors to incorporate historical information. Environmetrics, 17(1),
#' 95-106.
#'
#' Egidi, L., Pauli, F. and Torelli, N. (2022). Avoiding prior-data conflict in
#' regression models via mixture priors. Canadian Journal of Statistics,
#' 50(2), 491-510.
#'
#' Gravestock, I. and Held, L. (2017). Adaptive power priors with empirical
#' Bayes for clinical trials. Pharmaceutical Statistics, 16(5), 349-360.
#'
#' Hobbs, B. P., Carlin, B. P., Mandrekar, S. J. and Sargent, D. J. (2011).
#' Hierarchical commensurate and power prior models for adaptive incorporation
#' of historical information in clinical trials. Biometrics, 67(3), 1047-1056.
#'
#' Ibrahim, J. G. and Chen, M.-H. (2000). Power prior distributions for
#' regression models. Statistical Science, 15(1), 46-60.
#'
#' Schmidli, H., Gsteiger, S., Roychoudhury, S., O'Hagan, A., Spiegelhalter, D.
#' and Neuenschwander, B. (2014). Robust meta-analytic-predictive priors in
#' clinical trials with historical control information. Biometrics, 70(4),
#' 1023-1032.
#'
#' Viele, K. et al. (2014). Use of historical control data for assessing
#' treatment effects in clinical trials. Pharmaceutical Statistics, 13(1),
#' 41-54.
#'
#' @seealso [posterior()], [oc_frequentist()], [oc_bayesian()].
#'
#' @examples
#' src <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
#' rmp(src, weight = 0.5)
#' npp(src, a0_mean = 0.5, a0_sd = 0.2)
#' commensurate_prior(src)
#' @name borrowing_priors
NULL


#' Build a prior specification
#'
#' @param source A `bexte_source`.
#' @param method The method name `Model$create()` dispatches on.
#' @param class The method's S3 subclass.
#' @param label A human-readable method name.
#' @param ... Method parameters.
#' @keywords internal
#' @noRd
new_bexte_prior <- function(source, method, class, label, ...) {
  if (!inherits(source, "bexte_source")) {
    stop("`source` should come from source_data().", call. = FALSE)
  }
  structure(
    list(
      method = method,
      label = label,
      method_parameters = c(list(initial_prior = "noninformative"), list(...)),
      source = source
    ),
    class = c(class, "bexte_prior")
  )
}

check_unit_interval <- function(x, name, open = FALSE) {
  assert_single_number(x)
  bad <- if (open) x <= 0 || x >= 1 else x < 0 || x > 1
  if (bad) {
    stop("`", name, "` should lie in ", if (open) "(0, 1)" else "[0, 1]", ".",
         call. = FALSE)
  }
  invisible(x)
}

check_positive <- function(x, name) {
  assert_single_number(x)
  if (x <= 0) {
    stop("`", name, "` should be positive.", call. = FALSE)
  }
  invisible(x)
}

check_heterogeneity_prior <- function(heterogeneity_prior) {
  families <- c("inverse_gamma", "half_normal", "cauchy")
  if (!is.list(heterogeneity_prior) || !isTRUE(heterogeneity_prior$family %in% families)) {
    stop("`heterogeneity_prior` should be a list whose `family` is one of ",
         paste0('"', families, '"', collapse = ", "), ".", call. = FALSE)
  }
  invisible(heterogeneity_prior)
}

default_heterogeneity_prior <- function() {
  list(family = "inverse_gamma", alpha = 1 / 7, beta = 1)
}

#' @rdname borrowing_priors
#' @export
separate_prior <- function(source) {
  new_bexte_prior(source, "separate", "bexte_separate", "Separate analysis")
}

#' @rdname borrowing_priors
#' @export
pooling_prior <- function(source) {
  new_bexte_prior(source, "pooling", "bexte_pooling", "Pooling")
}

#' @rdname borrowing_priors
#' @export
power_prior <- function(source, a0) {
  check_unit_interval(a0, "a0")
  new_bexte_prior(source, "conditional_power_prior", "bexte_power_prior",
                  "Power prior", power_parameter = a0)
}

#' @rdname borrowing_priors
#' @export
npp <- function(source, a0_mean = 0.5, a0_sd = 0.2) {
  check_unit_interval(a0_mean, "a0_mean", open = TRUE)
  check_positive(a0_sd, "a0_sd")
  if (a0_sd^2 >= a0_mean * (1 - a0_mean)) {
    stop("`a0_sd` is too large for a Beta prior with mean `a0_mean`: ",
         "it should be below sqrt(a0_mean * (1 - a0_mean)).", call. = FALSE)
  }
  new_bexte_prior(source, "NPP", "bexte_npp", "Normalised power prior",
                  power_parameter_mean = a0_mean, power_parameter_std = a0_sd)
}

#' @rdname borrowing_priors
#' @export
npp_kl <- function(source, lambda = 0.5, c_target = 10, d_mtd_multiplier = 1) {
  check_unit_interval(lambda, "lambda")
  check_positive(c_target, "c_target")
  check_positive(d_mtd_multiplier, "d_mtd_multiplier")
  new_bexte_prior(source, "NPP_KL", "bexte_npp_kl", "KL-calibrated normalised power prior",
                  lambda_kl = lambda, c_target = c_target,
                  d_mtd_rule = "source_to_null", d_mtd_multiplier = d_mtd_multiplier)
}

#' @rdname borrowing_priors
#' @export
rmp <- function(source, weight = 0.5, empirical_bayes = FALSE) {
  check_unit_interval(weight, "weight")
  if (!isTRUE(empirical_bayes) && !isFALSE(empirical_bayes)) {
    stop("`empirical_bayes` should be TRUE or FALSE.", call. = FALSE)
  }
  new_bexte_prior(source, "RMP", "bexte_rmp", "Robust mixture prior",
                  prior_weight = weight, empirical_bayes = empirical_bayes)
}

#' @rdname borrowing_priors
#' @export
egidi_mixture <- function(source, alpha_pc = 0.05, pvalue_method = "exact",
                          weight_grid_step = 0.001) {
  check_unit_interval(alpha_pc, "alpha_pc", open = TRUE)
  check_unit_interval(weight_grid_step, "weight_grid_step", open = TRUE)
  new_bexte_prior(source, "egidi_empirical_mixture", "bexte_egidi_mixture",
                  "Empirical mixture prior (Egidi)",
                  alpha_pc = alpha_pc, pvalue_method = pvalue_method,
                  weight_grid_step = weight_grid_step, empirical_bayes = TRUE)
}

#' @rdname borrowing_priors
#' @export
commensurate_prior <- function(source, heterogeneity_prior = default_heterogeneity_prior()) {
  check_heterogeneity_prior(heterogeneity_prior)
  new_bexte_prior(source, "commensurate_prior", "bexte_commensurate_prior",
                  "Commensurate prior", heterogeneity_prior = heterogeneity_prior)
}

#' @rdname borrowing_priors
#' @export
commensurate_power_prior <- function(source, heterogeneity_prior = default_heterogeneity_prior()) {
  check_heterogeneity_prior(heterogeneity_prior)
  new_bexte_prior(source, "commensurate_power_prior", "bexte_commensurate_power_prior",
                  "Commensurate power prior", heterogeneity_prior = heterogeneity_prior)
}

#' @rdname borrowing_priors
#' @export
eb_power_prior <- function(source) {
  new_bexte_prior(source, "EB_PP", "bexte_eb_power_prior", "Empirical Bayes power prior")
}

#' @rdname borrowing_priors
#' @export
pvalue_power_prior <- function(source, shape = 1, equivalence_margin = 0.5) {
  check_positive(shape, "shape")
  check_positive(equivalence_margin, "equivalence_margin")
  new_bexte_prior(source, "p_value_based_PP", "bexte_pvalue_power_prior",
                  "p-value based power prior",
                  shape_parameter = shape, equivalence_margin = equivalence_margin)
}

#' @rdname borrowing_priors
#' @export
pdccpp <- function(source, desired_tie = 0.065, significance_level = 0.05, n_iter = 1e6) {
  check_unit_interval(desired_tie, "desired_tie", open = TRUE)
  check_unit_interval(significance_level, "significance_level", open = TRUE)
  check_positive(n_iter, "n_iter")
  new_bexte_prior(source, "PDCCPP", "bexte_pdccpp",
                  "Prior-data conflict calibrated power prior",
                  desired_tie = desired_tie, significance_level = significance_level,
                  tolerance = 1e-4, n_iter = n_iter)
}

#' @rdname borrowing_priors
#' @export
test_then_pool <- function(source, type = c("difference", "equivalence"),
                           significance_level = 0.1, equivalence_margin = 0.5) {
  type <- match.arg(type)
  check_unit_interval(significance_level, "significance_level", open = TRUE)
  if (type == "difference") {
    return(new_bexte_prior(source, "test_then_pool_difference", "bexte_test_then_pool",
                           "Test-then-pool (difference)",
                           significance_level = significance_level))
  }
  check_positive(equivalence_margin, "equivalence_margin")
  new_bexte_prior(source, "test_then_pool_equivalence", "bexte_test_then_pool",
                  "Test-then-pool (equivalence)",
                  significance_level = significance_level,
                  equivalence_margin = equivalence_margin)
}
