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
time_to_event_event_probability <- function(parameter,
                                            event_time_distribution,
                                            weibull_shape,
                                            accrual_period,
                                            final_follow_up,
                                            max_follow_up_time,
                                            dropout_rate) {
  closing_time <- accrual_period + final_follow_up

  density <- function(t) {
    if (event_time_distribution == "exponential") {
      stats::dexp(t, rate = parameter)
    } else {
      stats::dweibull(t, shape = weibull_shape, scale = parameter)
    }
  }

  integrand <- function(t) {
    administrative <- pmin(1, pmax(0, (closing_time - t) / accrual_period))
    density(t) * exp(-dropout_rate * t) * administrative
  }

  kink <- min(max(closing_time - max_follow_up_time, 0), max_follow_up_time)
  breaks <- unique(c(0, kink, max_follow_up_time))

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
                                             dropout_rate) {
  event_probability <- function(parameter) {
    time_to_event_event_probability(
      parameter = parameter,
      event_time_distribution = event_time_distribution,
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = dropout_rate
    )
  }

  sqrt(1 / event_probability(control_parameter) +
         1 / event_probability(treatment_parameter))
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
                                     dropout_rate) {
  n <- n_replicates * n_subjects

  entry <- stats::runif(n, min = 0, max = accrual_period)
  administrative <- pmin(max_follow_up_time,
                         accrual_period + final_follow_up - entry)

  event_time <- if (event_time_distribution == "exponential") {
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
                                         dropout_rate) {
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
    treatment <- sample_time_to_event_arm(
      n_subjects = sample_size_per_arm,
      n_replicates = size,
      parameter = treatment_parameter,
      event_time_distribution = event_time_distribution,
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = dropout_rate
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
