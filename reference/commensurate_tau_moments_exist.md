# Which posterior moments of the commensurability parameter exist

The target marginal likelihood approaches a positive constant as `tau`
goes to infinity, so it does not repair a divergent positive moment of
the prior: the posterior mean and standard deviation of `tau` exist
exactly when the prior's do. Where they do not, both inference paths
report `Inf` rather than a finite, run-dependent truncation - the
quadrature because its outer nodes are clipped, Stan because its draws
are a sample.

## Usage

``` r
commensurate_tau_moments_exist(heterogeneity_prior_family, heterogeneity_prior)
```

## Arguments

- heterogeneity_prior_family:

  Name of the prior family.

- heterogeneity_prior:

  Prior parameters.

## Value

A logical vector with elements `mean` and `sd`.
