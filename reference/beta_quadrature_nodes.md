# Quantile midpoints of a Beta distribution

Averaging a function over these nodes integrates it against the Beta
density by the midpoint rule in probability space, which follows the
mass of the distribution without any tuning.

## Usage

``` r
beta_quadrature_nodes(shape1, shape2, n_nodes)
```

## Arguments

- shape1, shape2:

  Shape parameters of the Beta distribution.

- n_nodes:

  Number of nodes.

## Value

A numeric vector of `n_nodes` nodes in (0, 1).
