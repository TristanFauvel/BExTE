# ELIR effective sample size by panelled Gauss-Legendre quadrature

The quadrature behind
[`normal_mixture_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/normal_mixture_elir_ess.md),
for mixtures with at least two components given as matrices with one row
per replicate.

## Usage

``` r
normal_mixture_elir_quadrature(
  weights,
  means,
  sds,
  sigma,
  n_nodes = 40L,
  spread = 9
)
```

## Arguments

- weights:

  Mixture weights: a vector when the prior is shared by every replicate,
  or a `n_replicates x n_components` matrix.

- means:

  Component means, shaped like `weights`.

- sds:

  Component standard deviations, shaped like `weights`.

- sigma:

  Reference scale, either a single value or one value per replicate.

- n_nodes:

  Number of Gauss-Legendre nodes per panel.

- spread:

  How many standard deviations each component's panels reach.

## Value

Vector of ELIR effective sample sizes, one per replicate.
