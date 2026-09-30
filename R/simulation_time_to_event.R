# Data generation and analysis for the time-to-event target trial.
#
# The design is the modified fixed-calendar variant of TERIKIDS: patients enter
# over an accrual window, every patient may be followed for at most L, and the
# database closes F after the end of recruitment. Each simulated trial is
# analysed with a Cox proportional-hazards model, whose estimate and standard
# error are the summary measure passed to the borrowing methods.


# Calibrate the Weibull control-arm scale to a relapse-free probability.
#
# The Weibull sensitivity analysis is anchored on the aggregate relapse-free
# probability at the end of follow-up rather than on a rate, so the control
# scale is whatever reproduces S_c(L): b_c = L / [-log S_c(L)]^(1/q).
weibull_control_scale <- function(max_follow_up_time,
                                  shape,
                                  relapse_free_probability) {
  max_follow_up_time / (-log(relapse_free_probability))^(1 / shape)
}


# Arm-specific event-time parameters for the target trial.
#
# Control-arm heterogeneity enters as a hazard multiplier, exp(kappa), and the
# treatment effect as a second one, exp(theta_T). The exponential rates are
# therefore scaled directly. Under a Weibull hazard (q/b^q)t^(q-1), multiplying
# the hazard by exp(x) divides the scale by exp(x/q), which is why the Weibull
# scales carry the shape in the denominator and the opposite sign.
#
# The two distributions are deliberately not nested: the exponential arm is
# calibrated to the source placebo rate, the Weibull arm to the aggregate
# relapse-free probability, so they do not coincide at kappa = 0.
time_to_event_arm_parameters <- function(event_time_distribution,
                                         control_rate,
                                         treatment_rate,
                                         treatment_effect,
                                         control_drift,
                                         weibull_shape,
                                         weibull_scale) {
  if (event_time_distribution == "exponential") {
    return(list(control = control_rate, treatment = treatment_rate))
  }

  if (event_time_distribution != "weibull") {
    stop(
      paste0(
        "Unknown event time distribution: ", event_time_distribution,
        ". Expected \"exponential\" or \"weibull\"."
      ),
      call. = FALSE
    )
  }

  control_scale <- weibull_scale * exp(-control_drift / weibull_shape)
  list(
    control = control_scale,
    treatment = control_scale * exp(-treatment_effect / weibull_shape)
  )
}


# Loss-to-follow-up rate implied by a probability of dropping out over L.
time_to_event_dropout_rate <- function(dropout_probability, max_follow_up_time) {
  if (dropout_probability <= 0) {
    return(0)
  }
  -log1p(-dropout_probability) / max_follow_up_time
}


# Probability that a patient contributes an observed event.
#
# T, D and the administrative censoring time C are independent, so
# P(Delta = 1) = integral of f_T(t) S_D(t) S_C(t) dt. With entry times uniform
# on (0, A) and C = min(L, A + F - R), the administrative survivor function is
# S_C(t) = min(1, (A + F - t)/A) on [0, L) and zero afterwards. It has a kink
# where entry stops buying full follow-up, so the integral is split there.
#
# With a delay, `parameter` is the control one and the arm is the delayed
# treatment arm of time_to_event_delayed_arms(): control hazard until `delay`,
# multiplied by exp(late_log_hr) afterwards.
time_to_event_event_probability <- function(parameter,
                                            event_time_distribution,
                                            weibull_shape,
                                            accrual_period,
                                            final_follow_up,
                                            max_follow_up_time,
                                            dropout_rate,
                                            delay = 0,
                                            late_log_hr = 0) {
  closing_time <- accrual_period + final_follow_up

  density <- if (delay > 0) {
    arms <- time_to_event_delayed_arms(
      parameter, event_time_distribution, weibull_shape, delay, late_log_hr
    )
    function(t) arms$treatment_hazard(t) * arms$treatment_survival(t)
  } else {
    function(t) {
      if (event_time_distribution == "exponential") {
        stats::dexp(t, rate = parameter)
      } else {
        stats::dweibull(t, shape = weibull_shape, scale = parameter)
      }
    }
  }

  integrand <- function(t) {
    administrative <- pmin(1, pmax(0, (closing_time - t) / accrual_period))
    density(t) * exp(-dropout_rate * t) * administrative
  }

  kink <- min(max(closing_time - max_follow_up_time, 0), max_follow_up_time)
  breaks <- sort(unique(c(0, kink, if (delay > 0) min(delay, max_follow_up_time),
                          max_follow_up_time)))

  sum(vapply(seq_len(length(breaks) - 1L), function(i) {
    stats::integrate(integrand, breaks[i], breaks[i + 1L])$value
  }, numeric(1)))
}


# Design-level standard deviation of the log hazard ratio.
#
# Expressed per patient, as for the other endpoints: the standard error of the
# estimate is this quantity divided by the square root of the per-arm sample
# size. It is driven by the expected number of observed events in each arm.
time_to_event_standard_deviation <- function(control_parameter,
                                             treatment_parameter,
                                             event_time_distribution,
                                             weibull_shape,
                                             accrual_period,
                                             final_follow_up,
                                             max_follow_up_time,
                                             dropout_rate,
                                             delay = 0,
                                             late_log_hr = 0) {
  event_probability <- function(parameter, delay = 0, late_log_hr = 0) {
    time_to_event_event_probability(
      parameter = parameter,
      event_time_distribution = event_time_distribution,
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = dropout_rate,
      delay = delay,
      late_log_hr = late_log_hr
    )
  }

  # Under a delayed effect the treatment arm is the control one with its hazard
  # multiplied after the delay; 1/d0 + 1/d1 is then only an approximation to
  # the variance of the Cox estimate, as the hazard ratio is not constant.
  treatment_events <- if (delay > 0) {
    event_probability(control_parameter, delay, late_log_hr)
  } else {
    event_probability(treatment_parameter)
  }
  sqrt(1 / event_probability(control_parameter) + 1 / treatment_events)
}


#' Expected number of observed events in each arm of the target trial
#'
#' @description The number of events is what loss to follow-up, the event time
#'   distribution and control-arm heterogeneity change in the time-to-event
#'   trial, and what the precision of its log hazard ratio rests on. Uses the
#'   same arm parameters and censoring as the data generator.
#'
#' @param case_study_config A time-to-event case study configuration.
#' @param sample_size_per_arm Number of patients in each arm.
#' @param control_drift Control-arm heterogeneity, kappa, on the log scale.
#' @param dropout_probability Probability of loss to follow-up over the
#'   maximum follow-up time.
#' @param event_time_distribution Either "exponential" or "weibull".
#' @param treatment_effect Target log hazard ratio; the source estimate by
#'   default, i.e. a consistent treatment effect. Under a delayed effect, the
#'   Cox model's large-sample limit (see [time_to_event_delayed_log_hr()]).
#' @param treatment_delay Time before the treatment effect starts, in years.
#'
#' @return A named numeric vector with elements `control` and `treatment`.
#'
#' @export
time_to_event_expected_events <- function(case_study_config,
                                          sample_size_per_arm,
                                          control_drift = 0,
                                          dropout_probability = 0,
                                          event_time_distribution = "exponential",
                                          treatment_effect = case_study_config$source$treatment_effect,
                                          treatment_delay = 0) {
  target <- case_study_config$target
  control_rate <- case_study_config$source$control_rate * exp(control_drift)

  weibull_scale <- NULL
  if (event_time_distribution == "weibull") {
    weibull_scale <- weibull_control_scale(
      max_follow_up_time = target$max_follow_up_time,
      shape = target$weibull_shape,
      relapse_free_probability = target$weibull_relapse_free_probability
    )
  }

  parameters <- time_to_event_arm_parameters(
    event_time_distribution = event_time_distribution,
    control_rate = control_rate,
    treatment_rate = control_rate * exp(treatment_effect),
    treatment_effect = treatment_effect,
    control_drift = control_drift,
    weibull_shape = target$weibull_shape,
    weibull_scale = weibull_scale
  )
  dropout_rate <- time_to_event_dropout_rate(
    dropout_probability, target$max_follow_up_time
  )

  late_log_hr <- time_to_event_delayed_log_hr(
    log_hr = treatment_effect,
    control_parameter = parameters$control,
    event_time_distribution = event_time_distribution,
    weibull_shape = target$weibull_shape,
    delay = treatment_delay,
    accrual_period = target$accrual_period,
    final_follow_up = target$final_follow_up,
    max_follow_up_time = target$max_follow_up_time,
    dropout_rate = dropout_rate
  )

  events <- function(parameter, delay = 0) {
    sample_size_per_arm * time_to_event_event_probability(
      parameter = parameter,
      event_time_distribution = event_time_distribution,
      weibull_shape = target$weibull_shape,
      accrual_period = target$accrual_period,
      final_follow_up = target$final_follow_up,
      max_follow_up_time = target$max_follow_up_time,
      dropout_rate = dropout_rate,
      delay = delay,
      late_log_hr = late_log_hr
    )
  }

  c(
    control = events(parameters$control),
    treatment = if (treatment_delay > 0) {
      events(parameters$control, treatment_delay)
    } else {
      events(parameters$treatment)
    }
  )
}


# ---- Delayed treatment effect ------------------------------------------------
#
# The non-proportional-hazards sensitivity analysis. The treatment arm shares the
# control hazard for the first `delay` years and is multiplied by exp(beta)
# afterwards, so the hazard ratio is 1 and then exp(beta): a treatment whose
# effect takes time to set in. The Cox model then estimates an average of the
# two, weighted by when the events fall, and it is that average - the Cox
# model's large-sample limit under the trial's own censoring - that plays the
# part of the scenario's treatment effect. beta is chosen so that the limit
# equals it; see time_to_event_delayed_log_hr().


# Cumulative control hazard and its inverse.
time_to_event_control_cumulative_hazard <- function(t,
                                                    parameter,
                                                    event_time_distribution,
                                                    weibull_shape) {
  if (event_time_distribution == "exponential") {
    parameter * t
  } else {
    (t / parameter)^weibull_shape
  }
}

time_to_event_control_inverse_cumulative_hazard <- function(x,
                                                            parameter,
                                                            event_time_distribution,
                                                            weibull_shape) {
  if (event_time_distribution == "exponential") {
    x / parameter
  } else {
    parameter * x^(1 / weibull_shape)
  }
}


# Hazard and survivor functions of both arms under a delayed treatment effect.
#
# With delay = 0 the treatment arm is the proportional-hazards one, hazard
# multiplied by exp(late_log_hr) throughout.
time_to_event_delayed_arms <- function(control_parameter,
                                       event_time_distribution,
                                       weibull_shape,
                                       delay,
                                       late_log_hr) {
  cumulative <- function(t) {
    time_to_event_control_cumulative_hazard(
      t, control_parameter, event_time_distribution, weibull_shape
    )
  }
  hazard <- function(t) {
    if (event_time_distribution == "exponential") {
      rep(control_parameter, length(t))
    } else {
      (weibull_shape / control_parameter) *
        (t / control_parameter)^(weibull_shape - 1)
    }
  }
  at_delay <- cumulative(delay)
  multiplier <- exp(late_log_hr)

  list(
    control_hazard = hazard,
    control_survival = function(t) exp(-cumulative(t)),
    treatment_hazard = function(t) hazard(t) * ifelse(t < delay, 1, multiplier),
    treatment_survival = function(t) {
      exp(-ifelse(t < delay, cumulative(t),
                  at_delay + multiplier * (cumulative(t) - at_delay)))
    }
  )
}


# Survivor function of the censoring: loss to follow-up, and the administrative
# censoring of the fixed-calendar design (see time_to_event_event_probability()).
time_to_event_censoring_survival <- function(accrual_period,
                                             final_follow_up,
                                             dropout_rate) {
  closing_time <- accrual_period + final_follow_up
  function(t) {
    exp(-dropout_rate * t) *
      pmin(1, pmax(0, (closing_time - t) / accrual_period))
  }
}


# Integrate over [0, L), split where the integrand has a kink: at the end of the
# delay, and where entry stops buying full follow-up.
time_to_event_integrate <- function(integrand,
                                    accrual_period,
                                    final_follow_up,
                                    max_follow_up_time,
                                    delay = 0) {
  kink <- min(max(accrual_period + final_follow_up - max_follow_up_time, 0),
              max_follow_up_time)
  breaks <- sort(unique(c(0, kink, min(delay, max_follow_up_time), max_follow_up_time)))
  sum(vapply(seq_len(length(breaks) - 1L), function(i) {
    stats::integrate(integrand, breaks[i], breaks[i + 1L],
                     rel.tol = 1e-8)$value
  }, numeric(1)))
}


# Large-sample limit of the Cox estimate under a delayed treatment effect.
#
# With equal arms, the expected partial-likelihood score is
#   U(b) = integral of G S0 S1 (h1 - exp(b) h0) / (S0 + exp(b) S1) dt
# over the follow-up window (Struthers and Kalbfleisch, 1986), where G is the
# censoring survivor function. Its root is the log hazard ratio the Cox model
# converges to, a weighted average of 0 before the delay and late_log_hr after.
time_to_event_cox_limit <- function(control_parameter,
                                    event_time_distribution,
                                    weibull_shape,
                                    delay,
                                    late_log_hr,
                                    accrual_period,
                                    final_follow_up,
                                    max_follow_up_time,
                                    dropout_rate) {
  if (late_log_hr == 0) {
    return(0)
  }
  arms <- time_to_event_delayed_arms(
    control_parameter, event_time_distribution, weibull_shape, delay, late_log_hr
  )
  censoring <- time_to_event_censoring_survival(
    accrual_period, final_follow_up, dropout_rate
  )

  score <- function(b) {
    integrand <- function(t) {
      s0 <- arms$control_survival(t)
      s1 <- arms$treatment_survival(t)
      censoring(t) * s0 * s1 *
        (arms$treatment_hazard(t) - exp(b) * arms$control_hazard(t)) /
        (s0 + exp(b) * s1)
    }
    time_to_event_integrate(integrand, accrual_period, final_follow_up,
                            max_follow_up_time, delay)
  }

  # The limit lies between 0 and late_log_hr, and the score is decreasing in b.
  stats::uniroot(score, sort(c(0, late_log_hr)), tol = 1e-10)$root
}


#' Post-delay log hazard ratio that gives a target Cox estimand
#'
#' @description Under a delayed treatment effect the hazard ratio is 1 for the
#'   first `delay` years and exp(beta) afterwards. The Cox model fitted to such a
#'   trial converges to an average of the two, weighted by when the events fall
#'   under the trial's censoring. This returns the beta for which that average
#'   equals `log_hr`, so that the delayed-effect scenario keeps the treatment
#'   effect - and hence the drift, the bias and the null hypothesis - of the
#'   proportional-hazards scenario it replaces. Under no effect beta is 0 and
#'   the two arms coincide.
#'
#' @param log_hr The Cox estimand, the scenario's target treatment effect.
#' @param control_parameter Control rate (exponential) or scale (Weibull).
#' @param event_time_distribution Either "exponential" or "weibull".
#' @param weibull_shape The Weibull shape, unused for exponential times.
#' @param delay Time before the treatment effect starts, in years.
#' @param accrual_period,final_follow_up,max_follow_up_time The calendar design.
#' @param dropout_rate Rate of loss to follow-up.
#'
#' @return The post-delay log hazard ratio, beta.
#'
#' @export
time_to_event_delayed_log_hr <- function(log_hr,
                                         control_parameter,
                                         event_time_distribution,
                                         weibull_shape,
                                         delay,
                                         accrual_period,
                                         final_follow_up,
                                         max_follow_up_time,
                                         dropout_rate) {
  if (delay <= 0 || log_hr == 0) {
    return(log_hr)
  }
  if (delay >= max_follow_up_time) {
    stop(paste0(
      "A treatment delay of ", delay, " years leaves no follow-up after the",
      " effect starts (maximum follow-up ", max_follow_up_time, " years)."
    ), call. = FALSE)
  }
  limit <- function(beta) {
    time_to_event_cox_limit(
      control_parameter, event_time_distribution, weibull_shape, delay, beta,
      accrual_period, final_follow_up, max_follow_up_time, dropout_rate
    ) - log_hr
  }
  # The delay dilutes the effect, so beta is further from 0 than log_hr.
  stats::uniroot(limit, sort(c(log_hr, 4 * log_hr)), extendInt = "yes",
                 tol = 1e-8)$root
}


# Number of replicates to hold in memory at once.
#
# The Cox solver works on matrices with one row per observation and one column
# per replicate, so the replicate count is chunked to keep each of those a
# manageable size.
time_to_event_chunk_size <- function(n_replicates,
                                     n_observations,
                                     max_cells = 2e6) {
  chunk <- as.integer(max_cells %/% max(1L, n_observations))
  max(1L, min(as.integer(n_replicates), chunk))
}


# Simulate one arm of the trial, for every replicate at once.
#
# Returns the observed follow-up time X = min(T, D, C) and the event indicator
# Delta = 1{T <= D, T <= C}, each as a matrix with one row per replicate.
sample_time_to_event_arm <- function(n_subjects,
                                     n_replicates,
                                     parameter,
                                     event_time_distribution,
                                     weibull_shape,
                                     accrual_period,
                                     final_follow_up,
                                     max_follow_up_time,
                                     dropout_rate,
                                     delay = 0,
                                     late_log_hr = 0) {
  n <- n_replicates * n_subjects

  entry <- stats::runif(n, min = 0, max = accrual_period)
  administrative <- pmin(max_follow_up_time,
                         accrual_period + final_follow_up - entry)

  event_time <- if (delay > 0) {
    # A delayed effect: `parameter` is the control one, and the hazard is
    # multiplied by exp(late_log_hr) after `delay`. Invert the piecewise
    # cumulative hazard at a unit exponential draw.
    at_delay <- time_to_event_control_cumulative_hazard(
      delay, parameter, event_time_distribution, weibull_shape
    )
    unit <- stats::rexp(n)
    control_scale <- ifelse(unit <= at_delay, unit,
                            at_delay + (unit - at_delay) * exp(-late_log_hr))
    time_to_event_control_inverse_cumulative_hazard(
      control_scale, parameter, event_time_distribution, weibull_shape
    )
  } else if (event_time_distribution == "exponential") {
    stats::rexp(n, rate = parameter)
  } else {
    stats::rweibull(n, shape = weibull_shape, scale = parameter)
  }

  # A scalar Inf recycles through pmin and the comparisons below, so the
  # no-dropout case costs no allocation.
  dropout_time <- if (dropout_rate > 0) stats::rexp(n, rate = dropout_rate) else Inf

  list(
    time = matrix(pmin(event_time, dropout_time, administrative),
                  nrow = n_replicates),
    event = matrix(as.numeric(event_time <= dropout_time &
                                event_time <= administrative),
                   nrow = n_replicates)
  )
}


# Fit a two-sample Cox proportional-hazards model to every replicate at once.
#
# With a single binary covariate the risk set at an event time is described
# entirely by the numbers still at risk in each arm, (n0, n1), so the Breslow
# log partial likelihood reduces to
#
#   l(beta) = beta * d1 - sum over events of log(n0 + n1 * exp(beta))
#
# with score and observed information
#
#   U(beta) = d1 - sum n1 e^b / (n0 + n1 e^b)
#   I(beta) = sum n0 n1 e^b / (n0 + n1 e^b)^2.
#
# Event times are continuous, so ties happen with probability zero and this
# agrees with survival::coxph() to machine precision under either tie handling;
# test-simulation_time_to_event.R asserts that rather than assuming it.
#
# `time` and `event` are matrices with one row per replicate and one column per
# patient; `arm` is the 0/1 treatment indicator for those columns. The estimate
# is NA for replicates where the maximum likelihood estimate does not exist,
# which is the convention the downstream methods expect.
fit_two_sample_cox <- function(time,
                               event,
                               arm,
                               max_iterations = 40L,
                               tolerance = 1e-10,
                               bound = 25) {
  n_replicates <- nrow(time)
  n_observations <- ncol(time)
  n_treated <- sum(arm)

  replicate_id <- rep(seq_len(n_replicates), times = n_observations)
  event_vector <- as.numeric(event)

  # Sort within each replicate by time, placing events before censored
  # observations that tie with them so that positions k..N are exactly the risk
  # set of the observation at position k.
  ordering <- order(replicate_id,
                    as.numeric(time),
                    event_vector == 0,
                    method = "radix")

  treated <- matrix(rep(as.numeric(arm), each = n_replicates)[ordering],
                    nrow = n_observations)
  events <- matrix(event_vector[ordering], nrow = n_observations)

  # Within-column cumulative counts of treated patients, obtained from a single
  # cumulative sum over the column-major matrix minus each column's offset.
  flat <- cumsum(as.numeric(treated))
  column_end <- flat[seq_len(n_replicates) * n_observations]
  column_start <- c(0, column_end[-n_replicates])
  within <- matrix(flat - rep(column_start, each = n_observations),
                   nrow = n_observations)

  # At sorted position k the risk set is positions k..N, so its size is N-k+1
  # and the treated patients still in it are those not yet consumed.
  at_risk_treated <- n_treated - within + treated
  at_risk_control <- (n_observations:1) - at_risk_treated

  events_treated <- colSums(events * treated)
  events_control <- colSums(events) - events_treated

  # The expected treated share of the risk set, n1 e^b / (n0 + n1 e^b), carries
  # both quantities: the score is d1 minus its total over the event times, and
  # because n0 = (n0 + n1 e^b) - n1 e^b the information term n0 n1 e^b / (.)^2
  # is exactly its Bernoulli variance p(1 - p).
  score_and_information <- function(beta) {
    weighted <- at_risk_treated * rep(exp(beta), each = n_observations)
    share <- weighted / (at_risk_control + weighted)
    weight <- events * share
    list(
      score = events_treated - colSums(weight),
      information = colSums(weight - weight * share)
    )
  }

  beta <- numeric(n_replicates)
  for (iteration in seq_len(max_iterations)) {
    current <- score_and_information(beta)
    step <- current$score / current$information
    step[!is.finite(step)] <- 0
    beta <- pmax(pmin(beta + step, bound), -bound)
    if (max(abs(step)) < tolerance) {
      break
    }
  }

  information <- score_and_information(beta)$information

  estimable <- events_treated > 0 & events_control > 0 &
    is.finite(beta) & abs(beta) < bound &
    is.finite(information) & information > 0

  list(
    estimate = ifelse(estimable, beta, NA_real_),
    standard_error = ifelse(estimable, 1 / sqrt(information), NA_real_)
  )
}


# Simulate and analyse the target trial for every replicate.
#
# Returns the data frame of summary measures that TimeToEventTargetData$generate()
# hands to the borrowing methods.
simulate_time_to_event_trial <- function(n_replicates,
                                         sample_size_per_arm,
                                         control_parameter,
                                         treatment_parameter,
                                         event_time_distribution,
                                         weibull_shape,
                                         accrual_period,
                                         final_follow_up,
                                         max_follow_up_time,
                                         dropout_rate,
                                         treatment_delay = 0,
                                         late_log_hr = 0) {
  n_observations <- 2L * as.integer(sample_size_per_arm)
  arm <- rep(c(0, 1), each = sample_size_per_arm)

  chunk_size <- time_to_event_chunk_size(n_replicates, n_observations)
  starts <- seq(1L, as.integer(n_replicates), by = chunk_size)

  estimate <- numeric(n_replicates)
  standard_error <- numeric(n_replicates)

  for (start in starts) {
    size <- min(chunk_size, as.integer(n_replicates) - start + 1L)

    control <- sample_time_to_event_arm(
      n_subjects = sample_size_per_arm,
      n_replicates = size,
      parameter = control_parameter,
      event_time_distribution = event_time_distribution,
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = dropout_rate
    )
    # Under a delayed effect the treatment arm is drawn from the control
    # hazard, multiplied by exp(late_log_hr) once the delay has passed.
    treatment <- sample_time_to_event_arm(
      n_subjects = sample_size_per_arm,
      n_replicates = size,
      parameter = if (treatment_delay > 0) control_parameter else treatment_parameter,
      event_time_distribution = event_time_distribution,
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = dropout_rate,
      delay = treatment_delay,
      late_log_hr = late_log_hr
    )

    fit <- fit_two_sample_cox(
      time = cbind(control$time, treatment$time),
      event = cbind(control$event, treatment$event),
      arm = arm
    )

    rows <- start:(start + size - 1L)
    estimate[rows] <- fit$estimate
    standard_error[rows] <- fit$standard_error
  }

  data.frame(
    treatment_effect_estimate = estimate,
    treatment_effect_standard_error = standard_error,
    sample_size_per_arm = sample_size_per_arm,
    standard_deviation = standard_error * sqrt(sample_size_per_arm)
  )
}
