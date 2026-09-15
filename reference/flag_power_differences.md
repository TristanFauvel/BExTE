# Flag power gains and power losses against the comparator

Adds the power difference, its interval, and the gain and loss flags
derived from that single interval. Deciding both from the same interval
keeps gains and losses at the same stringency; they were previously
detected with two different rules – a z-test built from interval widths
on one side, and non-overlap of two intervals on the other.

## Usage

``` r
flag_power_differences(results_df, correlation = 0)
```

## Arguments

- results_df:

  A data frame of operating characteristics.

- correlation:

  Correlation between the two estimates, passed to
  [`mover_difference_ci()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/mover_difference_ci.md).

## Value

The data frame with `power_difference`, `power_difference_lower`,
`power_difference_upper`, `power_gain` and `power_loss` columns added.
