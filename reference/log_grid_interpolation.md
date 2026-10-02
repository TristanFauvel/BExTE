# Interpolate an expensive function of a positive scalar

Evaluates `f` at `n_nodes` points spaced evenly on the log scale across
the range of `x`, and interpolates linearly in `log(x)` between them.
Where every `x` is equal, `f` is evaluated once.

## Usage

``` r
log_grid_interpolation(f, x, n_nodes = 100L)
```

## Arguments

- f:

  A function of one positive number, returning one number.

- x:

  Positive values at which `f` is wanted.

- n_nodes:

  Number of evaluations of `f`.

## Value

`f` interpolated at `x`.
