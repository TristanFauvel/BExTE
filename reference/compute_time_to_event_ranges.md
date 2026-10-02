# Compute the ranges of the time-to-event design axes.

The probability of loss to follow-up, the distribution of the event
times and the delay before the treatment effect only change how a
time-to-event trial is simulated, so every other case study keeps a
single scenario at the primary design rather than paying for a cross
product that would generate identical data.

## Usage

``` r
compute_time_to_event_ranges(scenarios_config, case_study_config)
```

## Arguments

- scenarios_config:

  Configuration for the simulation.

- case_study_config:

  Configuration for the case study.

## Value

A list with the `dropout_probability`, `event_time_distribution` and
`treatment_delay` ranges.
