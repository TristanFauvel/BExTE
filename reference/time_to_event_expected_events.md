# Expected number of observed events in each arm of the target trial

The number of events is what loss to follow-up, the event time
distribution and control-arm heterogeneity change in the time-to-event
trial, and what the precision of its log hazard ratio rests on. Uses the
same arm parameters and censoring as the data generator.

## Usage

``` r
time_to_event_expected_events(
  case_study_config,
  sample_size_per_arm,
  control_drift = 0,
  dropout_probability = 0,
  event_time_distribution = "exponential",
  treatment_effect = case_study_config$source$treatment_effect,
  treatment_delay = 0
)
```

## Arguments

- case_study_config:

  A time-to-event case study configuration.

- sample_size_per_arm:

  Number of patients in each arm.

- control_drift:

  Control-arm heterogeneity, kappa, on the log scale.

- dropout_probability:

  Probability of loss to follow-up over the maximum follow-up time.

- event_time_distribution:

  Either "exponential" or "weibull".

- treatment_effect:

  Target log hazard ratio; the source estimate by default, i.e. a
  consistent treatment effect. Under a delayed effect, the Cox model's
  large-sample limit (see
  [`time_to_event_delayed_log_hr()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/time_to_event_delayed_log_hr.md)).

- treatment_delay:

  Time before the treatment effect starts, in years.

## Value

A named numeric vector with elements `control` and `treatment`.
