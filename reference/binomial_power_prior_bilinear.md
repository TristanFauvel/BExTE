# The target terms in source coordinates

T(i, s - i) as an N x N matrix indexed by the source control rate i and
the source treatment rate s, zero where the risk difference s - i is not
among those the target data reach.

## Usage

``` r
binomial_power_prior_bilinear(terms)
```

## Arguments

- terms:

  Output of
  [`binomial_power_prior_target_terms()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_target_terms.md).

## Value

An N x N matrix.
