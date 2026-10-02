# Summarise a density tabulated on a grid

Normalises the density by the trapezoidal rule and accumulates it into
the distribution function, from which the moments, quantiles and draws
are read. Between grid points the density and the distribution function
are interpolated linearly.

## Usage

``` r
grid_posterior(grid, density)
```

## Arguments

- grid:

  Increasing grid of treatment effects.

- density:

  Unnormalised density on `grid`.

## Value

A list with `grid`, the normalised `density`, the `cdf` at the grid
points, and the posterior `mean` and `variance`.
