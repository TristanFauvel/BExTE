# Calibrate the KL normalized power prior to a design

The expected target standard error is the one the design implies, from
[`npp_kl_expected_target_se()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/npp_kl_expected_target_se.md).
It is not the standard error of any replicate: those vary around this
one, and using them would make the prior a function of the data it is
supposed to be a prior for.

## Usage

``` r
npp_kl_calibrate_design(source, target_data, theta_0, settings)
```

## Arguments

- source:

  The source data, with `treatment_effect_estimate` and
  `standard_error`.

- target_data:

  Target study data for the scenario.

- theta_0:

  Boundary of the null hypothesis space.

- settings:

  Output of
  [`npp_kl_settings()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/npp_kl_settings.md).

## Value

The output of
[`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md).
