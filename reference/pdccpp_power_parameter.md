# Power parameter of the calibrated power prior

Power parameter of the calibrated power prior

## Usage

``` r
pdccpp_power_parameter(
  target_estimate,
  target_standard_error,
  source_estimate,
  source_standard_error,
  calibration_parameter
)
```

## Arguments

- target_estimate, target_standard_error:

  Target estimates and their standard errors.

- source_estimate, source_standard_error:

  Source estimate and its standard error.

- calibration_parameter:

  The calibration parameter Z, a number of predictive standard
  deviations.

## Value

The power parameters, vectorised over the target estimates.
