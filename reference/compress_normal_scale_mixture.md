# Compress a normal scale mixture into a few components

A normal mixture whose components all share one mean is a distribution
over the component variance `v`, and the conjugate update of
[`normal_mixture_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/normal_mixture_posterior.md)
depends on each component through `v` alone. Every posterior summary is
then an integral against that distribution, and a Gauss rule for it with
a few dozen nodes computes them as accurately as the hundreds of
components it replaces.

The rule is built in \\r = \sqrt{c / (v + c)}\\, where `c` is a typical
squared standard error of the observations. In that variable the
marginal likelihood, the shrinkage factor and the posterior variance are
all analytic over the whole range of `v`, including the near-flat
components whose variance runs to 1e150, so the Gauss rule converges
geometrically: 24 nodes reproduce the 1728-component commensurate power
prior to rounding error. Rules built in `log(v)`, or with the
likelihood's square-root factor folded into the weights, converge far
more slowly or stall around 1e-9.

## Usage

``` r
compress_normal_scale_mixture(weights, variances, reference_variance, n_nodes)
```

## Arguments

- weights:

  Component weights.

- variances:

  Component variances.

- reference_variance:

  The constant `c` above.

- n_nodes:

  Number of components wanted.

## Value

A list with the compressed `weights` and `variances`, or the input
unchanged when it has no more than `n_nodes` components.
