# Expand a prior specification to one row per replicate

Expand a prior specification to one row per replicate

## Usage

``` r
recycle_prior_component(x, n_replicates)
```

## Arguments

- x:

  A vector of component values shared by every replicate, or a matrix
  with one row per replicate.

- n_replicates:

  Number of replicates.

## Value

A `n_replicates x n_components` matrix.
