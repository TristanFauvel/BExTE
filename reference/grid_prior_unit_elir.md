# Unit-scale ELIR of a gridded prior, averaged over several mixture fits

Each fit follows
[Model](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)'s
`prior_to_RBesT()`: a normal mixture fitted by
[`RBesT::automixfit()`](https://opensource.nibr.com/RBesT/reference/automixfit.html)
to `n_samples` draws from the prior. Its ELIR is taken at a unit
reference scale, which the caller rescales.

## Usage

``` r
grid_prior_unit_elir(
  prior_grid,
  n_samples,
  n_fits,
  n_components,
  aic_penalty,
  seed = 1L
)
```

## Arguments

- prior_grid:

  The prior, as a
  [`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md)
  list.

- n_samples:

  Draws per fit.

- n_fits:

  Number of fits averaged.

- n_components, aic_penalty:

  Mixture fit settings.

- seed:

  Seed the draws are made under.

## Value

The mean unit-scale ELIR over the fits that succeeded, or `NA`.
