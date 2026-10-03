# Calibrate the binomial PDCCPP on its exact type I error

The largest calibration parameter Z whose exact type I error does not
exceed `desired_tie`. The type I error is a step function of Z, so Z is
located on a logarithmic grid over \\\[1e-3, 1e3\]\\ and refined by
bisection at the last grid step that stays within `desired_tie`. If even
the largest Z does, borrowing is never discounted for conflict and Z is
the top of the grid; if even the smallest does not, Z is its bottom.

## Usage

``` r
pdccpp_binomial_calibrate(
  table,
  desired_tie,
  source_estimate,
  source_standard_error
)
```

## Arguments

- table:

  Output of
  [`pdccpp_binomial_null_table()`](https://tristanfauvel.github.io/BExTE/reference/pdccpp_binomial_null_table.md).

- desired_tie:

  Desired type I error rate.

- source_estimate, source_standard_error:

  The source estimate and its standard error.

## Value

A list with the `calibration_parameter` and its exact `type_I_error`.
