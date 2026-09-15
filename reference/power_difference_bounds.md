# Interval for the difference between success probability and comparator power

Applies
[`mover_difference_ci()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/mover_difference_ci.md)
row by row to the success probability and the frequentist power at
equivalent type I error.

## Usage

``` r
power_difference_bounds(results_df, correlation = 0)
```

## Arguments

- results_df:

  A data frame carrying `success_proba`, its interval bounds,
  `frequentist_power_at_equivalent_tie` and its interval bounds.

- correlation:

  Correlation between the two estimates, passed to
  [`mover_difference_ci()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/mover_difference_ci.md).

## Value

A matrix with one row per input row and columns `lower` and `upper`.
