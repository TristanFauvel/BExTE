# Compute the control drift range for a given source treatment effect.

Control drift is the control-arm heterogeneity between the source and
the target population, kappa = log(control rate in the target) -
log(control rate in the source). Only the time-to-event endpoint
simulates it; every other case study keeps a single scenario with no
control drift. The no-heterogeneity scenario is always included, as it
is the reference the others are read against.

## Usage

``` r
compute_control_drift_range(
  source_treatment_effect,
  scenarios_config = NULL,
  case_study_config = NULL
)
```

## Arguments

- source_treatment_effect:

  The source treatment effect.

- scenarios_config:

  Configuration for the simulation.

- case_study_config:

  Configuration for the case study.

## Value

A vector representing the control drift range.
