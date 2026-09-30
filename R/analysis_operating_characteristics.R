#' Whether power can be computed analytically for this target data
#'
#' @description The analytical power formulas apply to a normal summary measure
#'   on a continuous endpoint; the remaining endpoints have to be simulated.
#'   Sharing the predicate keeps the power computation and the propagation of
#'   its uncertainty on the same branch.
#'
#'   Recurrent events are simulated too. Mepolizumab used to be priced in
#'   closed form, but its trials are generated patient by patient from a
#'   negative binomial and the standard error is re-estimated in each one, so
#'   the closed form assumed a test the Bayesian methods were never compared
#'   against.
#'
#' @param target_data Target data object.
#'
#' @return `TRUE` when power has a closed form for this target data.
#'
#' @keywords internal
uses_analytical_power <- function(target_data) {
  target_data$endpoint == "normal" ||
    target_data$endpoint == "continuous"
}


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
estimable_replicates <- function(samples) {
  estimable <- is.finite(samples$treatment_effect_estimate) &
    is.finite(samples$standard_deviation)
  if (!any(estimable)) {
    stop("No simulated trial has an estimable summary measure.", call. = FALSE)
  }
  samples[estimable, , drop = FALSE]
}


#' Simulate the p-values of the frequentist test
#'
#' @description Generates `n_replicates` trials and returns the p-value of the
#'   test in each one. Returning the p-values rather than the decisions lets the
#'   power be read off at any significance level without re-simulating.
#'
#' @param target_data Target data object.
#' @param frequentist_test Type of frequentist test to apply.
#' @param theta_0 Boundary of the null hypothesis space.
#' @param alternative Direction of the alternative hypothesis.
#' @param simulation_config Simulation configuration.
#' @param n_replicates Number of trials to simulate.
#'
#' @return A numeric vector of `n_replicates` p-values.
#'
#' @keywords internal
simulate_test_p_values <- function(target_data,
                                   frequentist_test,
                                   theta_0,
                                   alternative,
                                   simulation_config,
                                   n_replicates) {
  if (frequentist_test != "t-test") {
    stop("Only implemented for a t-test.")
  }

  trial_p_values(
    simulated_trials(target_data, simulation_config, n_replicates),
    theta_0 = theta_0,
    alternative = alternative
  )
}

#' The trials a simulated frequentist power is read from
#'
#' @description Seeds the generator with `simulation_config$seed` and
#'   generates `n_replicates` trials, keeping the estimable ones. Every
#'   simulated power of a design - the separate analysis's at the equivalent
#'   and at the nominal type I error, and the pooled analysis's - reads these
#'   same trials, so they are generated once per design and shared. Only the
#'   three summaries the tests read are kept, which is what makes holding one
#'   set per design affordable.
#'
#' @param target_data Target data object.
#' @param simulation_config Simulation configuration.
#' @param n_replicates Number of trials to simulate.
#'
#' @return A data frame with `treatment_effect_estimate`,
#'   `standard_deviation` and `sample_size_per_arm`, one row per estimable
#'   trial.
#' @noRd
simulated_trials <- function(target_data, simulation_config, n_replicates) {
  set.seed(simulation_config$seed)

  samples <- estimable_replicates(target_data$generate(n_replicates))
  data.frame(
    treatment_effect_estimate = samples$treatment_effect_estimate,
    standard_deviation = samples$standard_deviation,
    sample_size_per_arm = samples$sample_size_per_arm
  )
}

#' The separate analysis's t-test p-value in each trial
#'
#' @param trials Trials from [simulated_trials()].
#' @param theta_0 Boundary of the null hypothesis space.
#' @param alternative Direction of the alternative hypothesis.
#'
#' @return A numeric vector of p-values, one per trial.
#' @noRd
trial_p_values <- function(trials, theta_0, alternative) {
  one_sample_t_test_p_values(
    estimate = trials$treatment_effect_estimate,
    mu = theta_0,
    standard_deviation = trials$standard_deviation,
    n = trials$sample_size_per_arm,
    alternative = alternative
  )
}

#' P-values of a one-sample t-test from summary statistics, for many trials
#'
#' @description The p-value `BSDA::tsum.test()` returns for a one-sample test,
#'   computed for every replicate at once. Calling `tsum.test()` once per
#'   replicate cost ~50us each in argument checking and the warning it raises
#'   about `var.equal`, which on 10,000 replicates was most of the test. The
#'   statistic is built with the same operations as `tsum.test()`, so the
#'   p-values agree with it to the last bit.
#'
#' @param estimate Sample means, one per replicate.
#' @param mu Value of the mean under the null hypothesis.
#' @param standard_deviation Sample standard deviations.
#' @param n Sample sizes.
#' @param alternative "greater", "less" or "two.sided".
#'
#' @return A numeric vector of p-values, one per replicate.
#' @noRd
one_sample_t_test_p_values <- function(estimate, mu, standard_deviation, n, alternative) {
  statistic <- (estimate - mu) / sqrt(standard_deviation^2 / n)
  degrees_of_freedom <- n - 1

  switch(
    alternative,
    greater = 1 - stats::pt(statistic, degrees_of_freedom),
    less = stats::pt(statistic, degrees_of_freedom),
    two.sided = 2 * stats::pt(-abs(statistic), degrees_of_freedom),
    stop("alternative must be one of \"greater\", \"less\" or \"two.sided\".")
  )
}
#' Direction of the alternative hypothesis implied by the null space
#'
#' @param null_space Side of the null space, either left or right.
#'
#' @return "greater" or "less".
#' @noRd
alternative_from_null_space <- function(null_space) {
  if (null_space == "left") {
    "greater"
  } else if (null_space == "right") {
    "less"
  } else {
    stop("Null space must be either 'left' or 'right'")
  }
}

#' Closed-form power of the frequentist test
#'
#' Vectorised over `alpha`: every pwr function used here accepts a vector of
#' significance levels and returns one power per level, which is what lets
#' compute_power_with_tie_ci() price 1000 sampled type I errors in a single
#' call instead of 1000 (the per-call overhead of pwr - match.arg, argument
#' assembly, simplify2array - costs more than the power calculation itself).
#'
#' @param alpha Significance level(s).
#' @param target_data Target data object.
#' @param frequentist_test Type of frequentist test to apply.
#' @param theta_0 Boundary of the null hypothesis space.
#' @param alternative Direction of the alternative hypothesis.
#'
#' @return A numeric vector of powers, one per element of `alpha`.
#' @noRd
analytical_power <- function(alpha, target_data, frequentist_test, theta_0, alternative) {
  if (target_data$summary_measure_likelihood == "normal") {
    effect_size <- (target_data$treatment_effect - theta_0) / target_data$standard_deviation

    if (frequentist_test == "t-test") {
      pwr::pwr.t.test(
        d = effect_size,
        n = target_data$sample_size_per_arm,
        sig.level = alpha,
        type = "one.sample",
        alternative = alternative
      )$power
    } else if (frequentist_test == "z-test") {
      pwr::pwr.norm.test(
        d = effect_size,
        n = target_data$sample_size_per_arm,
        sig.level = alpha,
        alternative = alternative
      )$power
    } else {
      stop("Unsupported test type.")
    }
  } else if (target_data$summary_measure_likelihood == "binomial") {
    h <- pwr::ES.h(target_data$treatment_rate, target_data$control_rate)

    pwr::pwr.2p2n.test(
      h = h,
      n1 = target_data$sample_size_per_arm,
      n2 = target_data$sample_size_per_arm,
      sig.level = alpha,
      alternative = alternative
    )$power
  } else {
    stop("Unsupported likelihood type.")
  }
}

#' Check the target data fields the power computations read
#'
#' Hoisted out of compute_freq_power(): compute_power_with_tie_ci()
#' evaluates power at 1000 sampled alphas per result row and target_data is
#' identical across all of them, so asserting inside that call ran the same
#' three checks 3000 times a row. assertions::assert_number() costs ~190us a
#' call (it deparses, matches the call and dispatches over a list of
#' assertion functions), which made argument checking ~87% of the analysis.
#'
#' @param target_data Target study data, as returned by load_data().
#'
#' @return `NULL`, invisibly. Called for the error it raises.
#' @noRd
assert_target_data_numbers <- function(target_data) {
  assertions::assert_number(target_data$treatment_effect)
  assertions::assert_number(target_data$standard_deviation)
  assertions::assert_number(target_data$sample_size_per_arm)

  invisible(NULL)
}



#' Compute the frequentist power
#'
#' @description This function computes the power of a test for a given significance level
#' @description This function computes the power of a test for a given significance level
#'
#' @param alpha The significance level.
#' @param target_data The target data containing sample size, treatment effect, standard deviation, and summary measure distribution.
#' @param frequentist_test The type of frequentist test ("t-test" or "z-test").
#' @param theta_0 The null hypothesis value.
#' @param target_data Target data object
#' @param frequentist_test Type of frequentist test to apply, either z-test or t-test
#' @param theta_0 Boundary of the null hypothesis space
#' @param null_space Side of the null space, either left or right.
#' @param simulation_config Simulation configuration.
#' @param case_study Optional case-study name.
#' @param n_replicates Number of Monte Carlo replicates for non-analytical power calculations.
#' @param p_values Optional p-values already simulated for this design by
#'   [simulate_test_p_values()], with the same seed and `n_replicates`. `NULL`
#'   simulates them. Ignored when the power has a closed form.
#'
#' @return A list containing the power and its confidence interval.
#'
#' @export
compute_freq_power <- function(alpha,
                               target_data,
                               frequentist_test,
                               theta_0,
                               null_space,
                               simulation_config,
                               case_study = NULL,
                               n_replicates = 1000,
                               p_values = NULL) {
  alternative <- alternative_from_null_space(null_space)

  if (is.na(alpha)){
    return(list(
      power = NA_real_,
      conf_int_power = rep(NA_real_, 2)
    ))
  }

  power <- NA # Default value in case of an unsupported distribution

  if (target_data$summary_measure_likelihood == "normal") {
    if (uses_analytical_power(target_data)) {
      power <- analytical_power(alpha, target_data, frequentist_test, theta_0, alternative)

      conf_int_power <- c(power, power)
    } else {
      # In this case, we cannot use an analytical computation of power
      if (is.null(p_values)) {
        p_values <- simulate_test_p_values(
          target_data = target_data,
          frequentist_test = frequentist_test,
          theta_0 = theta_0,
          alternative = alternative,
          simulation_config = simulation_config,
          n_replicates = n_replicates
        )
      }

      test_decisions <- p_values < alpha
      power <- mean(test_decisions)
      conf_int_power <- binom.test(sum(test_decisions), length(test_decisions), conf.level = 0.95)$conf.int
    }
  } else if (target_data$summary_measure_likelihood == "binomial") {
    power <- analytical_power(alpha, target_data, frequentist_test, theta_0, alternative)

    conf_int_power <- c(power, power)
  } else {
    stop("Unsupported likelihood type.")
  }

  return(list(power = power, conf_int_power = conf_int_power))
}

#' Compute a binomial credible interval
#'
#' @description Computes the Clopper-Pearson (exact) confidence interval for a
#'   binomial proportion estimated from 0/1 samples, along with the overall
#'   mean of the samples.
#'
#' @param samples A vector of 0/1 samples, or a matrix whose rows each contain
#'   a separate set of 0/1 samples.
#' @param confidence_level The confidence level of the interval.
#'
#' @return A list with `mean` (the overall mean of `samples`) and `conf_int`
#'   (a data frame with one row per group, containing `lower` and `upper`
#'   bounds).
#'
#' @export
compute_binomial_credible_interval <- function(samples, confidence_level = 0.95) {
  if (is.matrix(samples)) {
    successes <- rowSums(samples)
    trials <- ncol(samples)
  } else {
    successes <- sum(samples)
    trials <- length(samples)
  }

  conf_int <- binom::binom.confint(successes, trials, conf.level = confidence_level, methods = "exact")

  list(
    mean = mean(samples),
    conf_int = conf_int[, c("lower", "upper")]
  )
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
#' @export
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
  (upper - lower) +
    (2 / alpha) * pmax(lower - true_value, 0) +
    (2 / alpha) * pmax(true_value - upper, 0)
}

#' Compute the frequentist power
#'
#' @description This function computes the power of a test for a pooled analysis at a given significance level
#'
#' @param alpha The significance level.
#' @param target_data The target data containing sample size, treatment effect, standard deviation, and summary measure distribution.
#' @param source_data Source study data
#' @param frequentist_test The type of frequentist test ("t-test" or "z-test").
#' @param theta_0 The null hypothesis value.
#' @param target_data Target data object
#' @param frequentist_test Type of frequentist test to apply, either z-test or t-test
#' @param theta_0 Boundary of the null hypothesis space
#' @param null_space Side of the null space, either left or right.
#' @param simulation_config Simulation configuration.
#' @param case_study Optional case-study name.
#' @param n_replicates Number of Monte Carlo replicates for non-analytical power calculations.
#' @param trials Optional trials already simulated for this design, with the
#'   same seed and `n_replicates`, as the separate analysis's power reads them.
#'   `NULL` simulates them. Ignored when the power has a closed form.
#'
#' @return The power of the test.
#'
#' @export
compute_freq_power_pooling <- function(alpha,
                                       target_data,
                                       source_data,
                                       frequentist_test,
                                       theta_0,
                                       null_space,
                                       simulation_config,
                                       case_study =  NULL,
                                       n_replicates = 1000,
                                       trials = NULL) {

  if (null_space == "left") {
    alternative <- "greater"
  } else if (null_space == "right") {
    alternative <- "less"
  } else {
    stop("Null space must be either 'left' or 'right'")
  }

  assertions::assert_number(target_data$treatment_effect)
  assertions::assert_number(target_data$standard_deviation)
  assertions::assert_number(target_data$sample_size_per_arm)

  power <- NA # Default value in case of an unsupported distribution

  if (target_data$summary_measure_likelihood == "normal") {
    if (uses_analytical_power(target_data)) {
      target_treatment_effect_standard_error <- target_data$standard_deviation / sqrt(target_data$sample_size_per_arm)

      pooled_treatment_effect <- (
        source_data$treatment_effect_estimate / (
          source_data$standard_error ^ 2 / target_treatment_effect_standard_error ^
            2 + 1
        )
      ) + (
        target_data$treatment_effect / (
          1 + target_treatment_effect_standard_error ^ 2 / source_data$standard_error ^
            2
        )
      )


      pooled_standard_error_2 <- 1 / (1 / source_data$standard_error ^ 2 + 1 / target_treatment_effect_standard_error ^
                                        2)

      pooled_variance <- pooled_standard_error_2 * (
        target_data$sample_size_per_arm + source_data$equivalent_source_sample_size_per_arm
      )

      effect_size <- (pooled_treatment_effect - theta_0) / sqrt(pooled_variance)


      if (frequentist_test == "t-test") {
        # Use pwr::pwr.t.test for a t-test power calculation
        power <- pwr::pwr.t.test(
          d = effect_size,
          n = target_data$sample_size_per_arm + source_data$equivalent_source_sample_size_per_arm,
          sig.level = alpha,
          type = "one.sample",
          alternative = alternative
        )$power
      } else if (frequentist_test == "z-test") {
        # Calculate the power of the z-test
        power <- pwr::pwr.norm.test(
          d = effect_size,
          n = target_data$sample_size_per_arm + source_data$equivalent_source_sample_size_per_arm,
          sig.level = alpha,
          alternative = alternative
        )$power
      } else {
        stop("Only implemented for a t-test or z-test.")
      }
      conf_int_power <- c(power, power)
    } else {
      # In this case, we cannot use an analytical computation of power. These
      # are the same trials the separate analysis's power is read from.
      target_data_samples <- if (is.null(trials)) {
        simulated_trials(target_data, simulation_config, n_replicates)
      } else {
        trials
      }

      if (frequentist_test != "t-test") {
        stop("Only implemented for a t-test.")
      }

      # Every replicate at once: the arithmetic is elementwise, so each entry
      # is exactly what the former per-replicate loop computed.
      target_treatment_effect_standard_error <- target_data_samples$standard_deviation / sqrt(target_data_samples$sample_size_per_arm)

      pooled_treatment_effect <- (
        source_data$treatment_effect_estimate / (
          source_data$standard_error ^ 2 / target_treatment_effect_standard_error ^
            2 + 1
        )
      ) + (
        target_data_samples$treatment_effect_estimate / (
          1 + target_treatment_effect_standard_error ^ 2 / source_data$standard_error ^
            2
        )
      )

      pooled_standard_error_2 <- 1 / (1 / source_data$standard_error ^ 2 + 1 / target_treatment_effect_standard_error ^
                                        2)

      pooled_sample_size <- target_data$sample_size_per_arm + source_data$equivalent_source_sample_size_per_arm

      pooled_variance <- pooled_standard_error_2 * pooled_sample_size

      p_values <- one_sample_t_test_p_values(
        estimate = pooled_treatment_effect,
        mu = theta_0,
        standard_deviation = sqrt(pooled_variance),
        n = pooled_sample_size,
        alternative = alternative
      )
      test_decisions <- as.numeric(p_values < alpha)

      power <- mean(test_decisions)
      conf_int_power <- binom.test(sum(test_decisions), length(test_decisions), conf.level = 0.95)$conf.int
    }
  } else if (target_data$summary_measure_likelihood == "binomial") {
    pooled_sample_size_treatment <- target_data$sample_size_per_arm + source_data$sample_size_treatment
    treatment_rate_pooled <- (
      target_data$treatment_rate * target_data$sample_size_per_arm + source_data$treatment_rate * source_data$sample_size_treatment
    ) / (pooled_sample_size_treatment)

    pooled_sample_size_control <- target_data$sample_size_per_arm + source_data$sample_size_control
    control_rate_pooled <- (
      target_data$control_rate * target_data$sample_size_per_arm + source_data$control_rate * source_data$sample_size_control
    ) / (pooled_sample_size_control)

    # Compute Cohen's h
    h <- pwr::ES.h(treatment_rate_pooled, control_rate_pooled)
    power <- pwr::pwr.2p2n.test(
      h = h,
      n1 = pooled_sample_size_treatment,
      n2 = pooled_sample_size_control,
      sig.level = alpha,
      alternative = alternative
    )$power

    conf_int_power <- c(power, power)
  } else {
    stop("This likelihood is not supported.")
  }

  assertions::assert_number(power)
  return(list(power = power, conf_int_power = conf_int_power))
}


#' Draw plausible values of the equivalent type I error
#'
#' @description Draws from the posterior of the type I error implied by the
#'   replicates it was estimated from, rather than from a normal centred on the
#'   estimate whose spread is read off the width of an exact interval.
#'
#' @param alpha A list with the type I error estimate (`mean`), its exact
#'   interval bounds and, when available, its Monte Carlo standard error
#'   (`mcse`) or replicate count (`n_replicates`).
#' @param n_samples Number of draws to return.
#'
#' @return A numeric vector of `n_samples` draws, or `NA` when the replicate
#'   count behind the estimate cannot be recovered.
#'
#' @keywords internal
sample_equivalent_tie <- function(alpha, n_samples) {
  if (alpha$conf_int_upper <= alpha$conf_int_lower) {
    # The type I error carries no uncertainty of its own, so every draw sits at
    # the estimate and the simulated power supplies the only spread.
    return(rep(alpha$mean, n_samples))
  }

  n_replicates <- alpha$n_replicates
  if (is.null(n_replicates) || is.na(n_replicates)) {
    n_replicates <- binomial_replicate_count(
      estimate = alpha$mean,
      mcse = if (is.null(alpha$mcse)) NA_real_ else alpha$mcse,
      conf_int_lower = alpha$conf_int_lower,
      conf_int_upper = alpha$conf_int_upper
    )
  }

  sample_binomial_proportion(n_samples, alpha$mean, n_replicates)
}


#' Compute the frequentist power at an estimated type I error
#'
#' @description Propagates the uncertainty of the equivalent type I error, and
#'   the Monte Carlo error of the power itself, into an interval for the power a
#'   separate frequentist analysis would reach at that type I error.
#'
#'   The reported bounds are quantiles of the resulting posterior for the power,
#'   not a frequentist confidence interval; they are stored under the existing
#'   `conf_int_power` name for continuity with the columns downstream.
#'
#' @param alpha A list describing the estimated type I error: its `mean`, its
#'   exact interval bounds, and its `mcse` or `n_replicates` when available.
#' @param target_data Target data object.
#' @param frequentist_test Type of frequentist test to apply, either z-test or t-test.
#' @param theta_0 Boundary of the null hypothesis space.
#' @param null_space Side of the null space, either left or right.
#' @param simulation_config Simulation configuration.
#' @param case_study Optional case-study name.
#' @param n_replicates Number of Monte Carlo replicates for non-analytical power.
#' @param n_samples Number of draws of the type I error.
#' @param p_values Optional p-values of the separate analysis, already
#'   simulated for this design by [simulate_test_p_values()]. They depend on the
#'   design alone, not on the borrowing method, so a caller pricing many rows of
#'   one design simulates them once and passes them here. `NULL` simulates them.
#'   Ignored when the power has a closed form.
#'
#' @return A list with the power, its interval, and the number of draws used.
#'
#' @export
compute_power_with_tie_ci <- function(alpha,
                                      target_data,
                                      frequentist_test,
                                      theta_0,
                                      null_space,
                                      simulation_config,
                                      case_study = NULL,
                                      n_replicates = 1000,
                                      n_samples = 1000,
                                      p_values = NULL) {
  missing_result <- list(
    power = NA_real_,
    conf_int_power = rep(NA_real_, 2),
    n_effective_samples = 0L
  )

  if (is.na(alpha$mean) || is.na(alpha$conf_int_upper) || is.na(alpha$conf_int_lower)) {
    return(missing_result)
  }

  alpha_samples <- sample_equivalent_tie(alpha, n_samples)
  # A degenerate type I error of zero or one carries no information about the
  # power, so the whole estimate is reported as missing rather than some draws
  # being dropped from an otherwise usable sample.
  if (anyNA(alpha_samples) || any(alpha_samples <= 0) || any(alpha_samples >= 1)) {
    return(missing_result)
  }

  if (uses_analytical_power(target_data)) {
    # Once per result row rather than once per sampled alpha - see
    # assert_target_data_numbers().
    assert_target_data_numbers(target_data)

    # Power is a deterministic function of alpha here, so the type I error is
    # the only source of uncertainty. Every sampled level is priced in one
    # vectorised call - see analytical_power().
    alternative <- alternative_from_null_space(null_space)
    power_samples <- analytical_power(
      alpha_samples, target_data, frequentist_test, theta_0, alternative
    )
  } else {
    # Simulate the trials once and read the rejection count off the same
    # p-values at every sampled alpha, then propagate the Monte Carlo error of
    # each count through its own posterior. The reported interval therefore
    # carries both the type I error uncertainty and the replicate noise, which
    # re-simulating under a fixed seed used to suppress entirely.
    if (is.null(p_values)) {
      alternative <- if (null_space == "left") "greater" else "less"
      p_values <- simulate_test_p_values(
        target_data = target_data,
        frequentist_test = frequentist_test,
        theta_0 = theta_0,
        alternative = alternative,
        simulation_config = simulation_config,
        n_replicates = n_replicates
      )
    }
    # The number of p-values strictly below each sampled alpha, read off the
    # sorted p-values by binary search rather than one full pass per alpha.
    if (is.unsorted(p_values)) {
      p_values <- sort(p_values)
    }
    rejections <- as.numeric(
      findInterval(alpha_samples, p_values, left.open = TRUE)
    )
    power_samples <- stats::rbeta(
      n_samples,
      shape1 = rejections + 0.5,
      shape2 = length(p_values) - rejections + 0.5
    )
  }

  list(
    power = mean(power_samples, na.rm = TRUE),
    conf_int_power = unname(
      stats::quantile(power_samples, probs = c(0.025, 0.975), na.rm = TRUE)
    ),
    n_effective_samples = length(alpha_samples)
  )
}


#' Key under which one design's simulated trials are cached
#'
#' The trials follow from the design, the seed and the number of replicates,
#' so a key naming all three identifies them.
#'
#' @param design_key Keys from [nominal_tie_design_key()].
#' @param simulation_config The simulation configuration, for its seed.
#' @param n_replicates Number of trials simulated.
#'
#' @return A character vector, one key per design key.
#' @noRd
trial_cache_key <- function(design_key, simulation_config, n_replicates) {
  seed <- simulation_config$seed
  paste(design_key,
        if (is.null(seed)) "no seed" else format(seed),
        n_replicates, sep = "\003")
}


#' The cached trials of each design, where the cache holds them
#'
#' @param design_key Keys from [nominal_tie_design_key()].
#' @param simulation_config The simulation configuration.
#' @param n_replicates Number of trials simulated per design.
#' @param trial_cache An environment of cached trials, or `NULL`.
#'
#' @return A list with one entry per design key: its trials, or `NULL`.
#' @noRd
cached_design_trials <- function(design_key, simulation_config, n_replicates, trial_cache) {
  trials <- vector("list", length(design_key))
  if (is.null(trial_cache)) {
    return(trials)
  }

  keys <- trial_cache_key(design_key, simulation_config, n_replicates)
  for (d in which(vapply(keys, exists, logical(1), envir = trial_cache, inherits = FALSE))) {
    trials[[d]] <- get(keys[d], envir = trial_cache)
  }
  trials
}


#' Simulate the trials of one design
#'
#' @param row A results row describing the design.
#' @param simulation_config The simulation configuration.
#' @param n_replicates Number of trials to simulate.
#'
#' @return The design's trials, as [simulated_trials()] returns them.
#' @noRd
design_trials <- function(row, simulation_config, n_replicates) {
  target_data <- load_data(row, type = "target", reload_data_objects = TRUE)
  simulated_trials(target_data, simulation_config, n_replicates)
}


#' The separate analysis's p-values for every design that needs them
#'
#' @description Designs whose power has a closed form get `NULL`. The others
#'   read their trials from `trial_cache` when it holds them, and simulate
#'   them otherwise, on a cluster when there are enough of them to pay for
#'   one; the trials simulated are added to the cache.
#'
#' @param design_rows One results row per design.
#' @param design_keys Their keys from [nominal_tie_design_key()].
#' @param design_target_data Their target data, as `load_data()` returns it.
#' @param frequentist_test The test the p-values are computed for.
#' @param simulation_config The simulation configuration.
#' @param n_replicates Number of trials simulated per design.
#' @param parallelization Whether the caller asked for parallelism.
#' @param trial_cache An environment to read from and add to, or `NULL`.
#' @param cluster A cluster from [new_analysis_cluster()] to run on, or
#'   `NULL` to start one here if one is needed.
#'
#' @return A list with one entry per design: its sorted p-values, or `NULL`.
#' @noRd
equivalent_tie_design_p_values <- function(design_rows,
                                           design_keys,
                                           design_target_data,
                                           frequentist_test,
                                           simulation_config,
                                           n_replicates,
                                           parallelization,
                                           trial_cache = NULL,
                                           cluster = NULL) {
  p_values <- vector("list", nrow(design_rows))

  # which() drops an undetermined answer along with the closed-form designs.
  needs_simulation <- which(!vapply(design_target_data, uses_analytical_power, logical(1)))
  if (length(needs_simulation) == 0) {
    return(p_values)
  }

  trials <- cached_design_trials(
    design_keys[needs_simulation], simulation_config, n_replicates, trial_cache
  )
  to_simulate <- which(vapply(trials, is.null, logical(1)))

  if (length(to_simulate) > 0) {
    # Only the rows being simulated are sent to the workers.
    rows_to_simulate <- lapply(needs_simulation[to_simulate], function(d) {
      design_rows[d, , drop = FALSE]
    })

    if (analysis_uses_cluster(parallelization, length(to_simulate) * n_replicates,
                              min_rows = ANALYSIS_PARALLEL_MIN_TRIALS)) {
      if (is.null(cluster)) {
        cluster <- new_analysis_cluster()
        on.exit(cluster$stop(), add = TRUE)
      }
      cluster$get()

      # The foreach body is evaluated outside the package namespace, where an
      # internal function is not visible; bound here, it travels to the
      # workers as an exported variable, with the namespace as its environment.
      simulate_design <- design_trials
      trials[to_simulate] <- foreach(row = rows_to_simulate, .packages = c("dplyr", "yaml")) %dopar% {
        simulate_design(row, simulation_config, n_replicates)
      }
    } else {
      trials[to_simulate] <- lapply(rows_to_simulate, design_trials,
                                    simulation_config = simulation_config,
                                    n_replicates = n_replicates)
    }

    if (!is.null(trial_cache)) {
      keys <- trial_cache_key(
        design_keys[needs_simulation][to_simulate], simulation_config, n_replicates
      )
      for (j in seq_along(to_simulate)) {
        assign(keys[j], trials[[to_simulate[j]]], envir = trial_cache)
      }
    }
  }

  for (j in seq_along(needs_simulation)) {
    row <- design_rows[needs_simulation[j], , drop = FALSE]
    p_values[[needs_simulation[j]]] <- sort(trial_p_values(
      trials[[j]],
      theta_0 = row$theta_0,
      alternative = alternative_from_null_space(row$null_space)
    ))
  }

  p_values
}


#' Compute the frequentist power at equivalent tie
#'
#' @description This function computes the frequentist power at equivalent tie for a given set of results and analysis configuration.
#'
#' @param results The results data frame.
#' @param analysis_config The analysis configuration.
#' @param n_replicates Number of Monte Carlo replicates the simulated power
#'   estimates are built from, for the case studies analytical_power() cannot
#'   be used for.
#' @param trial_cache Optional environment holding the simulated trials of
#'   each design, filled here and read back by
#'   `frequentist_power_at_nominal_tie()`, whose separate and pooled powers
#'   read the same trials. `NULL` keeps them for this call only.
#' @param cluster Optional shared cluster from `new_analysis_cluster()`, as
#'   [simulation_analysis()] passes it. `NULL` starts one for this call if the
#'   work warrants it.
#'
#' @return The final results data frame with power and frequentist test columns added.
#'
#' @export
frequentist_power_at_equivalent_tie <- function(results, analysis_config, simulation_config, parallelization = FALSE, n_replicates = 1000, trial_cache = NULL, cluster = NULL) {
  if (nrow(results) == 0) {
    stop("The results dataframe is empty.")
  }

  # Remove the tie, mcse_tie, conf_int_tie_lower and conf_int_tie_upper if they exist
  results <- results[, !(
    names(results) %in% c(
      "tie",
      "mcse_tie",
      "conf_int_tie_lower",
      "conf_int_tie_upper",
      "frequentist_power_at_equivalent_tie",
      "frequentist_power_at_equivalent_tie_lower",
      "frequentist_power_at_equivalent_tie_upper",
      "frequentist_test"
    )
  )]

  # Everything that identifies a scenario apart from the treatment effect. The
  # type I error rate is joined back onto the scenarios it was computed for, so
  # a design axis missing here would match one scenario's TIE to several rows.
  matching_columns <- c(
    "method",
    "parameters",
    "control_drift",
    "source_denominator",
    "source_denominator_change_factor",
    "case_study",
    "target_to_source_std_ratio",
    "target_sample_size_per_arm",
    "theta_0",
    "null_space",
    "sampling_approximation",
    "summary_measure_likelihood",
    "source_sample_size_treatment",
    "source_sample_size_control",
    "endpoint",
    "source_standard_error",
    "source_treatment_effect_estimate",
    "equivalent_source_sample_size_per_arm"
  )

  # Results written before the time-to-event design axes existed do not carry
  # them, and such a run only ever had one design, so they join only when the
  # columns are actually there.
  matching_columns <- c(
    matching_columns,
    intersect(time_to_event_design_columns, names(results))
  )

  for (case_study in unique(results$case_study)){
    if (sum(results[results$case_study == case_study, ]['target_treatment_effect'] == results$theta_0) == 0){
      stop("theta_0 not included among the target study treatment effects considered in the simulation study!")
    }
  }

  # Select the results that correspond to TIE computation.
  results_freq_df_tie <- results[results$target_treatment_effect == results$theta_0, c(
    matching_columns,
    c(
      "success_proba",
      "mcse_success_proba",
      "conf_int_success_proba_lower",
      "conf_int_success_proba_upper"
    )
  )]

  # For these results the probability of success corresponds to TIE, so we rename the columns accordingly.
  results_freq_df_tie <- results_freq_df_tie %>%
    dplyr::rename(
      tie = success_proba,
      mcse_tie = mcse_success_proba,
      conf_int_tie_lower = conf_int_success_proba_lower,
      conf_int_tie_upper = conf_int_success_proba_upper
    )

  # We merge the TIE results onto the corresponding scenarios of the results dataframe.
  results <- dplyr::left_join(results, results_freq_df_tie, by = matching_columns)

  frequentist_test <- analysis_config[["frequentist_test"]]

  has_tie <- !is.na(results$tie)
  if (!all(has_tie)) {
    warning(sprintf(
      "TIE is NA for %d of %d rows, so their power at equivalent TIE is left missing.",
      sum(!has_tie), nrow(results)
    ))
  }

  # The trials the separate analysis is read off depend on the design alone,
  # while the results hold one row per design *and* method-parameter
  # combination (56 rows a design in the paper's environment). The target data
  # and the simulated p-values are therefore built once per design, and only
  # the part that depends on the row's own type I error runs per row. The
  # p-values are exactly the ones a per-row simulation would give, because
  # simulate_test_p_values() reseeds from simulation_config$seed every time.
  design_key <- nominal_tie_design_key(
    results[intersect(NOMINAL_TIE_DESIGN_COLUMNS, names(results))]
  )
  design_keys <- unique(design_key[has_tie])
  design_rows <- results[match(design_keys, design_key), , drop = FALSE]
  row_design <- match(design_key, design_keys)

  design_target_data <- lapply(seq_len(nrow(design_rows)), function(d) {
    load_data(design_rows[d, , drop = FALSE],
              type = "target",
              reload_data_objects = TRUE)
  })

  design_p_values <- equivalent_tie_design_p_values(
    design_rows = design_rows,
    design_keys = design_keys,
    design_target_data = design_target_data,
    frequentist_test = frequentist_test,
    simulation_config = simulation_config,
    n_replicates = n_replicates,
    parallelization = parallelization,
    trial_cache = trial_cache,
    cluster = cluster
  )

  # The type I error draws and the posterior of each rejection count are the
  # only random part left. Seeding them once makes the columns reproducible,
  # whatever the cache held and however the p-values were computed.
  set.seed(simulation_config$seed)

  power <- rep(NA_real_, nrow(results))
  power_lower <- rep(NA_real_, nrow(results))
  power_upper <- rep(NA_real_, nrow(results))
  test_column <- rep(NA_character_, nrow(results))

  for (i in which(has_tie)) {
    d <- row_design[i]

    alpha <- list(
      mean = results$tie[i],
      conf_int_lower = results$conf_int_tie_lower[i],
      conf_int_upper = results$conf_int_tie_upper[i],
      mcse = results$mcse_tie[i]
    )

    power_estimation <- compute_power_with_tie_ci(
      alpha = alpha,
      target_data = design_target_data[[d]],
      frequentist_test = frequentist_test,
      theta_0 = results$theta_0[i],
      null_space = results$null_space[i],
      case_study = results$case_study[i],
      simulation_config = simulation_config,
      n_replicates = n_replicates,
      p_values = design_p_values[[d]]
    )

    power[i] <- power_estimation$power
    power_lower[i] <- power_estimation$conf_int_power[1]
    power_upper[i] <- power_estimation$conf_int_power[2]
    test_column[i] <- frequentist_test
  }

  results$frequentist_power_at_equivalent_tie <- power
  results$frequentist_power_at_equivalent_tie_lower <- power_lower
  results$frequentist_power_at_equivalent_tie_upper <- power_upper
  results$frequentist_test <- test_column

  return(results)
}


#' Power of the separate and pooling baselines for one scenario row
#'
#' @description Neither baseline depends on the borrowing method, only on the
#'   design, so both branches of [frequentist_power_at_nominal_tie()] need
#'   exactly this computation. A worker cannot see a copy of it that lives
#'   inside the loop body, so it lives here rather than being written twice.
#'
#' @param row One row of the results data frame.
#' @param nominal_tie The type I error rate the power is evaluated at.
#' @param frequentist_test The test the power is computed for.
#' @param simulation_config The simulation configuration.
#' @param n_replicates Number of Monte Carlo replicates the simulated power
#'   estimates are built from, for the case studies analytical_power() cannot
#'   be used for.
#' @param trials Optional trials already simulated for this design, as
#'   [simulated_trials()] returns them. `NULL` simulates them if the powers
#'   need them.
#'
#' @return A named list holding the six power columns for that row.
#' @noRd
nominal_tie_power_row <- function(row,
                                  nominal_tie,
                                  frequentist_test,
                                  simulation_config,
                                  n_replicates,
                                  trials = NULL) {
  target_data <- load_data(row, type = "target", reload_data_objects = TRUE)
  source_data <- load_data(row, type = "source", reload_data_objects = TRUE)

  assert_target_data_numbers(target_data)

  # Where both powers are simulated they read the same trials - each would
  # otherwise reseed and generate them again - so they are generated once
  # here, unless the caller already holds them.
  simulated <- identical(target_data$summary_measure_likelihood, "normal") &&
    isFALSE(uses_analytical_power(target_data)) &&
    identical(frequentist_test, "t-test")
  if (!simulated) {
    trials <- NULL
  } else if (is.null(trials)) {
    trials <- simulated_trials(target_data, simulation_config, n_replicates)
  }
  p_values <- if (is.null(trials)) {
    NULL
  } else {
    trial_p_values(trials, row$theta_0, alternative_from_null_space(row$null_space))
  }

  separate <- compute_freq_power(
    alpha = nominal_tie,
    target_data = target_data,
    frequentist_test = frequentist_test,
    theta_0 = row$theta_0,
    null_space = row$null_space,
    case_study = row$case_study,
    simulation_config = simulation_config,
    n_replicates = n_replicates,
    p_values = p_values
  )

  pooling <- compute_freq_power_pooling(
    alpha = nominal_tie,
    target_data = target_data,
    source_data = source_data,
    frequentist_test = frequentist_test,
    theta_0 = row$theta_0,
    null_space = row$null_space,
    case_study = row$case_study,
    simulation_config = simulation_config,
    n_replicates = n_replicates,
    trials = trials
  )

  # The bounds are unnamed so that binding the rows together downstream gives
  # plain numeric columns, whichever of the two intervals came back.
  list(
    nominal_frequentist_power_separate = separate$power,
    nominal_frequentist_power_separate_lower = unname(separate$conf_int_power[1]),
    nominal_frequentist_power_separate_upper = unname(separate$conf_int_power[2]),
    nominal_frequentist_power_pooling = pooling$power,
    nominal_frequentist_power_pooling_lower = unname(pooling$conf_int_power[1]),
    nominal_frequentist_power_pooling_upper = unname(pooling$conf_int_power[2])
  )
}

#' The columns that identify one baseline computation
#'
#' Neither baseline depends on the borrowing method, so rows that agree on
#' every column here yield the same two numbers however they were analysed.
#'
#' This list must stay a *superset* of what [nominal_tie_power_row()] reads.
#' An extra column only splits a group that could have been shared, which
#' costs a little time; a missing one merges rows that genuinely differ, which
#' is silently wrong. It is therefore every design column of the results
#' frame, not only the six `load_data()` happens to read today.
#' @noRd
NOMINAL_TIE_DESIGN_COLUMNS <- c(
  "case_study", "theta_0", "null_space",
  "target_sample_size_per_arm", "target_treatment_effect",
  "target_standard_deviation", "target_to_source_std_ratio",
  "target_treatment_rate", "target_control_rate",
  "drift", "treatment_drift", "control_drift",
  "source_denominator", "source_denominator_change_factor",
  "source_treatment_effect_estimate", "source_standard_error",
  "source_sample_size_control", "source_sample_size_treatment",
  "source_treatment_rate", "source_control_rate",
  "equivalent_source_sample_size_per_arm",
  "summary_measure_likelihood", "endpoint", "sampling_approximation",
  "dropout_probability", "event_time_distribution", "treatment_delay"
)


#' Group rows of a results frame by the design they describe
#'
#' @param design The design columns of the results frame.
#'
#' @return A character vector, one entry per row, equal exactly for rows
#'   describing the same design.
#' @noRd
nominal_tie_design_key <- function(design) {
  if (length(design) == 0) {
    return(rep("", nrow(design)))
  }

  # A missing entry is given a token no value of its own can take, so that it
  # never collides with a column that literally holds the string "NA".
  tokens <- lapply(design, function(column) {
    column <- as.character(column)
    ifelse(is.na(column), "\001missing\001", column)
  })

  do.call(paste, c(tokens, list(sep = "\002")))
}


#' Compute the frequentist power at the nominal type I error rate
#'
#' @description Computes the power of the separate and the pooled analysis at
#'   the nominal type I error rate, which the plots use as the two baselines
#'   every borrowing method is read against.
#'
#'   Both baselines are a property of the design alone, while the results
#'   frame holds one row per design *and* method-parameter combination: the
#'   paper's environment repeats each of its 330 designs 56 times. They are
#'   therefore computed once per design and copied to the rows that share it.
#'   That is exact rather than an approximation, because
#'   `simulate_test_p_values()` reseeds from `simulation_config$seed` on every
#'   call, so the repeats were identical to the last bit anyway.
#'
#' @param results The results data frame.
#' @param analysis_config The analysis configuration.
#' @param simulation_config The simulation configuration.
#' @param parallelization Whether the caller asked for parallelism, as
#'   [analysis_runs_in_parallel()] resolves it. A design costs seconds here -
#'   two power computations, either of which may be a simulation - so a run
#'   with many of them is worth spreading over a cluster.
#' @param n_replicates Number of Monte Carlo replicates the simulated power
#'   estimates are built from, for the case studies analytical_power() cannot
#'   be used for.
#' @param trial_cache Optional environment of simulated trials left by
#'   [frequentist_power_at_equivalent_tie()]. Both baselines read the same
#'   trials, so a design found there is not simulated again.
#' @param cluster Optional shared cluster from `new_analysis_cluster()`.
#'   `NULL` starts one for this call if the work warrants it.
#'
#' @return The results data frame with the six baseline power columns added.
frequentist_power_at_nominal_tie <- function(results, analysis_config, simulation_config, parallelization = FALSE, n_replicates = 1000, trial_cache = NULL, cluster = NULL) {
  if (nrow(results) == 0) {
    stop("The results dataframe is empty.")
  }

  results <- results[, !(
    names(results) %in% c(
     "nominal_frequentist_power_separate",
     "nominal_frequentist_power_separate_lower",
     "nominal_frequentist_power_separate_upper",
     "nominal_frequentist_power_pooling",
     "nominal_frequentist_power_pooling_lower",
     "nominal_frequentist_power_pooling_upper"
    )
  )]

  nominal_tie <- analysis_config[["nominal_tie"]]
  frequentist_test <- analysis_config[["frequentist_test"]]

  # One row per distinct design, and the index that puts each computed value
  # back on every row sharing it.
  design_key <- nominal_tie_design_key(
    results[intersect(NOMINAL_TIE_DESIGN_COLUMNS, names(results))]
  )
  representatives <- !duplicated(design_key)
  design_rows <- results[representatives, , drop = FALSE]
  design_index <- match(design_key, design_key[representatives])

  # The trials the equivalent-TIE step already simulated. A design missing
  # from the cache gets NULL and simulates its own.
  cached_trials <- cached_design_trials(
    design_key[representatives], simulation_config, n_replicates, trial_cache
  )

  # Only the distinct designs are handed to the workers, rather than the whole
  # results frame: on the paper's environment that is 330 rows to serialise
  # instead of 18,480, each carrying its parameters as JSON.
  compute_design <- function(i, trials = NULL) {
    nominal_tie_power_row(
      row = design_rows[i, ],
      nominal_tie = nominal_tie,
      frequentist_test = frequentist_test,
      simulation_config = simulation_config,
      n_replicates = n_replicates,
      trials = trials
    )
  }

  # A design whose trials are cached costs milliseconds - two tests on
  # trials already drawn - so those are computed here.
  computed_list <- vector("list", nrow(design_rows))
  is_cached <- !vapply(cached_trials, is.null, logical(1))
  for (i in which(is_cached)) {
    computed_list[[i]] <- compute_design(i, cached_trials[[i]])
  }
  # Dropped before compute_design() goes to the workers: foreach ships the
  # environment it was defined in, which would carry every cached trial to
  # each of them.
  cached_trials <- NULL
  to_compute <- which(!is_cached)

  if (length(to_compute) > 0 &&
      analysis_uses_cluster(parallelization, length(to_compute))) {
    if (is.null(cluster)) {
      cluster <- new_analysis_cluster()
      on.exit(cluster$stop(), add = TRUE)
    }
    cluster$get()

    computed_list[to_compute] <- foreach(i = to_compute, .packages = c("dplyr", "yaml", "pwr", "BSDA")) %dopar% {
      compute_design(i)
    }
  } else if (length(to_compute) > 0) {
    # One progress bar for the whole loop. Building it inside the loop, as
    # this did, restarts it on every step, and what gets printed is then
    # thousands of bars that never pass the first few percent.
    pb <- txtProgressBar(min = 0, max = length(to_compute), style = 3)
    on.exit(close(pb), add = TRUE)

    for (k in seq_along(to_compute)) {
      computed_list[[to_compute[k]]] <- compute_design(to_compute[k])

      # Update progress bar
      setTxtProgressBar(pb, k)
    }
  }

  # Assigned by name rather than cbind()ed on, so that a stale column is
  # replaced instead of being shadowed by a second copy of itself.
  computed <- dplyr::bind_rows(computed_list)
  for (column in names(computed)) {
    results[[column]] <- as.numeric(computed[[column]])[design_index]
  }

  return(results)
}
