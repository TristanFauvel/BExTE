# Draw plausible values of the equivalent type I error

Draws from the posterior of the type I error implied by the replicates
it was estimated from, rather than from a normal centred on the estimate
whose spread is read off the width of an exact interval.

## Usage

``` r
sample_equivalent_tie(alpha, n_samples)
```

## Arguments

- alpha:

  A list with the type I error estimate (`mean`), its exact interval
  bounds and, when available, its Monte Carlo standard error (`mcse`) or
  replicate count (`n_replicates`).

- n_samples:

  Number of draws to return.

## Value

A numeric vector of `n_samples` draws, or `NA` when the replicate count
behind the estimate cannot be recovered.
