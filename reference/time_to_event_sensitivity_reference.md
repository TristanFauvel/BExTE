# The point at which the time-to-event sensitivity designs are simulated

Crossing control-arm heterogeneity, loss to follow-up and the event time
distribution with the whole grid multiplies a run by the product of
their lengths, and most of that is spent re-simulating designs nobody
reads. When `sensitivity_reference` names a sample size factor and a
source denominator change factor, a design other than the primary one is
simulated only there, so the sensitivity analysis still varies the drift
across its full range at a single trial size. Without the key the axes
cross the whole grid, which is what a configuration written before it
existed does.

## Usage

``` r
time_to_event_sensitivity_reference(scenarios_config, case_study_config)
```

## Arguments

- scenarios_config:

  Configuration for the simulation.

- case_study_config:

  Configuration for the case study.

## Value

A list with `sample_size_factor` and `denominator_change_factor`, or
NULL when every design is simulated across the whole grid.
