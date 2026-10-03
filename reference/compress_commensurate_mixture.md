# Compress the commensurate quadrature mixture, checking it against the full one

Every component of
[`commensurate_prior_mixture()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_prior_mixture.md)
is centred on the source estimate, so the mixture is a distribution over
the component variance and
[`compress_normal_scale_mixture()`](https://tristanfauvel.github.io/BExTE/reference/compress_normal_scale_mixture.md)
can replace its hundreds of components with a few dozen. The posterior
moments of `tau` and of the power parameter are not functions of the
variance alone; each is the ratio of an integral against the variance
distribution weighted by that parameter to the marginal likelihood, and
gets its own compressed rule.

The compression is accepted only once it reproduces the full mixture on
a probe of the replicates at the extremes and quartiles of the estimate
and of its standard error: every posterior summary, the posterior
probability at `theta_0` and the borrowing-parameter summaries, to
within `tolerance` (relative, for the parameter summaries). The node
count is doubled until it does, and the full mixture is kept if no
compression smaller than it passes, or if it has fewer than four times
`n_nodes` components to begin with.

## Usage

``` r
compress_commensurate_mixture(
  mixture,
  samples,
  theta_0,
  confidence_level,
  heterogeneity_prior_family,
  heterogeneity_prior,
  n_nodes = 32L,
  tolerance = 1e-10
)
```

## Arguments

- mixture:

  Output from
  [`commensurate_prior_mixture()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_prior_mixture.md).

- samples:

  Data frame of generated replicates.

- theta_0:

  Null hypothesis value.

- confidence_level:

  Credible interval level.

- heterogeneity_prior_family:

  Name of the prior family.

- heterogeneity_prior:

  Prior parameters.

- n_nodes:

  Number of components the search starts from.

- tolerance:

  Largest discrepancy accepted on the probe.

## Value

A list with the compressed `weights`, `means` and `sds`, the rules
[`compressed_commensurate_parameter_summary()`](https://tristanfauvel.github.io/BExTE/reference/compressed_commensurate_parameter_summary.md)
reads, and the node count; or `NULL` when the full mixture should be
used.
