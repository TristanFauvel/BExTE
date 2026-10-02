# Exact type I error of the binomial PDCCPP for given calibration parameters

Exact type I error of the binomial PDCCPP for given calibration
parameters

## Usage

``` r
pdccpp_binomial_type_I_error(
  table,
  calibration_parameter,
  source_estimate,
  source_standard_error
)
```

## Arguments

- table:

  Output of
  [`pdccpp_binomial_null_table()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/pdccpp_binomial_null_table.md).

- calibration_parameter:

  Calibration parameters Z.

- source_estimate, source_standard_error:

  The source estimate and its standard error.

## Value

One type I error rate per calibration parameter.
