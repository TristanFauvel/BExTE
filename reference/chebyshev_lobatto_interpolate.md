# Barycentric interpolation at Chebyshev-Lobatto nodes

Barycentric interpolation at Chebyshev-Lobatto nodes

## Usage

``` r
chebyshev_lobatto_interpolate(nodes, values, z)
```

## Arguments

- nodes:

  The nodes `cos(pi * k / (n - 1))`, `k = 0, ..., n - 1`.

- values:

  Function values at the nodes.

- z:

  Points in `[-1, 1]` to interpolate at.

## Value

The interpolant at `z`.
