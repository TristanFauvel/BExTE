# Post-delay log hazard ratio that gives a target Cox estimand

Under a delayed treatment effect the hazard ratio is 1 for the first
`delay` years and exp(beta) afterwards. The Cox model fitted to such a
trial converges to an average of the two, weighted by when the events
fall under the trial's censoring. This returns the beta for which that
average equals `log_hr`, so that the delayed-effect scenario keeps the
treatment effect - and hence the drift, the bias and the null
hypothesis - of the proportional-hazards scenario it replaces. Under no
effect beta is 0 and the two arms coincide.

## Usage

``` r
time_to_event_delayed_log_hr(
  log_hr,
  control_parameter,
  event_time_distribution,
  weibull_shape,
  delay,
  accrual_period,
  final_follow_up,
  max_follow_up_time,
  dropout_rate
)
```

## Arguments

- log_hr:

  The Cox estimand, the scenario's target treatment effect.

- control_parameter:

  Control rate (exponential) or scale (Weibull).

- event_time_distribution:

  Either "exponential" or "weibull".

- weibull_shape:

  The Weibull shape, unused for exponential times.

- delay:

  Time before the treatment effect starts, in years.

- accrual_period, final_follow_up, max_follow_up_time:

  The calendar design.

- dropout_rate:

  Rate of loss to follow-up.

## Value

The post-delay log hazard ratio, beta.
