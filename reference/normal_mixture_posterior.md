# Conjugate update of a normal mixture prior across replicates

Applies the normal-normal conjugate update to every replicate at once.
This is the vectorised equivalent of calling
[`RBesT::postmix()`](https://opensource.nibr.com/RBesT/reference/postmix.html)
once per replicate: for a prior component with weight \\w_k\\, mean
\\\mu_k\\ and standard deviation \\s_k\\, and an observation \\(m_i,
se_i)\\, the posterior component has variance \\1/(1/s_k^2 +
1/se_i^2)\\, mean \\v\_{ik}(\mu_k/s_k^2 + m_i/se_i^2)\\ and weight
proportional to \\w_k \\ N(m_i; \mu_k, s_k^2 + se_i^2)\\.

## Usage

``` r
normal_mixture_posterior(weights, means, sds, estimate, standard_error)
```

## Arguments

- weights:

  Prior component weights. Either a vector of length `n_components` (a
  prior shared by every replicate) or a `n_replicates x n_components`
  matrix (one prior per replicate, as needed by empirical Bayes
  methods).

- means:

  Prior component means, shaped like `weights`.

- sds:

  Prior component standard deviations, shaped like `weights`.

- estimate:

  Vector of per-replicate treatment effect estimates.

- standard_error:

  Vector of per-replicate standard errors.

## Value

A list of three `n_replicates x n_components` matrices: `weights`,
`means` and `sds` of the posterior mixture.
