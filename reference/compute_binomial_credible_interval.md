# Compute a binomial credible interval

Computes the Clopper-Pearson (exact) confidence interval for a binomial
proportion estimated from 0/1 samples, along with the overall mean of
the samples.

## Usage

``` r
compute_binomial_credible_interval(samples, confidence_level = 0.95)
```

## Arguments

- samples:

  A vector of 0/1 samples, or a matrix whose rows each contain a
  separate set of 0/1 samples.

- confidence_level:

  The confidence level of the interval.

## Value

A list with `mean` (the overall mean of `samples`) and `conf_int` (a
data frame with one row per group, containing `lower` and `upper`
bounds).
