# Compute the frequentist power

This function computes the power of a test for a given significance
level

This function computes the power of a test for a given significance
level

## Usage

``` r
compute_freq_power(
  alpha,
  target_data,
  frequentist_test,
  theta_0,
  null_space,
  simulation_config,
  case_study = NULL,
  n_replicates = 1000,
  p_values = NULL,
  null_p_values = NULL
)
```

## Arguments

- alpha:

  The significance level.

- target_data:

  Target data object

- frequentist_test:

  Type of frequentist test to apply, either z-test or t-test

- theta_0:

  Boundary of the null hypothesis space

- null_space:

  Side of the null space, either left or right.

- simulation_config:

  Simulation configuration.

- case_study:

  Optional case-study name.

- n_replicates:

  Number of Monte Carlo replicates for non-analytical power
  calculations.

- p_values:

  Optional p-values already simulated for this design by
  [`simulate_test_p_values()`](https://tristanfauvel.github.io/BExTE/reference/simulate_test_p_values.md),
  with the same seed and `n_replicates`. `NULL` simulates them. Ignored
  when the power has a closed form.

- null_p_values:

  Optional p-values of the same test on the trials of the design's null
  scenario. When given, the test rejects at the threshold its actual
  type I error there equals `alpha` at, rather than at `alpha` itself -
  see
  [`calibrated_levels()`](https://tristanfauvel.github.io/BExTE/reference/calibrated_levels.md).
  Ignored when the power has a closed form.

## Value

A list containing the power and its confidence interval.
