# The design a time-to-event case study is primarily simulated under

No control-arm heterogeneity, no loss to follow-up, exponential event
times and proportional hazards (no delay before the treatment effect).
It is the design a configuration that does not mention the sensitivity
axes produces, and the one the whole scenario grid is simulated at.

## Usage

``` r
is_primary_time_to_event_design(
  control_drift,
  dropout_probability,
  event_time_distribution,
  treatment_delay = 0
)
```

## Arguments

- control_drift:

  Control-arm heterogeneity, kappa.

- dropout_probability:

  Probability of loss to follow-up over the maximum follow-up time.

- event_time_distribution:

  Either "exponential" or "weibull".

- treatment_delay:

  Time before the treatment effect starts, in years.

## Value

TRUE when the four describe the primary design.
