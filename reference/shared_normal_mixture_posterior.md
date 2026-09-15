# Conjugate update of a normal mixture prior shared by every replicate

The same update as
[`normal_mixture_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/normal_mixture_posterior.md),
for the common case of one prior serving every replicate. Broadcasting
the component values against the observations with
[`outer()`](https://rdrr.io/r/base/outer.html) keeps three constant
`n_replicates x n_components` copies of the prior out of memory. For the
commensurate quadrature mixture those copies alone run to hundreds of
megabytes; the posterior matrices are irreducible and dominate what is
left.

## Usage

``` r
shared_normal_mixture_posterior(weights, means, sds, estimate, standard_error)
```

## Arguments

- weights:

  Prior component weights, a vector of length `n_components`.

- means:

  Prior component means, shaped like `weights`.

- sds:

  Prior component standard deviations, shaped like `weights`.

- estimate:

  Vector of per-replicate treatment effect estimates.

- standard_error:

  Per-replicate standard errors, already recycled to the same length as
  `estimate`.

## Value

A list of three `n_replicates x n_components` matrices: `weights`,
`means` and `sds` of the posterior mixture.
