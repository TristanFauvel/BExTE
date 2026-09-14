# Replace success probabilities by power differences

Turns the success probability columns into the difference against the
frequentist power at equivalent type I error, with an interval that
accounts for the uncertainty of both estimates rather than shifting the
success probability interval by the comparator's point estimate.

## Usage

``` r
add_power_difference_columns(results_df, correlation = 0)
```

## Arguments

- results_df:

  A data frame of operating characteristics.

- correlation:

  Correlation between the two estimates. The default of `0` treats them
  as independent, which is the conservative choice: the two are
  estimated from simulations sharing a seed, and any positive
  correlation between them would only narrow the interval.

  Note separately that the comparator is a deterministic function of a
  single type I error estimate shared by every row of a panel, so the
  comparator errors are perfectly correlated *across* rows whatever this
  within-row correlation is; points within a panel must not be read as
  independent.

## Value

The data frame with `success_proba` and its interval bounds replaced by
the difference and its interval.
