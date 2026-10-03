# Discretise the commensurate power prior as a normal mixture

Conditional on the commensurability precision `tau` and power parameter
`gamma`, the treatment-effect prior is normal. Quadrature over those two
parameters therefore turns the continuous prior into a finite normal
mixture. The shared conjugate-mixture kernel can update that mixture for
every simulated target estimate at once, avoiding a separate Stan fit
for each replicate.

All three families are integrated the same way, through their quantile
representation on a Gauss-Legendre rule over the probability scale. For
the inverse-gamma family this remains stable for shapes as small as
0.001, for which direct density quadrature is dominated by an endpoint
singularity.

## Usage

``` r
commensurate_prior_mixture(model, n_tau = 48L, n_gamma = 12L)
```

## Arguments

- model:

  A
  [GaussianCommensuratePowerPrior](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.md)
  or
  [GaussianCommensuratePrior](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePrior.md)
  object. The latter fixes the power parameter at one, which collapses
  the second quadrature dimension: the mixture is then one normal
  component per `tau` node rather than `n_gamma` of them.

- n_tau:

  Number of quadrature nodes for the commensurability parameter. Two
  families multiply it, because their quantile functions are too steep
  for the default: an inverse gamma with a shape below 0.01 by four, and
  a log-Cauchy by `ceiling(scale / 10)`. With those, every configured
  prior's posterior summaries agree with a 3072-node rule to within 5e-5
  over target estimates from 0 to 2.

- n_gamma:

  Number of conditional power-parameter nodes per `tau` node. Ignored
  when the model does not borrow a power parameter. Against a rule twice
  as fine in both dimensions, 12 nodes keep every configured prior's
  posterior quantiles within 0.2% of a posterior standard deviation on
  the Botox, Belimumab, Mepolizumab and Teriflunomide designs, the same
  order as the error left by the `tau` rule; 24 nodes halve that
  difference at twice the cost of every replicate.

## Value

A list containing normal-mixture `weights`, `means` and `sds`, plus the
`tau` and `power_parameter` value represented by each component.
`power_parameter` is `NULL` when the model does not have one.
