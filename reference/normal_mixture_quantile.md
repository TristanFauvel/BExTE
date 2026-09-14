# Invert a normal mixture CDF for every replicate at once

Bisection on the mixture CDF, which is strictly increasing. The bracket
starts at the mixture mean plus or minus a multiple of its standard
deviation, widened until it straddles the root, then halved to
convergence.

## Usage

``` r
normal_mixture_quantile(
  weights,
  means,
  sds,
  p,
  mixture_mean,
  mixture_sd,
  tolerance = 1e-12
)
```

## Arguments

- weights:

  `n_replicates x n_components` matrix of mixture weights.

- means:

  `n_replicates x n_components` matrix of component means.

- sds:

  `n_replicates x n_components` matrix of component standard deviations.

- p:

  Single probability at which to evaluate the quantile function.

- mixture_mean:

  Vector of mixture means, used to seed the bracket.

- mixture_sd:

  Vector of mixture standard deviations, used to seed the bracket.

- tolerance:

  Absolute width at which bisection stops.

## Value

Vector of quantiles, one per replicate.
