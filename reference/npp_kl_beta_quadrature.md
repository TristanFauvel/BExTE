# Quadrature rule for a Beta measure on the unit interval

The calibration integrates against `Beta(a, b)` densities whose shape
parameters go as low as 0.05, so the integrand has an algebraic
singularity at each endpoint. Gauss-Jacobi integrates
\\\gamma^{a-1}(1-\gamma)^{b-1}\\ exactly, leaving only the smooth
remainder to the rule, which is the same argument
[`npp_prior_mixture()`](https://tristanfauvel.github.io/BExTE/reference/npp_prior_mixture.md)
makes for the prior mixture. Substituting \\\gamma = (1 + x)/2\\ maps
[`statmod::gauss.quad()`](https://rdrr.io/pkg/statmod/man/gauss.quad.html)'s
interval onto the unit interval and turns its weight function
\\(1-x)^\alpha (1+x)^\beta\\ into the Beta kernel with \\\alpha = b -
1\\ and \\\beta = a - 1\\, at the cost of the constant \\2^{1-a-b}\\.

Dividing that by the Beta function leaves weights that are the Beta
measure itself, so they sum to one; they are returned on the log scale
because the likelihood they are combined with is evaluated there.

## Usage

``` r
npp_kl_beta_quadrature(alpha_gamma, beta_gamma, n_nodes = 80L)
```

## Arguments

- alpha_gamma:

  First shape parameter of the Beta prior.

- beta_gamma:

  Second shape parameter of the Beta prior.

- n_nodes:

  Number of quadrature nodes.

## Value

A list with `nodes`, strictly inside the unit interval, and
`log_weights`, the log of the Beta measure each node carries.
