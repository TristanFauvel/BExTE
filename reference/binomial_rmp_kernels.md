# Prior kernels of the binomial robust mixture prior with a given weight

Prior kernels of the binomial robust mixture prior with a given weight

## Usage

``` r
binomial_rmp_kernels(components, weight)
```

## Arguments

- components:

  Output of
  [`binomial_rmp_components()`](https://tristanfauvel.github.io/BExTE/reference/binomial_rmp_components.md).

- weight:

  Prior weight of the informative component.

## Value

A list as
[`binomial_npp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_posterior.md)
reads it, whose `prior_weight` moment gives the posterior weight of the
informative component.
