# Simulate the p-values of the frequentist test

Generates `n_replicates` trials and returns the p-value of the test in
each one. Returning the p-values rather than the decisions lets the
power be read off at any significance level without re-simulating.

## Usage

``` r
simulate_test_p_values(
  target_data,
  frequentist_test,
  theta_0,
  alternative,
  simulation_config,
  n_replicates
)
```

## Arguments

- target_data:

  Target data object.

- frequentist_test:

  Type of frequentist test to apply.

- theta_0:

  Boundary of the null hypothesis space.

- alternative:

  Direction of the alternative hypothesis.

- simulation_config:

  Simulation configuration.

- n_replicates:

  Number of trials to simulate.

## Value

A numeric vector of `n_replicates` p-values.
