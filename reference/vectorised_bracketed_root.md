# Find a root of every row's function within its bracket

Regula falsi with the Illinois modification, run on every row at once.
Each row keeps an interval whose ends give its function opposite signs,
so the root is never lost, and whenever the same end survives twice in a
row its function value is halved for the next interpolation, which
restores superlinear convergence where plain regula falsi would stall. A
point the interpolation cannot place strictly inside the interval, as
with an infinite end, is replaced by the midpoint. A row stops when its
interval is narrower than `tolerance` times the larger of one and its
magnitude, or when its function is exactly zero, which collapses the
interval onto the root.

## Usage

``` r
vectorised_bracketed_root(
  f,
  lower,
  upper,
  f_lower,
  f_upper,
  tolerance = 1e-13,
  max_iterations = 100L
)
```

## Arguments

- f:

  Function of the points and the indices of the rows they belong to,
  returning one value per point.

- lower, upper:

  Ends of each row's interval.

- f_lower, f_upper:

  The function at those ends, of opposite signs or zero.

- tolerance:

  Relative width at which a row stops.

- max_iterations:

  Iteration cap, far above what convergence needs.

## Value

A list with the final `lower` and `upper` ends, the function's sign
there as `f_lower` and `f_upper` (its magnitude is rescaled by the
Illinois step), and `root`, the midpoint of the final interval.
