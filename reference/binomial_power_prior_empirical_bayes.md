# Empirical Bayes power parameter of the binomial power prior

The maximizer of
[`binomial_power_prior_log_marginal()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_power_prior_log_marginal.md)
over 0, 1: the best of 21 equally spaced values, refined by Brent's
method between its neighbours, with the end points kept as candidates.

## Usage

``` r
binomial_power_prior_empirical_bayes(terms)
```

## Arguments

- terms:

  Output of
  [`binomial_power_prior_target_terms()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_power_prior_target_terms.md).

## Value

The power parameter.
