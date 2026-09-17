# The target trial follows the modified fixed-calendar design: patients enter
# uniformly over an accrual window, each may be followed for at most L, and the
# database is closed F after the end of recruitment.

accrual_period <- 3.41
final_follow_up <- 48 / 52
max_follow_up_time <- 96 / 52
weibull_shape <- 0.72
relapse_free_probability <- 0.442
source_control_rate <- 0.534
source_effect <- -0.393

simulate_arm <- function(n_subjects,
                         n_replicates,
                         parameter,
                         event_time_distribution = "exponential",
                         dropout_rate = 0,
                         accrual = accrual_period,
                         final = final_follow_up) {
  BExTE:::sample_time_to_event_arm(
    n_subjects = n_subjects,
    n_replicates = n_replicates,
    parameter = parameter,
    event_time_distribution = event_time_distribution,
    weibull_shape = weibull_shape,
    accrual_period = accrual,
    final_follow_up = final,
    max_follow_up_time = max_follow_up_time,
    dropout_rate = dropout_rate
  )
}


test_that("the vectorised Cox fit reproduces survival::coxph", {
  skip_if_not_installed("survival")
  set.seed(9001)

  n <- 70
  arm <- rep(c(0, 1), each = n)
  scale <- BExTE:::weibull_control_scale(
    max_follow_up_time, weibull_shape, relapse_free_probability
  )

  for (distribution in c("exponential", "weibull")) {
    for (dropout_probability in c(0, 0.10)) {
      rate <- BExTE:::time_to_event_dropout_rate(
        dropout_probability, max_follow_up_time
      )
      parameters <- if (distribution == "exponential") {
        list(control = source_control_rate,
             treatment = source_control_rate * exp(source_effect))
      } else {
        BExTE:::time_to_event_arm_parameters(
          "weibull", NA, NA, source_effect, 0, weibull_shape, scale
        )
      }

      control <- simulate_arm(n, 6, parameters$control, distribution, rate)
      treatment <- simulate_arm(n, 6, parameters$treatment, distribution, rate)
      time <- cbind(control$time, treatment$time)
      event <- cbind(control$event, treatment$event)

      fit <- BExTE:::fit_two_sample_cox(time, event, arm)

      for (replicate in seq_len(nrow(time))) {
        reference <- survival::coxph(
          survival::Surv(time[replicate, ], event[replicate, ]) ~ arm
        )
        # coxph stops at its own convergence threshold, hence 1e-7 rather than
        # exact equality.
        expect_equal(fit$estimate[replicate], unname(coef(reference)),
                     tolerance = 1e-7)
        expect_equal(fit$standard_error[replicate],
                     unname(sqrt(diag(vcov(reference)))),
                     tolerance = 1e-7)
      }
    }
  }
})


test_that("no patient is followed past the database lock", {
  set.seed(9002)
  sample <- simulate_arm(400, 50, source_control_rate)

  expect_true(all(sample$time <= max_follow_up_time + 1e-12))
  expect_true(all(sample$time > 0))

  # A patient recruited at R is followed until A + F - R, so only those
  # recruited before A + F - L get the full L.
  expect_equal(mean(sample$time >= max_follow_up_time - 1e-12 &
                      sample$event == 0),
               (accrual_period + final_follow_up - max_follow_up_time) /
                 accrual_period * exp(-source_control_rate * max_follow_up_time),
               tolerance = 0.02)
})


test_that("observed event times follow the assumed distribution", {
  set.seed(9003)
  scale <- BExTE:::weibull_control_scale(
    max_follow_up_time, weibull_shape, relapse_free_probability
  )

  # A negligible accrual window with F = L leaves every patient the full
  # follow-up, so an observed event time is the event time truncated to L and
  # can be checked against a closed form.
  exponential <- simulate_arm(20000, 1, source_control_rate,
                              accrual = 1e-8, final = max_follow_up_time)
  observed <- exponential$time[exponential$event == 1]
  expect_gt(suppressWarnings(stats::ks.test(
    observed,
    function(q) {
      stats::pexp(q, source_control_rate) /
        stats::pexp(max_follow_up_time, source_control_rate)
    }
  )$p.value), 0.001)

  weibull <- simulate_arm(20000, 1, scale, "weibull",
                          accrual = 1e-8, final = max_follow_up_time)
  observed <- weibull$time[weibull$event == 1]
  expect_gt(suppressWarnings(stats::ks.test(
    observed,
    function(q) {
      stats::pweibull(q, weibull_shape, scale) /
        stats::pweibull(max_follow_up_time, weibull_shape, scale)
    }
  )$p.value), 0.001)
})


test_that("the dropout rate delivers the requested loss to follow-up", {
  set.seed(9004)

  for (dropout_probability in c(0.05, 0.10)) {
    rate <- BExTE:::time_to_event_dropout_rate(
      dropout_probability, max_follow_up_time
    )
    expect_equal(stats::pexp(max_follow_up_time, rate), dropout_probability,
                 tolerance = 1e-12)
  }

  expect_identical(
    BExTE:::time_to_event_dropout_rate(0, max_follow_up_time), 0
  )

  # With no dropout every patient is followed to an event or to the lock.
  set.seed(9005)
  none <- simulate_arm(2000, 5, source_control_rate, dropout_rate = 0)
  administrative <- none$event == 0
  expect_true(all(none$time[administrative] > 0))
})


test_that("the Weibull scale reproduces the reported relapse-free probability", {
  scale <- BExTE:::weibull_control_scale(
    max_follow_up_time, weibull_shape, relapse_free_probability
  )
  expect_equal(scale, 2.4468, tolerance = 1e-4)
  expect_equal(
    1 - stats::pweibull(max_follow_up_time, weibull_shape, scale),
    relapse_free_probability,
    tolerance = 1e-12
  )

  # Control-arm heterogeneity multiplies the hazard by exp(kappa), which on a
  # Weibull scale is a division by exp(kappa / shape).
  parameters <- BExTE:::time_to_event_arm_parameters(
    "weibull", NA, NA, source_effect, 0.3, weibull_shape, scale
  )
  expect_equal(parameters$control, scale * exp(-0.3 / weibull_shape))
  expect_equal(parameters$treatment,
               parameters$control * exp(-source_effect / weibull_shape))
})


test_that("the analytic event probability matches the simulation", {
  set.seed(9006)
  scale <- BExTE:::weibull_control_scale(
    max_follow_up_time, weibull_shape, relapse_free_probability
  )

  for (distribution in c("exponential", "weibull")) {
    parameter <- if (distribution == "exponential") source_control_rate else scale
    for (dropout_probability in c(0, 0.10)) {
      rate <- BExTE:::time_to_event_dropout_rate(
        dropout_probability, max_follow_up_time
      )
      analytic <- BExTE:::time_to_event_event_probability(
        parameter = parameter,
        event_time_distribution = distribution,
        weibull_shape = weibull_shape,
        accrual_period = accrual_period,
        final_follow_up = final_follow_up,
        max_follow_up_time = max_follow_up_time,
        dropout_rate = rate
      )
      simulated <- mean(simulate_arm(50000, 1, parameter, distribution, rate)$event)
      expect_equal(analytic, simulated, tolerance = 0.01)
    }
  }
})


test_that("the Cox fit recovers the treatment effect under both distributions", {
  set.seed(9007)
  scale <- BExTE:::weibull_control_scale(
    max_follow_up_time, weibull_shape, relapse_free_probability
  )

  average_standard_error <- list()

  for (distribution in c("exponential", "weibull")) {
    for (control_drift in c(0, 0.405)) {
      parameters <- if (distribution == "exponential") {
        control <- source_control_rate * exp(control_drift)
        list(control = control, treatment = control * exp(source_effect))
      } else {
        BExTE:::time_to_event_arm_parameters(
          "weibull", NA, NA, source_effect, control_drift, weibull_shape, scale
        )
      }

      samples <- BExTE:::simulate_time_to_event_trial(
        n_replicates = 3000,
        sample_size_per_arm = 185,
        control_parameter = parameters$control,
        treatment_parameter = parameters$treatment,
        event_time_distribution = distribution,
        weibull_shape = weibull_shape,
        accrual_period = accrual_period,
        final_follow_up = final_follow_up,
        max_follow_up_time = max_follow_up_time,
        dropout_rate = 0
      )

      expect_equal(mean(samples$treatment_effect_estimate, na.rm = TRUE),
                   source_effect, tolerance = 0.02)
      # The reported standard error describes the spread of the estimates.
      expect_equal(mean(samples$treatment_effect_standard_error, na.rm = TRUE),
                   stats::sd(samples$treatment_effect_estimate, na.rm = TRUE),
                   tolerance = 0.05)

      label <- paste(distribution, control_drift)
      average_standard_error[[label]] <-
        mean(samples$treatment_effect_standard_error, na.rm = TRUE)
    }
  }

  # Raising the control hazard buys more events, so the estimate gets sharper.
  for (distribution in c("exponential", "weibull")) {
    expect_lt(average_standard_error[[paste(distribution, 0.405)]],
              average_standard_error[[paste(distribution, 0)]])
  }
})


test_that("replicates without an estimable hazard ratio come back as NA", {
  arm <- rep(c(0, 1), each = 10)
  time <- matrix(stats::runif(2 * 20), nrow = 2)

  no_events <- BExTE:::fit_two_sample_cox(time, matrix(0, 2, 20), arm)
  expect_true(all(is.na(no_events$estimate)))
  expect_true(all(is.na(no_events$standard_error)))

  # Every event in one arm drives the maximum likelihood estimate to infinity.
  one_arm <- matrix(0, 2, 20)
  one_arm[, 1:10] <- 1
  separated <- BExTE:::fit_two_sample_cox(time, one_arm, arm)
  expect_true(all(is.na(separated$estimate)))
  expect_true(all(is.na(separated$standard_error)))
})


test_that("the design standard deviation matches the spread of the estimates", {
  set.seed(9008)
  n <- 185
  design_by_dropout <- c()

  for (dropout_probability in c(0, 0.10)) {
    rate <- BExTE:::time_to_event_dropout_rate(
      dropout_probability, max_follow_up_time
    )
    control <- source_control_rate
    treatment <- control * exp(source_effect)

    design <- BExTE:::time_to_event_standard_deviation(
      control_parameter = control,
      treatment_parameter = treatment,
      event_time_distribution = "exponential",
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = rate
    )

    samples <- BExTE:::simulate_time_to_event_trial(
      n_replicates = 3000,
      sample_size_per_arm = n,
      control_parameter = control,
      treatment_parameter = treatment,
      event_time_distribution = "exponential",
      weibull_shape = weibull_shape,
      accrual_period = accrual_period,
      final_follow_up = final_follow_up,
      max_follow_up_time = max_follow_up_time,
      dropout_rate = rate
    )

    expect_equal(design / sqrt(n),
                 stats::sd(samples$treatment_effect_estimate, na.rm = TRUE),
                 tolerance = 0.05)

    design_by_dropout[as.character(dropout_probability)] <- design
  }

  # Losing patients to follow-up costs events and so widens the estimate.
  expect_lt(design_by_dropout[["0"]], design_by_dropout[["0.1"]])
})


test_that("the time-to-event grid axes are only simulated for that endpoint", {
  scenarios <- list(
    control_drift_range = list(-0.405, 0.405),
    dropout_probability = list(0, 0.05),
    event_time_distribution = list("exponential", "weibull")
  )

  time_to_event <- list(endpoint = "time_to_event")
  continuous <- list(endpoint = "continuous")

  expect_equal(
    compute_control_drift_range(0, scenarios, time_to_event),
    c(-0.405, 0, 0.405)
  )
  expect_equal(compute_control_drift_range(0, scenarios, continuous), 0)
  # A configuration that does not mention control drift keeps a single scenario.
  expect_equal(compute_control_drift_range(0, list(), time_to_event), 0)

  ranges <- compute_time_to_event_ranges(scenarios, time_to_event)
  expect_equal(ranges$dropout_probability, c(0, 0.05))
  expect_equal(ranges$event_time_distribution, c("exponential", "weibull"))

  defaults <- compute_time_to_event_ranges(scenarios, continuous)
  expect_equal(defaults$dropout_probability, 0)
  expect_equal(defaults$event_time_distribution, "exponential")
})
