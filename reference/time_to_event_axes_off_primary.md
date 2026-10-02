# How many time-to-event design axes are off their primary value

A sensitivity analysis that varies one axis at a time only needs the
designs for which this is at most one; crossing the axes simulates every
combination of them as well.

## Usage

``` r
time_to_event_axes_off_primary(
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

An integer vector, 0 for the primary design.
