# Summarise borrowing parameters from quadrature weights

Summarise borrowing parameters from quadrature weights

## Usage

``` r
commensurate_parameter_summary(
  posterior_weights,
  mixture,
  heterogeneity_prior_family,
  heterogeneity_prior
)
```

## Arguments

- posterior_weights:

  Matrix with one posterior mixture per row.

- mixture:

  Output from
  [`commensurate_prior_mixture()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_prior_mixture.md).

- heterogeneity_prior_family:

  Name of the prior family.

- heterogeneity_prior:

  Prior parameters.

## Value

A data frame of posterior means and standard deviations.
