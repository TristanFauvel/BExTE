# Posterior of the risk difference from the target terms

Posterior of the risk difference from the target terms

## Usage

``` r
binomial_power_prior_terms_posterior(terms, power_parameter)
```

## Arguments

- terms:

  Output of
  [`binomial_power_prior_target_terms()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_target_terms.md).

- power_parameter:

  The power parameter, in \\\[0, 1\]\\.

## Value

A
[`grid_posterior()`](https://tristanfauvel.github.io/BExTE/reference/grid_posterior.md)
list, the same as
[`binomial_power_prior_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_posterior.md)
gives.
