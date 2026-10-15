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
        sample_size_control = 185,
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
      sample_size_control = n,
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


test_that("the expected number of events falls with loss to follow-up", {
  config <- yaml::read_yaml(
    system.file("conf/case_studies/teriflunomide.yml", package = "BExTE")
  )
  events <- vapply(c(0, 0.05, 0.10), function(dropout) {
    sum(time_to_event_expected_events(config, 123, dropout_probability = dropout))
  }, numeric(1))

  expect_true(all(diff(events) < 0))
  expect_true(all(events < 2 * 123))
  # A higher control relapse rate gives more events.
  expect_gt(
    sum(time_to_event_expected_events(config, 123, control_drift = 0.405)),
    events[1]
  )
})


teriflunomide_design <- function() {
  config <- yaml::read_yaml(
    system.file("conf/case_studies/teriflunomide.yml", package = "BExTE")
  )
  config$target
}


test_that("under proportional hazards the Cox limit is the hazard ratio", {
  target <- teriflunomide_design()
  # Exponential and Weibull, with and without loss to follow-up: the limit
  # does not depend on the censoring when hazards are proportional.
  expect_equal(time_to_event_cox_limit(
    0.534, "exponential", NULL, 0, -0.393,
    target$accrual_period, target$final_follow_up, target$max_follow_up_time, 0
  ), -0.393, tolerance = 1e-6)
  scale <- weibull_control_scale(target$max_follow_up_time, target$weibull_shape,
                                 target$weibull_relapse_free_probability)
  expect_equal(time_to_event_cox_limit(
    scale, "weibull", target$weibull_shape, 0, 0.3,
    target$accrual_period, target$final_follow_up, target$max_follow_up_time, 0.1
  ), 0.3, tolerance = 1e-6)
})


test_that("the post-delay hazard ratio reproduces the Cox estimand", {
  target <- teriflunomide_design()
  solve <- function(log_hr, delay) {
    time_to_event_delayed_log_hr(
      log_hr, 0.534, "exponential", NULL, delay,
      target$accrual_period, target$final_follow_up, target$max_follow_up_time, 0
    )
  }

  # No delay, or no effect: nothing to dilute.
  expect_equal(solve(-0.393, 0), -0.393)
  expect_equal(solve(0, 0.461538), 0)

  for (delay in c(0.230769, 0.461538)) {
    for (log_hr in c(-0.393, 0.2)) {
      late <- solve(log_hr, delay)
      # The delay dilutes the effect, so the late one is stronger.
      expect_gt(abs(late), abs(log_hr))
      expect_equal(sign(late), sign(log_hr))
      expect_equal(time_to_event_cox_limit(
        0.534, "exponential", NULL, delay, late,
        target$accrual_period, target$final_follow_up, target$max_follow_up_time, 0
      ), log_hr, tolerance = 1e-6)
    }
  }
  # A longer delay needs a stronger late effect.
  expect_lt(solve(-0.393, 0.461538), solve(-0.393, 0.230769))

  expect_error(solve(-0.393, target$max_follow_up_time), "no follow-up")
})


test_that("a delayed arm keeps the control hazard until the delay", {
  set.seed(3)
  arm <- sample_time_to_event_arm(
    n_subjects = 20000, n_replicates = 1, parameter = 0.5,
    event_time_distribution = "exponential", weibull_shape = NULL,
    accrual_period = 1, final_follow_up = 100, max_follow_up_time = 100,
    dropout_rate = 0, delay = 1, late_log_hr = log(0.5)
  )
  time <- as.vector(arm$time)
  # Before the delay the hazard is 0.5, so P(T < 1) = 1 - exp(-0.5); after it
  # the hazard halves, so P(T > 3 | T > 1) = exp(-0.25 * 2).
  expect_equal(mean(time < 1), 1 - exp(-0.5), tolerance = 0.02)
  expect_equal(mean(time > 3) / mean(time > 1), exp(-0.5), tolerance = 0.02)
})


test_that("the delayed trial's Cox estimate is centred on the treatment effect", {
  cfg <- yaml::read_yaml(
    system.file("conf/case_studies/teriflunomide.yml", package = "BExTE")
  )
  source <- SourceData$new(case_study_config = cfg, source_denominator = cfg$source$control_rate)
  set.seed(11)
  target <- TargetDataFactory$new()$create(
    source_data = source, case_study_config = cfg, target_sample_size_control = 123, target_sample_size_treatment = 123,
    treatment_drift = 0, control_drift = 0, summary_measure_likelihood = "normal",
    treatment_delay = 0.461538
  )
  expect_lt(target$late_log_hr, target$treatment_effect)

  estimates <- target$generate(1500)$treatment_effect_estimate
  expect_lt(abs(mean(estimates) - target$treatment_effect),
            4 * stats::sd(estimates) / sqrt(length(estimates)))
})


test_that("a delay is refused under the sampling approximation", {
  cfg <- yaml::read_yaml(
    system.file("conf/case_studies/teriflunomide.yml", package = "BExTE")
  )
  cfg$sampling_approximation <- TRUE
  source <- SourceData$new(case_study_config = cfg, source_denominator = cfg$source$control_rate)
  target <- TargetDataFactory$new()$create(
    source_data = source, case_study_config = cfg, target_sample_size_control = 123, target_sample_size_treatment = 123,
    treatment_drift = 0, control_drift = 0, summary_measure_likelihood = "normal",
    treatment_delay = 0.230769
  )
  expect_error(target$generate(10), "patient by patient")
})


test_that("the expected number of treatment events falls with the delay", {
  config <- yaml::read_yaml(
    system.file("conf/case_studies/teriflunomide.yml", package = "BExTE")
  )
  events <- vapply(c(0, 0.230769, 0.461538), function(delay) {
    time_to_event_expected_events(config, 123, treatment_delay = delay)[["treatment"]]
  }, numeric(1))
  # Matching the same Cox estimand needs a stronger effect after a longer
  # delay, which removes more treatment-arm events than the delay adds.
  expect_true(all(diff(events) < 0))
  expect_equal(time_to_event_expected_events(config, 123, treatment_delay = 0.461538)[["control"]],
               time_to_event_expected_events(config, 123)[["control"]])
})
