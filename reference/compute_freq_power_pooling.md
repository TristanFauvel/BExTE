# Compute the frequentist power

This function computes the power of a test for a pooled analysis at a
given significance level

## Usage

``` r
compute_freq_power_pooling(
  alpha,
  target_data,
  source_data,
  frequentist_test,
  theta_0,
  null_space,
  simulation_config,
  case_study = NULL,
  n_replicates = 1000,
  trials = NULL
)
```

## Arguments

- alpha:

  The significance level.

- target_data:

  Target data object

- source_data:

  Source study data

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

- trials:

  Optional trials already simulated for this design, with the same seed
  and `n_replicates`, as the separate analysis's power reads them.
  `NULL` simulates them. Ignored when the power has a closed form.

## Value

The power of the test.
