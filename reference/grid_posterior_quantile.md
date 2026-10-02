# Quantiles of a grid posterior

Inverts the piecewise linear distribution function. Its flat stretches,
where the density underflowed to zero, are dropped first, so the inverse
is well defined.

## Usage

``` r
grid_posterior_quantile(posterior, probability)
```

## Arguments

- posterior:

  Output of
  [`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md).

- probability:

  Probabilities.

## Value

The quantiles.
