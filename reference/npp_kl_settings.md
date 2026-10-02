# Criterion settings of the KL-calibrated normalized power prior

Read from the method parameters, with the defaults of
[`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md).
Shared by
[GaussianNPP_KL](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianNPP_KL.md)
and
[BinomialNPP_KL](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialNPP_KL.md).

## Usage

``` r
npp_kl_settings(parameters, null_space)
```

## Arguments

- parameters:

  The method parameters.

- null_space:

  The null hypothesis space, which gives the benefit direction when
  `benefit_sign` is not configured.

## Value

A list of settings.
