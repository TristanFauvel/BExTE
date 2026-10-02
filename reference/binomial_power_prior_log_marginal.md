# Log marginal likelihood of the target data under the binomial power prior

Up to a constant that does not depend on the power parameter. The source
log likelihoods are shifted to a maximum of zero; the shift multiplies
the numerator and Z_S(gamma) alike, so it cancels.

## Usage

``` r
binomial_power_prior_log_marginal(
  terms,
  power_parameter,
  bilinear = binomial_power_prior_bilinear(terms)
)
```

## Arguments

- terms:

  Output of
  [`binomial_power_prior_target_terms()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_power_prior_target_terms.md).

- power_parameter:

  Power parameters in 0, 1.

## Value

One log marginal likelihood per power parameter.
