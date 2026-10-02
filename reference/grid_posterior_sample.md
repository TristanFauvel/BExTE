# Draw from a grid posterior

Draw from a grid posterior

## Usage

``` r
grid_posterior_sample(posterior, n_samples)
```

## Arguments

- posterior:

  Output of
  [`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md).

- n_samples:

  Number of draws.

## Value

A vector of draws, by inversion of the distribution function.
