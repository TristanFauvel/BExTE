# Compute the frequentist power at an estimated type I error

Propagates the uncertainty of the equivalent type I error, and the Monte
Carlo error of the power itself, into an interval for the power a
separate frequentist analysis would reach at that type I error.

The reported bounds are quantiles of the resulting posterior for the
power, not a frequentist confidence interval; they are stored under the
existing `conf_int_power` name for continuity with the columns
downstream.

## Usage

``` r
compute_power_with_tie_ci(
  alpha,
  target_data,
  frequentist_test,
  theta_0,
  null_space,
  simulation_config,
  case_study = NULL,
  n_replicates = 1000,
  n_samples = 1000,
  p_values = NULL,
  null_p_values = NULL
)
```

## Arguments

- alpha:

  A list describing the estimated type I error: its `mean`, its exact
  interval bounds, and its `mcse` or `n_replicates` when available.

- target_data:

  Target data object.

- frequentist_test:

  Type of frequentist test to apply, either z-test or t-test.

- theta_0:

  Boundary of the null hypothesis space.

- null_space:

  Side of the null space, either left or right.

- simulation_config:

  Simulation configuration.

- case_study:

  Optional case-study name.

- n_replicates:

  Number of Monte Carlo replicates for non-analytical power.

- n_samples:

  Number of draws of the type I error.

- p_values:

  Optional p-values of the separate analysis, already simulated for this
  design by
  [`simulate_test_p_values()`](https://tristanfauvel.github.io/BExTE/reference/simulate_test_p_values.md).
  They depend on the design alone, not on the borrowing method, so a
  caller pricing many rows of one design simulates them once and passes
  them here. `NULL` simulates them. Ignored when the power has a closed
  form.

- null_p_values:

  Optional p-values of the same test on the trials of the design's null
  scenario. When given, each sampled type I error is matched by the
  test's actual rejection rate there rather than by its nominal level -
  see
  [`calibrated_levels()`](https://tristanfauvel.github.io/BExTE/reference/calibrated_levels.md).
  Ignored when the power has a closed form.

## Value

A list with the power, its interval, and the number of draws used.
