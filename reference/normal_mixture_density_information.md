# Density times Fisher information of a normal mixture at a grid of points

Returns \\p(x)\\i(x)\\, the integrand of the ELIR expectation, with
\\i(x) = -\partial^2_x \log p(x)\\. Both factors come out of the same
log-sum-exp pass, which keeps a component with negligible responsibility
from underflowing.

## Usage

``` r
normal_mixture_density_information(weights, means, sds, x)
```

## Arguments

- weights:

  `n_replicates x n_components` matrix of mixture weights.

- means:

  `n_replicates x n_components` matrix of component means.

- sds:

  `n_replicates x n_components` matrix of component standard deviations.

- x:

  `n_replicates x n_points` matrix of evaluation points.

## Value

A `n_replicates x n_points` matrix of \\p(x)\\i(x)\\.
