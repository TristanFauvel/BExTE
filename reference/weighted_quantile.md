# Quantiles of a weighted sample

The smallest value whose cumulative weight reaches each probability: the
inverse of the weighted empirical distribution function, which is
`stats::quantile(type = 1)` when the weights are equal. `NA` values are
dropped with their weight, and the rest renormalised.

## Usage

``` r
weighted_quantile(x, weights, probs)
```

## Arguments

- x:

  Numeric vector.

- weights:

  Nonnegative weights, the same length as `x`.

- probs:

  Probabilities.

## Value

A numeric vector of quantiles, one per probability.
