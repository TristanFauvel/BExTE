# Mean, standard deviation and quantiles of a normal mixture, per replicate

Vectorised equivalent of
[`summary()`](https://rdrr.io/r/base/summary.html) on an
[`RBesT::mixnorm()`](https://opensource.nibr.com/RBesT/reference/mixnorm.html)
object. The mean and standard deviation are closed form. The quantiles
invert the mixture CDF by bisection, which runs on every replicate
simultaneously; RBesT instead calls `uniroot` once per mixture, at a
looser tolerance.

## Usage

``` r
normal_mixture_summary(weights, means, sds, probs = c(0.025, 0.5, 0.975))
```

## Arguments

- weights:

  `n_replicates x n_components` matrix of mixture weights.

- means:

  `n_replicates x n_components` matrix of component means.

- sds:

  `n_replicates x n_components` matrix of component standard deviations.

- probs:

  Probabilities at which to evaluate the quantile function.

## Value

A list with `mean` and `sd` vectors of length `n_replicates`, and a
`n_replicates x length(probs)` matrix of `quantiles`.
