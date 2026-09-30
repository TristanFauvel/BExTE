#' Recycle Egidi mixture arguments to a common length
#'
#' The conflict p-value is evaluated once per replicate, and each of the
#' replicate-varying quantities may arrive as a scalar shared by every replicate
#' or as one value per replicate. Recycling them here keeps every downstream
#' expression a plain elementwise one.
#'
#' @param ... Named numeric vectors.
#' @return A list of the same names, each recycled to the longest length.
#' @keywords internal
egidi_recycle <- function(...) {
  arguments <- list(...)
  n <- max(vapply(arguments, length, integer(1)))
  lapply(arguments, rep_len, length.out = n)
}

#' Outer bounds of the region where a two-component normal mixture exceeds a level
#'
#' The conflict p-value integrates the predictive mixture over the set where its
#' density is at or below the density at the observed statistic. That set is the
#' complement of a bounded region, and this returns an interval containing it.
#'
#' A component whose weighted density never reaches `level / 2` cannot on its own
#' carry the mixture above `level`, so halving the level makes the bound valid for
#' the sum rather than for either term: outside the returned interval both
#' components sit below `level / 2` and the mixture below `level`.
#'
#' @param level The density level, one per replicate.
#' @param weights A list of the two component weights.
#' @param means A list of the two component means.
#' @param sds A list of the two component standard deviations.
#' @return A list with `lower` and `upper`, each one value per replicate.
#' @keywords internal
egidi_level_bounds <- function(level, weights, means, sds) {
  half <- level / 2

  distance <- function(weight, sd) {
    # Where weight * dnorm(t; mu, sd) == half, measured from the mean. A ratio
    # at or above one means the component never reaches half, so it contributes
    # no distance at all rather than a negative square root.
    ratio <- pmin(1, half * sd * sqrt(2 * pi) / weight)
    sd * sqrt(pmax(0, -2 * log(ratio)))
  }

  spread_p <- distance(weights[[1]], sds[[1]])
  spread_q <- distance(weights[[2]], sds[[2]])

  list(
    lower = pmin(means[[1]] - spread_p, means[[2]] - spread_q),
    upper = pmax(means[[1]] + spread_p, means[[2]] + spread_q)
  )
}

#' Prior-predictive conflict p-value of a two-component normal mixture
#'
#' @description The Egidi, Pauli and Torelli conflict p-value
#' \deqn{P_\psi(t) = \Pr_{T \sim m_\psi}\{m_\psi(T) \le m_\psi(t)\},}
#' where \eqn{m_\psi = \psi m_q + (1 - \psi) m_p} is the prior-predictive density
#' of the mixture and each component predictive is normal.
#'
#' @details
#' The inequality is taken on the density of the complete mixture, not by
#' averaging component-specific p-values, which would be a different quantity
#' whenever the two components have different centres.
#'
#' No quadrature is needed. A two-component normal mixture density is a sum of
#' two unimodal bumps, so \eqn{\{m_\psi > c\}} is a union of at most two bounded
#' intervals and \eqn{m_\psi(t) = c} has at most four roots. Integrating the
#' mixture between consecutive roots is closed form, so only the roots are found
#' numerically.
#'
#' The roots are located by first splitting the line into the pieces on which the
#' density is monotone, which is what makes the result robust. Below both
#' component means every term of \eqn{m_\psi'} is positive and the density is
#' strictly increasing; above both means it is strictly decreasing. All turning
#' points therefore lie between the two means, where \eqn{m_\psi'} is scanned on a
#' grid fine enough to resolve the narrower component and its sign changes are
#' refined by root-finding. There are at most three of them, giving at most four
#' monotone pieces, each of which holds at most one root. Both refinements run
#' [vectorised_bracketed_root()] on a bracket found beforehand, so neither can
#' lose its root.
#'
#' Scanning for the level crossings directly would not be robust: when the
#' observed statistic sits near a turning point the region above the level can be
#' far narrower than either component, and any fixed grid will step over it.
#' Turning points do not have that failure mode, because they are separated on the
#' components' own scales.
#'
#' Two cases are exact and need no root-finding. A degenerate weight collapses the
#' mixture to a single normal, whose conflict p-value is
#' \eqn{2\Phi(-|t - \mu| / \sigma)} whatever the two centres are; this is what
#' decides the common no-conflict case. Equal centres make the mixture symmetric
#' and decreasing in \eqn{|t - \mu|}, so the conflict p-value is the weighted sum
#' of the component tail probabilities.
#'
#' @param t_obs Observed target statistic, one per replicate.
#' @param psi Weight on the weak component, in \eqn{[0, 1]}.
#' @param mu_p Mean of the informative component's predictive.
#' @param sigma_p Standard deviation of the informative component's predictive,
#'   \eqn{\sqrt{s_T^2 + \tau_p^2}}.
#' @param mu_q Mean of the weak component's predictive.
#' @param sigma_q Standard deviation of the weak component's predictive,
#'   \eqn{\sqrt{s_T^2 + \tau_q^2}}.
#' @param root_tolerance Relative width at which each bracketed turning point
#'   and each root is considered found.
#' @return The conflict p-value, one per replicate.
#' @keywords internal
egidi_normal_conflict_pvalue <- function(t_obs, psi, mu_p, sigma_p, mu_q, sigma_q,
                                         root_tolerance = 1e-13) {
  recycled <- egidi_recycle(t_obs = t_obs, psi = psi, mu_p = mu_p,
                            sigma_p = sigma_p, mu_q = mu_q, sigma_q = sigma_q)
  t_obs <- recycled$t_obs
  psi <- recycled$psi
  mu_p <- recycled$mu_p
  sigma_p <- recycled$sigma_p
  mu_q <- recycled$mu_q
  sigma_q <- recycled$sigma_q

  pvalue <- rep(NA_real_, length(t_obs))

  # A degenerate weight leaves a single normal, whose conflict p-value is the
  # two-sided tail probability at the observed statistic. Exact for any centres.
  at_informative <- psi <= 0
  at_weak <- psi >= 1
  pvalue[at_informative] <- 2 * stats::pnorm(
    -abs(t_obs[at_informative] - mu_p[at_informative]) / sigma_p[at_informative]
  )
  pvalue[at_weak] <- 2 * stats::pnorm(
    -abs(t_obs[at_weak] - mu_q[at_weak]) / sigma_q[at_weak]
  )

  # Equal centres make the mixture symmetric and decreasing in the distance from
  # the shared centre, so the conflict set is a pair of matching tails and the
  # p-value is the weighted sum of the component tail probabilities.
  centred <- !at_informative & !at_weak & (mu_p == mu_q)
  if (any(centred)) {
    deviation <- abs(t_obs[centred] - mu_p[centred])
    pvalue[centred] <-
      (1 - psi[centred]) * 2 * stats::pnorm(-deviation / sigma_p[centred]) +
      psi[centred] * 2 * stats::pnorm(-deviation / sigma_q[centred])
  }

  active <- !at_informative & !at_weak & !centred
  if (!any(active)) {
    return(pvalue)
  }

  t_obs <- t_obs[active]
  psi <- psi[active]
  mu_p <- mu_p[active]
  sigma_p <- sigma_p[active]
  mu_q <- mu_q[active]
  sigma_q <- sigma_q[active]
  n <- length(t_obs)

  density <- function(t, i = seq_len(n)) {
    (1 - psi[i]) * stats::dnorm(t, mu_p[i], sigma_p[i]) +
      psi[i] * stats::dnorm(t, mu_q[i], sigma_q[i])
  }
  # The level crossings are found on the log scale, where the tails of the
  # density neither underflow nor flatten out.
  log_density <- function(t, i = seq_len(n)) {
    informative <- log1p(-psi[i]) + stats::dnorm(t, mu_p[i], sigma_p[i], log = TRUE)
    weak <- log(psi[i]) + stats::dnorm(t, mu_q[i], sigma_q[i], log = TRUE)
    largest <- pmax(informative, weak)
    largest + log(exp(informative - largest) + exp(weak - largest))
  }
  distribution <- function(t) {
    (1 - psi) * stats::pnorm(t, mu_p, sigma_p) + psi * stats::pnorm(t, mu_q, sigma_q)
  }

  # Turning points are found from the sign of the derivative, but the derivative
  # itself is not evaluated: between the two means its two terms have opposite
  # signs, so the difference of their logarithms has the derivative's sign. Well
  # separated components make each term underflow to zero at the other's mean,
  # which would hide every sign change if the difference were formed directly.
  informative_is_left <- mu_p < mu_q
  mean_left <- ifelse(informative_is_left, mu_p, mu_q)
  sd_left <- ifelse(informative_is_left, sigma_p, sigma_q)
  weight_left <- ifelse(informative_is_left, 1 - psi, psi)
  mean_right <- ifelse(informative_is_left, mu_q, mu_p)
  sd_right <- ifelse(informative_is_left, sigma_q, sigma_p)
  weight_right <- ifelse(informative_is_left, psi, 1 - psi)

  rising_margin <- function(t, i) {
    t <- pmin(pmax(t, mean_left[i]), mean_right[i])
    pull_up <- log(weight_right[i]) + log(mean_right[i] - t) -
      2 * log(sd_right[i]) + stats::dnorm(t, mean_right[i], sd_right[i], log = TRUE)
    pull_down <- log(weight_left[i]) + log(t - mean_left[i]) -
      2 * log(sd_left[i]) + stats::dnorm(t, mean_left[i], sd_left[i], log = TRUE)
    pull_up - pull_down
  }

  level <- density(t_obs)
  log_level <- log_density(t_obs)

  # A level that has underflowed puts every point of the sample space strictly
  # above it, so the conflict set is empty. Reporting zero is the limit of the
  # p-value rather than a failure.
  underflowed <- !is.finite(level) | level <= 0

  bounds <- egidi_level_bounds(
    level = level,
    weights = list(1 - psi, psi),
    means = list(mu_p, mu_q),
    sds = list(sigma_p, sigma_q)
  )
  lower <- pmin(bounds$lower, mean_left)
  upper <- pmax(bounds$upper, mean_right)

  # Turning points lie strictly between the means, where they are the zeros of
  # the rising margin g. Writing t = mean_left + gap * u, the derivative of g
  # has the sign of the cubic
  #   h(u) = (B + (A - B) u) u (1 - u) - 1,
  # with A = (gap / sd_left)^2 and B = (gap / sd_right)^2. h is -1 at both ends
  # of [0, 1] and has its local maximum inside, at u_top below, so it is either
  # negative throughout - g decreases from +Inf to -Inf and has one zero - or
  # positive on an interval (u_1, u_2), in which case g decreases, increases and
  # decreases again, and has a zero on each of those pieces that changes sign.
  # Either way the pieces are monotone, so each zero is bracketed exactly and
  # none can be missed, however narrow the components.
  gap <- mean_right - mean_left
  A <- (gap / sd_left)^2
  B <- (gap / sd_right)^2
  h <- function(u, i) (B[i] + (A[i] - B[i]) * u) * u * (1 - u) - 1
  u_top <- B / (2 * B - A + sqrt(A^2 - A * B + B^2))
  at_u <- function(u, i) mean_left[i] + gap[i] * u

  # Pieces of the unit interval on which g is monotone, one row per replicate:
  # [0, u_1], [u_1, u_2] and [u_2, 1], or [0, 1] alone when h stays negative.
  piece_ends <- cbind(0, u_top, u_top, 1)
  bends <- which(h(u_top, seq_len(n)) > 0)
  if (length(bends) > 0) {
    first <- vectorised_bracketed_root(
      f = function(u, within) h(u, bends[within]),
      lower = rep(0, length(bends)), upper = u_top[bends],
      f_lower = rep(-1, length(bends)), f_upper = h(u_top[bends], bends),
      tolerance = root_tolerance
    )
    second <- vectorised_bracketed_root(
      f = function(u, within) h(u, bends[within]),
      lower = u_top[bends], upper = rep(1, length(bends)),
      f_lower = h(u_top[bends], bends), f_upper = rep(-1, length(bends)),
      tolerance = root_tolerance
    )
    piece_ends[bends, 2] <- first$root
    piece_ends[bends, 3] <- second$root
  }
  single <- setdiff(seq_len(n), bends)
  piece_ends[single, 2:3] <- 1

  # g is +Inf at the left mean and -Inf at the right one.
  turning <- matrix(NA_real_, nrow = n, ncol = 3L)
  for (piece in 1:3) {
    left_u <- piece_ends[, piece]
    right_u <- piece_ends[, piece + 1L]
    g_left <- ifelse(left_u == 0, Inf, rising_margin(at_u(left_u, seq_len(n)), seq_len(n)))
    g_right <- ifelse(right_u == 1, -Inf, rising_margin(at_u(right_u, seq_len(n)), seq_len(n)))
    changes <- which(right_u > left_u & ((g_left > 0) != (g_right > 0) | g_left == 0))
    if (length(changes) == 0) {
      next
    }
    zero <- vectorised_bracketed_root(
      f = function(t, within) rising_margin(t, changes[within]),
      lower = at_u(left_u[changes], changes),
      upper = at_u(right_u[changes], changes),
      f_lower = g_left[changes],
      f_upper = g_right[changes],
      tolerance = root_tolerance
    )
    turning[changes, piece] <- zero$root
  }

  # The density rises at the left mean and falls at the right one, so at least
  # one turning point is always present. Unused slots hold the right mean, which
  # leaves the boundaries sorted and the extra pieces empty.
  turning <- sort_rows(turning)
  turning[is.na(turning)] <- matrix(mean_right, nrow = n, ncol = 3L)[is.na(turning)]

  # Each consecutive pair of boundaries is a piece on which the density is
  # monotone, so it holds at most one root and a bracketed search cannot miss it.
  boundaries <- cbind(lower, turning, upper)
  roots <- matrix(NA_real_, nrow = n, ncol = ncol(boundaries) - 1L)
  for (piece in seq_len(ncol(boundaries) - 1L)) {
    left <- boundaries[, piece]
    right <- boundaries[, piece + 1L]
    excess_left <- log_density(left) - log_level
    excess_right <- log_density(right) - log_level
    brackets <- (excess_left > 0) != (excess_right > 0)
    brackets[is.na(brackets)] <- FALSE
    if (!any(brackets)) {
      next
    }
    index <- which(brackets)
    found <- vectorised_bracketed_root(
      f = function(t, within) {
        rows <- index[within]
        log_density(t, rows) - log_level[rows]
      },
      lower = left[index],
      upper = right[index],
      f_lower = excess_left[index],
      f_upper = excess_right[index],
      tolerance = root_tolerance
    )
    roots[index, piece] <- found$root
  }

  # The density vanishes in both tails, so the crossings come in pairs and the
  # region above the level is the union of the intervals between the first and
  # second root, the third and fourth, and so on.
  ordered <- sort_rows(roots)
  mass <- rep(0, n)
  for (pair in seq_len(ncol(ordered) %/% 2)) {
    contribution <- distribution(ordered[, 2 * pair]) -
      distribution(ordered[, 2 * pair - 1])
    contribution[is.na(contribution)] <- 0
    mass <- mass + contribution
  }

  resolved <- pmin(pmax(1 - mass, 0), 1)
  resolved[underflowed] <- 0
  pvalue[active] <- resolved
  pvalue
}

#' Prior-predictive conflict p-value by simulation
#'
#' @description The Monte Carlo fallback of [egidi_normal_conflict_pvalue()], for
#' checking the deterministic calculation and for sampling distributions with no
#' closed-form level sets. Egidi, Pauli and Torelli used 1000 hypothetical
#' replications; the deterministic route is preferred in the simulation study
#' because a nested Monte Carlo error would propagate into every operating
#' characteristic.
#'
#' @details
#' The estimator adds one to the numerator and the denominator, which keeps the
#' p-value away from zero and makes it the usual randomisation-test estimator.
#' Drawing the component indicator and both component values up front means the
#' same underlying uniforms serve every candidate weight, so the p-values compared
#' across candidates differ only through the weight.
#'
#' @param t_obs Observed target statistic, a single value.
#' @param psi Weight on the weak component, a single value.
#' @param mu_p,sigma_p Informative component predictive mean and standard deviation.
#' @param mu_q,sigma_q Weak component predictive mean and standard deviation.
#' @param draws Number of hypothetical replications.
#' @param seed Optional seed, so that a replicate's p-value is reproducible.
#' @return A list with the estimate `pvalue` and its `standard_error`.
#' @keywords internal
egidi_monte_carlo_conflict_pvalue <- function(t_obs, psi, mu_p, sigma_p,
                                              mu_q, sigma_q,
                                              draws = 1000L, seed = NULL) {
  if (!is.null(seed)) {
    withr::local_seed(seed)
  }

  from_weak <- stats::runif(draws) < psi
  simulated <- ifelse(
    from_weak,
    stats::rnorm(draws, mu_q, sigma_q),
    stats::rnorm(draws, mu_p, sigma_p)
  )

  density <- function(t) {
    (1 - psi) * stats::dnorm(t, mu_p, sigma_p) + psi * stats::dnorm(t, mu_q, sigma_q)
  }
  conflicting <- density(simulated) <= density(t_obs)

  estimate <- (1 + sum(conflicting)) / (draws + 1)
  list(
    pvalue = estimate,
    standard_error = sqrt(estimate * (1 - estimate) / draws)
  )
}

#' First candidate weight at which the conflict criterion is met
#'
#' @description Scans a grid upwards and returns, for each replicate, the
#' interval in which the criterion is first satisfied.
#'
#' @details
#' The scan runs upwards and stops at the first crossing rather than searching the
#' whole interval, because the quantity wanted is an infimum. A bisection over
#' \eqn{[0, 1]} would be wrong here: the conflict p-value is not monotone in the
#' weight when the components have different centres, and it can fall before it
#' rises when the observed statistic sits near the informative component's centre.
#'
#' Replicates leave the scan as they resolve, so later steps are evaluated only
#' for those still looking.
#'
#' @param lower,upper Per-replicate ends of the interval to scan.
#' @param steps Number of equal steps the interval is cut into.
#' @param evaluate Function of a candidate weight and the row indices it belongs
#'   to, returning the conflict p-value.
#' @param alpha_pc Conflict threshold.
#' @param lower_value,upper_value The conflict p-value at `lower` and `upper`,
#'   which are carried to the ends of the bracket so that refining it needs no
#'   further evaluation there. `NA` when unknown.
#' @return A list with the bracketing `lower` and `upper` weights, and the
#'   conflict p-values there as `lower_value` and `upper_value`.
#' @keywords internal
egidi_first_crossing <- function(lower, upper, steps, evaluate, alpha_pc,
                                 lower_value = rep(NA_real_, length(lower)),
                                 upper_value = rep(NA_real_, length(lower))) {
  n <- length(lower)
  resolved <- rep(FALSE, n)
  bracket_lower <- lower
  bracket_upper <- upper
  previous <- lower
  previous_value <- lower_value
  bracket_lower_value <- lower_value
  bracket_upper_value <- upper_value

  for (step in seq_len(steps)) {
    remaining <- which(!resolved)
    if (!length(remaining)) {
      break
    }
    candidate <- lower[remaining] +
      (upper[remaining] - lower[remaining]) * step / steps
    value <- evaluate(candidate, remaining)
    crossed <- value >= alpha_pc

    found <- remaining[crossed]
    bracket_lower[found] <- previous[found]
    bracket_lower_value[found] <- previous_value[found]
    bracket_upper[found] <- candidate[crossed]
    bracket_upper_value[found] <- value[crossed]
    resolved[found] <- TRUE
    previous[remaining] <- candidate
    previous_value[remaining] <- value
  }

  # The upper end satisfies the criterion by construction, so anything the scan
  # did not resolve crosses in its final step.
  missed <- !resolved
  bracket_lower[missed] <- previous[missed]
  bracket_lower_value[missed] <- previous_value[missed]
  bracket_upper[missed] <- upper[missed]

  list(
    lower = bracket_lower, upper = bracket_upper,
    lower_value = bracket_lower_value, upper_value = bracket_upper_value
  )
}

#' Select the smallest acceptable weak-component weight
#'
#' @description Implements the Egidi, Pauli and Torelli selection rule
#' \deqn{\hat\psi = \inf\{\psi \in [0, 1] : P_\psi(t_{obs}) \ge \alpha_{PC}\},}
#' separately for every replicate and using only the observed target statistic.
#'
#' @details
#' Both ends of the interval are exact and are tried first, which decides most
#' replicates without any search. \eqn{P_0} is the conflict p-value under the
#' informative component alone: when it already reaches the threshold there is no
#' conflict to resolve and the selected weight is zero. \eqn{P_1} is the conflict
#' p-value under the weak component alone: when even that falls short, no weight
#' removes the conflict, and the rule returns one while flagging the conflict as
#' unresolved rather than treating it as resolved.
#'
#' With common centres the mixture predictive is symmetric, \eqn{P_\psi} is exactly
#' \eqn{(1 - \psi)P_p + \psi P_q}, and the crossing is solved in closed form.
#' Otherwise the weight is found by scanning upwards for the first crossing and
#' refining it, since monotonicity in \eqn{\psi} is not guaranteed.
#'
#' The scan is run in two stages, a coarse one to locate the crossing and a fine
#' one at `weight_grid_step` inside it, and the crossing is then refined by
#' [vectorised_bracketed_root()]. The two-stage scan agrees with a single scan at `weight_grid_step` unless a crossing both starts
#' and ends inside one coarse step; `weight_scan_step = weight_grid_step` disables
#' the coarse stage.
#'
#' @param t_obs Observed target treatment effect estimate, one per replicate.
#' @param s_target Target standard error, one per replicate.
#' @param mu_p,tau_p Informative component prior mean and standard deviation.
#' @param mu_q,tau_q Weak component prior mean and standard deviation.
#' @param alpha_pc Conflict threshold, 0.05 in the primary analysis.
#' @param weight_grid_step Resolution of the weight scan.
#' @param weight_scan_step Resolution of the coarse stage of the scan.
#' @param weight_tolerance Width of the weight bracket at which the crossing is
#'   considered found.
#' @return A data frame with one row per replicate and the columns `psi_weak`,
#'   `pvalue_informative`, `pvalue_weak`, `pvalue_selected`, `initial_conflict`
#'   and `conflict_unresolved`.
#' @keywords internal
egidi_select_weak_weight <- function(t_obs, s_target, mu_p, tau_p, mu_q, tau_q,
                                     alpha_pc = 0.05,
                                     weight_grid_step = 0.001,
                                     weight_scan_step = 0.02,
                                     weight_tolerance = 1e-12) {
  recycled <- egidi_recycle(t_obs = t_obs, s_target = s_target, mu_p = mu_p,
                            tau_p = tau_p, mu_q = mu_q, tau_q = tau_q)
  t_obs <- recycled$t_obs
  mu_p <- recycled$mu_p
  mu_q <- recycled$mu_q
  sigma_p <- sqrt(recycled$s_target^2 + recycled$tau_p^2)
  sigma_q <- sqrt(recycled$s_target^2 + recycled$tau_q^2)
  n <- length(t_obs)

  # Both ends of the weight interval collapse the mixture to a single normal, so
  # they are closed form whatever the two centres are.
  pvalue_informative <- 2 * stats::pnorm(-abs(t_obs - mu_p) / sigma_p)
  pvalue_weak <- 2 * stats::pnorm(-abs(t_obs - mu_q) / sigma_q)

  psi <- rep(0, n)
  pvalue_selected <- pvalue_informative
  initial_conflict <- pvalue_informative < alpha_pc
  conflict_unresolved <- initial_conflict & (pvalue_weak < alpha_pc)

  psi[conflict_unresolved] <- 1
  pvalue_selected[conflict_unresolved] <- pvalue_weak[conflict_unresolved]

  searching <- initial_conflict & !conflict_unresolved

  # Common centres make the mixture predictive symmetric, so the conflict
  # p-value interpolates the two ends linearly and the crossing is exact.
  centred <- searching & (mu_p == mu_q)
  if (any(centred)) {
    psi[centred] <- (alpha_pc - pvalue_informative[centred]) /
      (pvalue_weak[centred] - pvalue_informative[centred])
    pvalue_selected[centred] <- alpha_pc
  }

  general <- which(searching & !centred)
  if (length(general)) {
    evaluate <- function(candidate, index) {
      rows <- general[index]
      egidi_normal_conflict_pvalue(
        t_obs = t_obs[rows], psi = candidate,
        mu_p = mu_p[rows], sigma_p = sigma_p[rows],
        mu_q = mu_q[rows], sigma_q = sigma_q[rows]
      )
    }

    coarse <- egidi_first_crossing(
      lower = rep(0, length(general)), upper = rep(1, length(general)),
      steps = max(1L, as.integer(round(1 / weight_scan_step))),
      evaluate = evaluate, alpha_pc = alpha_pc,
      lower_value = pvalue_informative[general],
      upper_value = pvalue_weak[general]
    )
    fine <- egidi_first_crossing(
      lower = coarse$lower, upper = coarse$upper,
      steps = max(1L, as.integer(ceiling(weight_scan_step / weight_grid_step))),
      evaluate = evaluate, alpha_pc = alpha_pc,
      lower_value = coarse$lower_value,
      upper_value = coarse$upper_value
    )

    # The upper end of the bracket satisfies the criterion and the lower end does
    # not. The root search keeps that invariant, and the upper end is returned:
    # the selected weight is one the criterion actually holds at.
    index <- seq_along(general)
    refined <- vectorised_bracketed_root(
      f = function(candidate, within) evaluate(candidate, within) - alpha_pc,
      lower = fine$lower,
      upper = fine$upper,
      f_lower = fine$lower_value - alpha_pc,
      f_upper = fine$upper_value - alpha_pc,
      tolerance = weight_tolerance
    )
    high <- refined$upper

    psi[general] <- pmin(pmax(high, 0), 1)
    pvalue_selected[general] <- evaluate(high, index)
  }

  data.frame(
    psi_weak = psi,
    pvalue_informative = pvalue_informative,
    pvalue_weak = pvalue_weak,
    pvalue_selected = pvalue_selected,
    initial_conflict = initial_conflict,
    conflict_unresolved = conflict_unresolved
  )
}

#' Number of quadrature nodes for a prior-predictive table
#'
#' @description Matches the resolution rule of
#' [truncated_normal_mixture_binomial_weights()], but for a whole table rather
#' than a single cell: every response count has to be resolved, and the narrowest
#' binomial likelihood is the one at an empty or a full arm, whose scale is set by
#' the sample size.
#'
#' @param sds Standard deviations of the mixture components.
#' @param n_control,n_treatment Arm sizes.
#' @param maximum Largest number of nodes allowed, which bounds the working
#'   memory of the blocked quadrature.
#' @return An odd number of nodes, as Simpson's rule requires.
#' @keywords internal
egidi_binomial_nodes <- function(sds, n_control, n_treatment, maximum = 4001L) {
  scales <- c(sds, 1 / (n_control + 1), 1 / (n_treatment + 1))
  nodes <- min(max(2001L, ceiling(40 / min(scales))), maximum)
  if (nodes %% 2 == 0) {
    nodes <- nodes + 1L
  }
  as.integer(nodes)
}

#' Joint prior-predictive table of one truncated normal component
#'
#' @description The probability of every pair of response counts under one
#' component of the mixture prior,
#' \deqn{m_j(y_c, y_t) = \int p(y_c, y_t \mid \theta_T, p_c)\,
#'       j(\theta_T, p_c)\, d\theta_T\, dp_c,}
#' with a uniform prior on the control rate and the treatment effect truncated to
#' the range that rate leaves it. This is the same model the robust mixture
#' prior's Stan program encodes, so the weight is selected under the distribution
#' the analysis actually assumes.
#'
#' @details
#' Substituting the treatment rate \eqn{p_t = p_c + \theta_T} for the treatment
#' effect puts both integrals on \eqn{(0, 1)}, and Simpson's rule on a shared grid
#' turns the whole table into one bilinear form,
#' \eqn{B_c^\top K B_t}, where \eqn{K_{ij}} is the truncated normal density of
#' \eqn{p_t - p_c} and the \eqn{B} matrices hold the binomial likelihoods. The
#' sample space is finite, so this enumerates it exactly rather than sampling it.
#'
#' `K` is formed in row blocks because it is square in the number of nodes, and
#' holding it whole would cost hundreds of megabytes at the resolutions the larger
#' arms need.
#'
#' @param mu,sd Mean and standard deviation of the component.
#' @param n_control,n_treatment Arm sizes.
#' @param n_nodes Number of quadrature nodes.
#' @param block Number of rows of the kernel built at a time.
#' @return A `(n_control + 1) x (n_treatment + 1)` matrix of probabilities,
#'   indexed by the number of responders plus one.
#' @keywords internal
egidi_binomial_predictive_table <- function(mu, sd, n_control, n_treatment,
                                            n_nodes = NULL, block = 512L) {
  if (is.null(n_nodes)) {
    n_nodes <- egidi_binomial_nodes(sd, n_control, n_treatment)
  }

  nodes <- seq(0, 1, length.out = n_nodes)
  spacing <- nodes[2] - nodes[1]
  simpson <- c(1, rep(c(4, 2), length.out = n_nodes - 2), 1) * spacing / 3

  normalisers <- stats::pnorm(1 - nodes, mu, sd) - stats::pnorm(-nodes, mu, sd)

  control_likelihood <- outer(nodes, seq.int(0, n_control), function(rate, y) {
    stats::dbinom(y, n_control, rate)
  }) * simpson
  treatment_likelihood <- outer(nodes, seq.int(0, n_treatment), function(rate, y) {
    stats::dbinom(y, n_treatment, rate)
  }) * simpson

  # The nodes are equally spaced, so the kernel depends on a pair of nodes only
  # through the difference of their indices. Its 2 n_nodes - 1 distinct values
  # are computed once and indexed, rather than one density per pair.
  offsets <- seq.int(-(n_nodes - 1L), n_nodes - 1L)
  kernel_values <- stats::dnorm(offsets * spacing, mu, sd)

  inner <- matrix(0, nrow = n_nodes, ncol = n_treatment + 1L)
  for (start in seq.int(1L, n_nodes, by = block)) {
    rows <- seq.int(start, min(start + block - 1L, n_nodes))
    kernel <- matrix(
      kernel_values[outer(rows, seq_len(n_nodes), function(control, treatment) {
        treatment - control + n_nodes
      })],
      nrow = length(rows)
    )
    # Where the component has no mass left after truncation the row contributes
    # nothing, rather than a ratio of two zeros.
    scaling <- ifelse(normalisers[rows] > 0, 1 / normalisers[rows], 0)
    inner[rows, ] <- (kernel * scaling) %*% treatment_likelihood
  }

  crossprod(control_likelihood, inner)
}

#' Cache of prior-predictive tables
#'
#' @description A table depends on the component and the arm sizes alone, not
#' on the drift, so every scenario of a design reads the same ones. The store
#' lives in the package rather than on a model because a model is built afresh
#' for each scenario, the same reason [inference_cache_store] does.
#'
#' @keywords internal
egidi_table_cache_store <- new.env(parent = emptyenv())

#' Empty the prior-predictive table cache
#'
#' @return `NULL`, invisibly.
#' @keywords internal
egidi_table_cache_reset <- function() {
  rm(
    list = ls(envir = egidi_table_cache_store, all.names = TRUE),
    envir = egidi_table_cache_store
  )
  invisible(NULL)
}

#' Prior-predictive table of one component, built once per worker
#'
#' @description Returns [egidi_binomial_predictive_table()] for these inputs,
#' from the cache when it holds it. A table is a deterministic function of its
#' inputs, so serving it from the cache changes nothing but the time taken.
#'
#' The weak component's scale takes a few hundred rounded values per design, and
#' the largest arms give tables of several hundred kilobytes, so the cache is
#' emptied once it holds `max_bytes`, which bounds each worker's memory.
#'
#' @param mu,sd Mean and standard deviation of the component.
#' @param n_control,n_treatment Arm sizes.
#' @param n_nodes Number of quadrature nodes.
#' @param max_bytes Size the cache may reach before it is emptied.
#' @return The table.
#' @keywords internal
egidi_cached_predictive_table <- function(mu, sd, n_control, n_treatment, n_nodes,
                                          max_bytes = 128 * 1024^2) {
  key <- paste(format(mu, digits = 17), format(sd, digits = 17),
               n_control, n_treatment, n_nodes, sep = "/")
  if (exists(key, envir = egidi_table_cache_store, inherits = FALSE)) {
    return(get(key, envir = egidi_table_cache_store))
  }

  table <- egidi_binomial_predictive_table(
    mu = mu, sd = sd, n_control = n_control,
    n_treatment = n_treatment, n_nodes = n_nodes
  )

  held <- mget(ls(envir = egidi_table_cache_store, all.names = TRUE),
               envir = egidi_table_cache_store)
  held_cells <- sum(vapply(held, length, numeric(1)))
  if (8 * (held_cells + length(table)) > max_bytes) {
    egidi_table_cache_reset()
  }
  assign(key, table, envir = egidi_table_cache_store)
  table
}

#' Exact discrete conflict p-value for a two-arm binomial target
#'
#' @description The discrete counterpart of [egidi_normal_conflict_pvalue()]:
#' the total prior-predictive probability of every pair of response counts whose
#' probability is at or below that of the observed pair.
#'
#' @details
#' Ties are possible on a finite sample space and matter, because a cell excluded
#' by a rounding difference removes its whole probability from the sum rather than
#' an infinitesimal amount. The comparison therefore carries a relative tolerance.
#'
#' @param table_informative,table_weak Component tables from
#'   [egidi_binomial_predictive_table()].
#' @param psi Weight on the weak component, one value.
#' @param y_control,y_treatment Observed responder counts.
#' @param tolerance Relative tolerance used when comparing probabilities.
#' @return The conflict p-value.
#' @keywords internal
egidi_binomial_conflict_pvalue <- function(table_informative, table_weak, psi,
                                           y_control, y_treatment,
                                           tolerance = 1e-9) {
  mixture <- (1 - psi) * table_informative + psi * table_weak
  observed <- mixture[y_control + 1L, y_treatment + 1L]
  conflicting <- mixture <= observed * (1 + tolerance) + .Machine$double.xmin
  total <- sum(mixture)
  if (!is.finite(total) || total <= 0) {
    return(NA_real_)
  }
  sum(mixture[conflicting]) / total
}

#' Conflict p-values at many weights at once
#'
#' @description [egidi_binomial_conflict_pvalue()] at every weight in `psi`,
#' for the cost of sorting the table once rather than of one pass over it per
#' weight.
#'
#' @details
#' The mixture is `A + psi (B - A)`, so whether a cell is at or below the
#' observed one, with the same relative tolerance, is a linear inequality in
#' `psi`: every cell enters or leaves the conflict set at a single crossing
#' weight. Sorting the crossings turns the conflict mass at each weight into a
#' difference of cumulative sums. A cell tied with the observed one to rounding
#' at exactly one of the weights may be counted differently than by the direct
#' computation, so a caller that must agree with it exactly re-checks the weight
#' it selects.
#'
#' @param table_informative,table_weak Component tables.
#' @param psi Weights on the weak component.
#' @param y_control,y_treatment Observed responder counts.
#' @param tolerance Relative tolerance used when comparing probabilities.
#' @return The conflict p-value at each weight.
#' @keywords internal
egidi_binomial_conflict_pvalue_path <- function(table_informative, table_weak, psi,
                                                y_control, y_treatment,
                                                tolerance = 1e-9) {
  informative <- as.vector(table_informative)
  difference <- as.vector(table_weak) - informative
  observed <- (y_treatment) * nrow(table_informative) + y_control + 1L

  # Cell i is in the conflict set at weight psi when
  # intercept_i + psi * slope_i <= 0.
  intercept <- informative - (1 + tolerance) * informative[observed] - .Machine$double.xmin
  slope <- difference - (1 + tolerance) * difference[observed]

  # Conflict mass at each weight, as sum(informative) + psi * sum(difference)
  # over the cells in the set.
  mass_informative <- numeric(length(psi))
  mass_difference <- numeric(length(psi))

  # Cells whose comparison does not depend on the weight.
  flat <- slope == 0 & intercept <= 0
  mass_informative <- mass_informative + sum(informative[flat])
  mass_difference <- mass_difference + sum(difference[flat])

  # Rising cells are in the set up to their crossing, falling cells from it.
  rising <- which(slope > 0)
  if (length(rising)) {
    crossing <- -intercept[rising] / slope[rising]
    order_rising <- order(crossing)
    crossing <- crossing[order_rising]
    cumulative_informative <- c(0, cumsum(informative[rising][order_rising]))
    cumulative_difference <- c(0, cumsum(difference[rising][order_rising]))
    # Those crossing below psi have left the set.
    left <- findInterval(psi, crossing, left.open = TRUE)
    mass_informative <- mass_informative +
      cumulative_informative[length(rising) + 1L] - cumulative_informative[left + 1L]
    mass_difference <- mass_difference +
      cumulative_difference[length(rising) + 1L] - cumulative_difference[left + 1L]
  }

  falling <- which(slope < 0)
  if (length(falling)) {
    crossing <- -intercept[falling] / slope[falling]
    order_falling <- order(crossing)
    crossing <- crossing[order_falling]
    cumulative_informative <- c(0, cumsum(informative[falling][order_falling]))
    cumulative_difference <- c(0, cumsum(difference[falling][order_falling]))
    # Those crossing at or below psi have entered it.
    entered <- findInterval(psi, crossing)
    mass_informative <- mass_informative + cumulative_informative[entered + 1L]
    mass_difference <- mass_difference + cumulative_difference[entered + 1L]
  }

  total <- sum(informative) + psi * sum(difference)
  pvalue <- (mass_informative + psi * mass_difference) / total
  pvalue[!is.finite(total) | total <= 0] <- NA_real_
  pvalue
}

#' Select the weak-component weight from a pair of response counts
#'
#' @description The binomial counterpart of [egidi_select_weak_weight()]. The
#' component tables are fixed, so the scan is over candidate weights alone.
#'
#' @details
#' As in the normal case both ends are evaluated first and decide the common
#' cases, and the scan runs upwards for the first crossing because the conflict
#' p-value need not be monotone in the weight. The p-value is a step function of
#' the weight here, since the conflict set can only change when a cell crosses the
#' observed cell's probability, so the crossing is reported at the grid resolution
#' rather than refined further.
#'
#' @param table_informative,table_weak Component tables.
#' @param y_control,y_treatment Observed responder counts.
#' @param alpha_pc Conflict threshold.
#' @param weight_grid_step Resolution of the weight scan.
#' @param tolerance Relative tolerance for comparing probabilities.
#' @return A one-row data frame shaped like [egidi_select_weak_weight()]'s.
#' @keywords internal
egidi_select_weak_weight_binomial <- function(table_informative, table_weak,
                                              y_control, y_treatment,
                                              alpha_pc = 0.05,
                                              weight_grid_step = 0.001,
                                              tolerance = 1e-9) {
  at <- function(psi) {
    egidi_binomial_conflict_pvalue(
      table_informative, table_weak, psi, y_control, y_treatment, tolerance
    )
  }

  pvalue_informative <- at(0)
  pvalue_weak <- at(1)

  if (is.na(pvalue_informative) || is.na(pvalue_weak)) {
    return(data.frame(
      psi_weak = NA_real_, pvalue_informative = pvalue_informative,
      pvalue_weak = pvalue_weak, pvalue_selected = NA_real_,
      initial_conflict = NA, conflict_unresolved = NA
    ))
  }

  if (pvalue_informative >= alpha_pc) {
    return(data.frame(
      psi_weak = 0, pvalue_informative = pvalue_informative,
      pvalue_weak = pvalue_weak, pvalue_selected = pvalue_informative,
      initial_conflict = FALSE, conflict_unresolved = FALSE
    ))
  }
  if (pvalue_weak < alpha_pc) {
    return(data.frame(
      psi_weak = 1, pvalue_informative = pvalue_informative,
      pvalue_weak = pvalue_weak, pvalue_selected = pvalue_weak,
      initial_conflict = TRUE, conflict_unresolved = TRUE
    ))
  }

  candidates <- seq(weight_grid_step, 1, by = weight_grid_step)

  # The p-value at every candidate at once locates the first crossing; the
  # scan's own function then confirms it there and just before it, so that the
  # weight reported is the one the scan below would find. Only if a cell's
  # comparison lands differently under the two ways of computing it - a cell
  # tied with the observed one to rounding, at exactly a candidate weight -
  # does the scan run, and it then decides.
  path <- egidi_binomial_conflict_pvalue_path(
    table_informative, table_weak, candidates, y_control, y_treatment, tolerance
  )
  first <- which(path >= alpha_pc)[1]
  if (!is.na(first)) {
    pvalue <- at(candidates[first])
    confirmed <- pvalue >= alpha_pc &&
      (first == 1L || at(candidates[first - 1L]) < alpha_pc)
    if (confirmed) {
      return(data.frame(
        psi_weak = candidates[first], pvalue_informative = pvalue_informative,
        pvalue_weak = pvalue_weak, pvalue_selected = pvalue,
        initial_conflict = TRUE, conflict_unresolved = FALSE
      ))
    }
  }

  for (candidate in candidates) {
    pvalue <- at(candidate)
    if (pvalue >= alpha_pc) {
      return(data.frame(
        psi_weak = candidate, pvalue_informative = pvalue_informative,
        pvalue_weak = pvalue_weak, pvalue_selected = pvalue,
        initial_conflict = TRUE, conflict_unresolved = FALSE
      ))
    }
  }

  data.frame(
    psi_weak = 1, pvalue_informative = pvalue_informative,
    pvalue_weak = pvalue_weak, pvalue_selected = pvalue_weak,
    initial_conflict = TRUE, conflict_unresolved = FALSE
  )
}

#' Fit the Egidi, Pauli and Torelli empirical mixture prior
#'
#' @description Selects the mixture weight from the observed target summary and
#' then updates the resulting prior with the same summary. The two prior
#' components are the ones the robust mixture prior uses, so the only difference
#' between the two methods is where the weight comes from.
#'
#' @details
#' The procedure is deliberately adaptive: the observed target data are used first
#' to choose the weight on the weak component and then again to update the
#' mixture. `psi_weak` is therefore not a prior probability chosen before the
#' target data were seen, and should not be reported as one.
#'
#' The selected weight and the posterior component weight are different
#' quantities and are both returned. The first is the weight the prior is given;
#' the second is the posterior probability that the treatment effect came from the
#' informative component, obtained from the component marginal likelihoods on the
#' log scale.
#'
#' The robust mixture prior parameterises its mixture by the weight on the
#' informative component, so `w_informative_prior` is `1 - psi_weak`.
#'
#' @param theta_target_hat Observed target treatment effect estimate.
#' @param se_target Target standard error.
#' @param informative_component A list with `mean` and `sd`, the source-based
#'   prior \eqn{p(\theta_T)}.
#' @param weak_component A list with `mean` and `sd`, the weak or unit-information
#'   prior \eqn{q(\theta_T)}.
#' @param alpha_pc Prior-predictive conflict threshold. 0.05 in the primary
#'   analysis; 0.01 and 0.10 are the sensitivity values.
#' @param pvalue_method `"exact"` for the deterministic calculation, or `"mc"` for
#'   the prior-predictive simulation fallback.
#' @param weight_grid_step Resolution of the weight scan.
#' @param mc_draws Number of hypothetical replications when `pvalue_method` is
#'   `"mc"`.
#' @param seed Seed for the simulation fallback. The same seed is used at every
#'   candidate weight, which is what makes the comparison use common random
#'   numbers.
#' @param theta_0 Null value of the treatment effect.
#' @param null_space Either `"left"` or `"right"`.
#' @param confidence_level Credible interval level.
#' @return A list with the selected and posterior weights, the three conflict
#'   p-values, the conflict flags, the posterior mixture and its summaries, the
#'   probability of success, and numerical diagnostics.
#' @export
fit_egidi_mixture <- function(theta_target_hat,
                              se_target,
                              informative_component,
                              weak_component,
                              alpha_pc = 0.05,
                              pvalue_method = c("exact", "mc"),
                              weight_grid_step = 0.001,
                              mc_draws = 1000L,
                              seed = NULL,
                              theta_0 = 0,
                              null_space = "left",
                              confidence_level = 0.95) {
  pvalue_method <- match.arg(pvalue_method)

  mu_p <- informative_component$mean
  tau_p <- informative_component$sd
  mu_q <- weak_component$mean
  tau_q <- weak_component$sd

  sigma_p <- sqrt(se_target^2 + tau_p^2)
  sigma_q <- sqrt(se_target^2 + tau_q^2)

  diagnostics <- list(
    pvalue_method = pvalue_method,
    weight_grid_step = weight_grid_step,
    predictive_sd_informative = sigma_p,
    predictive_sd_weak = sigma_q,
    common_centre = isTRUE(mu_p == mu_q),
    mc_draws = if (pvalue_method == "mc") mc_draws else NA_integer_,
    mc_standard_error = NA_real_
  )

  if (pvalue_method == "exact") {
    selection <- egidi_select_weak_weight(
      t_obs = theta_target_hat, s_target = se_target,
      mu_p = mu_p, tau_p = tau_p, mu_q = mu_q, tau_q = tau_q,
      alpha_pc = alpha_pc, weight_grid_step = weight_grid_step
    )
  } else {
    at <- function(psi) {
      egidi_monte_carlo_conflict_pvalue(
        t_obs = theta_target_hat, psi = psi, mu_p = mu_p, sigma_p = sigma_p,
        mu_q = mu_q, sigma_q = sigma_q, draws = mc_draws, seed = seed
      )
    }
    lowest <- at(0)
    highest <- at(1)
    if (lowest$pvalue >= alpha_pc) {
      chosen <- list(psi = 0, pvalue = lowest$pvalue, unresolved = FALSE)
    } else if (highest$pvalue < alpha_pc) {
      chosen <- list(psi = 1, pvalue = highest$pvalue, unresolved = TRUE)
    } else {
      chosen <- list(psi = 1, pvalue = highest$pvalue, unresolved = FALSE)
      for (candidate in seq(weight_grid_step, 1, by = weight_grid_step)) {
        estimate <- at(candidate)
        if (estimate$pvalue >= alpha_pc) {
          chosen <- list(psi = candidate, pvalue = estimate$pvalue,
                         unresolved = FALSE)
          break
        }
      }
    }
    diagnostics$mc_standard_error <- sqrt(
      chosen$pvalue * (1 - chosen$pvalue) / mc_draws
    )
    selection <- data.frame(
      psi_weak = chosen$psi,
      pvalue_informative = lowest$pvalue,
      pvalue_weak = highest$pvalue,
      pvalue_selected = chosen$pvalue,
      initial_conflict = lowest$pvalue < alpha_pc,
      conflict_unresolved = chosen$unresolved
    )
  }

  psi_weak <- selection$psi_weak
  w_informative_prior <- 1 - psi_weak

  posterior <- normal_mixture_posterior(
    weights = matrix(c(w_informative_prior, psi_weak), nrow = 1),
    means = matrix(c(mu_p, mu_q), nrow = 1),
    sds = matrix(c(tau_p, tau_q), nrow = 1),
    estimate = theta_target_hat,
    standard_error = se_target
  )

  alpha <- (1 - confidence_level) / 2
  summaries <- normal_mixture_summary(
    posterior$weights, posterior$means, posterior$sds,
    probs = c(alpha, 0.5, 1 - alpha)
  )

  below_null <- sum(
    posterior$weights * stats::pnorm(theta_0, posterior$means, posterior$sds)
  )
  probability_of_success <- if (null_space == "left") {
    1 - below_null
  } else {
    below_null
  }

  list(
    psi_weak = psi_weak,
    w_informative_prior = w_informative_prior,
    psi_weak_posterior = posterior$weights[1, 2],
    w_informative_posterior = posterior$weights[1, 1],
    pvalue_informative = selection$pvalue_informative,
    pvalue_weak = selection$pvalue_weak,
    pvalue_selected = selection$pvalue_selected,
    initial_conflict = selection$initial_conflict,
    conflict_unresolved = selection$conflict_unresolved,
    posterior_distribution = list(
      weights = as.vector(posterior$weights),
      means = as.vector(posterior$means),
      sds = as.vector(posterior$sds)
    ),
    posterior_mean = summaries$mean,
    posterior_sd = summaries$sd,
    credible_interval = c(summaries$quantiles[1, 1], summaries$quantiles[1, 3]),
    probability_of_success = probability_of_success,
    convergence_or_numerical_diagnostics = diagnostics
  )
}
