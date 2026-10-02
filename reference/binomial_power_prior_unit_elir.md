# Unit-scale ELIR of a binomial power prior, interpolated in the power parameter

Linear interpolation between the two grid nodes around
`power_parameter`, each computed once per worker by
[`grid_prior_unit_elir()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_prior_unit_elir.md)
and cached. The ELIR is close to linear in the power parameter, so the
interpolation error is small against the fits' own.

## Usage

``` r
binomial_power_prior_unit_elir(
  model,
  power_parameter,
  n_samples,
  step = 0.05,
  n_fits = 10L
)
```

## Arguments

- model:

  A binomial power prior model, whose `quadrature_prior()` takes the
  power parameter.

- power_parameter:

  The power parameter, in 0, 1.

- n_samples:

  Draws per mixture fit.

- step:

  Spacing of the power parameter grid.

- n_fits:

  Number of mixture fits averaged per node.

## Value

The unit-scale ELIR.
