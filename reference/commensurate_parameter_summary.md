# Summarise borrowing parameters from quadrature weights

Summarise borrowing parameters from quadrature weights

## Usage

``` r
commensurate_parameter_summary(
  posterior_weights,
  mixture,
  heterogeneity_prior_family,
  heterogeneity_prior,
  borrows_power_parameter = TRUE
)
```

## Arguments

- posterior_weights:

  Matrix with one posterior mixture per row.

- mixture:

  Output from
  [`commensurate_prior_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/commensurate_prior_mixture.md).

- heterogeneity_prior_family:

  Name of the prior family.

- heterogeneity_prior:

  Prior parameters.

- borrows_power_parameter:

  Whether the model has a power parameter. When it does not, the two
  power-parameter columns are absent rather than constant: the plain
  commensurate prior has no such parameter to report, and a column of
  ones would read as an estimate.

## Value

A data frame of posterior means and standard deviations.
