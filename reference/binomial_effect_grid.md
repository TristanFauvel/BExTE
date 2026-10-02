# Grid of treatment effects covering a binomial posterior

The posterior of the difference in response rates only has mass where
the treatment arm likelihood does, i.e. where theta + v falls in the
bulk of Beta(treatment_shape1, treatment_shape2) for some control rate
node v. The grid spans that region, clipped to -1, 1, with a spacing
fine enough to resolve the narrowest of `scales`.

## Usage

``` r
binomial_effect_grid(
  treatment_shape1,
  treatment_shape2,
  control_nodes,
  scales,
  points_per_scale = 20,
  min_points = 401L,
  max_points = 20001L,
  tail = 1e-12
)
```

## Arguments

- treatment_shape1, treatment_shape2:

  Shape parameters of the treatment arm likelihood, as a Beta density in
  the treatment rate.

- control_nodes:

  Quadrature nodes on the target control rate.

- scales:

  Standard deviations of every factor the grid must resolve.

- points_per_scale:

  Grid points per narrowest standard deviation.

- min_points, max_points:

  Bounds on the number of grid points.

- tail:

  Tail probability left outside the grid on each side.

## Value

An increasing numeric vector of treatment effects.
