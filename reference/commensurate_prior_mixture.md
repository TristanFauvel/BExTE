# Discretise the commensurate power prior as a normal mixture

Conditional on the commensurability precision `tau` and power parameter
`gamma`, the treatment-effect prior is normal. Quadrature over those two
parameters therefore turns the continuous prior into a finite normal
mixture. The shared conjugate-mixture kernel can update that mixture for
every simulated target estimate at once, avoiding a separate Stan fit
for each replicate.

All three families are integrated the same way, through their quantile
representation on a Gauss-Legendre rule over the probability scale. For
the inverse-gamma family this remains stable for the configured shapes
as small as 0.001, for which direct density quadrature is dominated by
an endpoint singularity.

## Usage

``` r
commensurate_prior_mixture(model, n_tau = 48L, n_gamma = 24L)
```

## Arguments

- model:

  A
  [GaussianCommensuratePowerPrior](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.md)
  object.

- n_tau:

  Number of quadrature nodes for the commensurability parameter. At the
  default every configured prior family agrees with a 1536-node rule to
  four significant figures, including the `inverse_gamma(0.001, 1)`
  prior, whose quantile function is the steepest of them.

- n_gamma:

  Number of conditional power-parameter nodes per `tau` node.

## Value

A list containing normal-mixture `weights`, `means` and `sds`, plus the
`tau` and `power_parameter` value represented by each component.
