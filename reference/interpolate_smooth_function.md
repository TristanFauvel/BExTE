# Interpolate a smooth, expensive function of a positive scalar

Evaluates `f` at Chebyshev-Lobatto nodes in `log(x)` over the range of
`x` and interpolates barycentrically between them, which converges
geometrically for a function analytic in `log(x)`. The interpolant is
checked against `f` halfway between the nodes; the nodes are doubled,
reusing every evaluation, until the largest relative error there is
below `tolerance`. When `x` has no more distinct values than the nodes
would take, `f` is evaluated at those values directly instead.

## Usage

``` r
interpolate_smooth_function(f, x, n_nodes = 33L, tolerance = 1e-09)
```

## Arguments

- f:

  Vectorised function of positive numbers.

- x:

  Positive values at which `f` is wanted.

- n_nodes:

  Number of nodes to start from.

- tolerance:

  Largest relative error accepted at the check points.

## Value

`f` at `x`, interpolated where that is cheaper than evaluating it.
