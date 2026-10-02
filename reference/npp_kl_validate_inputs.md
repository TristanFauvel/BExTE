# Check the inputs of the KL calibration

Every one of these makes the calibration criterion undefined rather than
merely inaccurate, so they are all rejected before any quadrature rule
is built. Each message names the offending input and its value: the
calibration runs once per scenario, deep inside a simulation, and a bare
"invalid argument" there is expensive to trace back.

## Usage

``` r
npp_kl_validate_inputs(
  theta_source,
  se_source,
  se_target_expected,
  theta_null,
  benefit_sign,
  d_mtd,
  lambda_kl,
  c_target,
  beta_parameter_bounds
)
```

## Arguments

- theta_source:

  Source treatment effect estimate.

- se_source:

  Standard error of the source estimate.

- se_target_expected:

  Expected standard error of the target estimate.

- theta_null:

  Boundary of the null hypothesis space.

- benefit_sign:

  Either `1` or `-1`.

- d_mtd:

  Maximum tolerable discrepancy.

- lambda_kl:

  Weight on the compatible term.

- c_target:

  Shape of the two reference Beta distributions.

- beta_parameter_bounds:

  Bounds on the calibrated shape parameters.

## Value

`NULL`, invisibly.
