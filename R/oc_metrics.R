#' Drop the replicates whose summary measure is not estimable
#'
#' @description A trial whose summary measure is not estimable - a
#'   recurrent-event arm with no event, or a Cox fit that does not exist - has
#'   no p-value. The Bayesian operating characteristics leave such replicates
#'   out of their denominator (see `Model`), and the simulated frequentist
#'   baselines do the same, so that both are computed on the same trials.
#'
#' @param samples Replicates returned by the target data's `generate()`.
#'
#' @return The estimable rows of `samples`.
#'
#' @keywords internal
#' @export
estimable_replicates <- function(samples) {
  estimable <- is.finite(samples$treatment_effect_estimate) &
    is.finite(samples$standard_deviation)
  if (!any(estimable)) {
    stop("No simulated trial has an estimable summary measure.", call. = FALSE)
  }
  return(samples[estimable, , drop = FALSE])
}

#' Interval score of a credible interval
#'
#' @description The interval score (Winkler 1972; Gneiting and Raftery 2007)
#'   combines the width of an interval estimate with the penalty it incurs when
#'   the true value falls outside it, so that an interval narrowed by shifting
#'   it away from the truth scores worse than the wider interval it replaced.
#'   The width and the coverage read on their own leave that trade-off
#'   ambiguous; the score resolves it into one number.
#'
#'   For a central interval `[lower, upper]` at level `confidence_level`, and
#'   writing `a = 1 - confidence_level`, one replicate scores
#'
#'   \deqn{(u - l) + \frac{2}{a}(l - y)\mathbf{1}\{y < l\} +
#'         \frac{2}{a}(y - u)\mathbf{1}\{y > u\}}{
#'         (u - l) + (2/a) (l - y) 1\{y < l\} + (2/a) (y - u) 1\{y > u\}}
#'
#'   A replicate whose interval covers the true value scores the full width of
#'   that interval. That is the full width, not the half width the `precision`
#'   operating characteristic reports, so the two are not on the same scale.
#'   Smaller is better.
#'
#' @param lower Lower bounds of the intervals, one per replicate.
#' @param upper Upper bounds of the intervals, one per replicate.
#' @param true_value The value the intervals are estimating. Either a single
#'   value shared by every replicate, or one value per replicate.
#' @param confidence_level The level of the intervals, which sets the rate
#'   `2 / (1 - confidence_level)` at which a miss is penalised.
#'
#' @return A numeric vector of scores, one per replicate. `NA` bounds propagate
#'   to `NA` scores, and empty input gives `numeric(0)`.
#'
#' @references Winkler, R. L. (1972). A decision-theoretic approach to interval
#'   estimation. Journal of the American Statistical Association, 67(337),
#'   187-191.
#'
#'   Gneiting, T. and Raftery, A. E. (2007). Strictly proper scoring rules,
#'   prediction, and estimation. Journal of the American Statistical
#'   Association, 102(477), 359-378, equation 43.
#'
#' @keywords internal
interval_score <- function(lower, upper, true_value, confidence_level = 0.95) {
  if (length(lower) != length(upper)) {
    stop("lower and upper must have the same length.")
  }
  if (length(true_value) != 1 && length(true_value) != length(lower)) {
    stop("true_value must be a single value or one value per interval.")
  }
  if (length(confidence_level) != 1 ||
      is.na(confidence_level) ||
      confidence_level <= 0 ||
      confidence_level >= 1) {
    stop("confidence_level must be a single value strictly between 0 and 1.")
  }

  alpha <- 1 - confidence_level

  # pmax() leaves an NA bound as NA rather than folding it to a zero penalty,
  # so a replicate with no usable interval stays missing instead of scoring as
  # though it had been covered.
  return((upper - lower) +
    (2 / alpha) * pmax(lower - true_value, 0) +
    (2 / alpha) * pmax(true_value - upper, 0))
}
