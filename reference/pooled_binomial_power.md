# Power of the pooled two-proportion test, the source counts held fixed

The pooled analysis adds the source study's responders to the target's
and tests the pooled response rates with the arcsine two-sample test
that
[`pwr::pwr.2p2n.test()`](https://rdrr.io/pkg/pwr/man/pwr.2p2n.test.html)
describes. The source counts are the ones observed, fixed across the
simulated trials, so the rejection rate is summed over the target
responder counts alone, weighted by their binomial probabilities.
[`pwr::pwr.2p2n.test()`](https://rdrr.io/pkg/pwr/man/pwr.2p2n.test.html)
itself would treat the pooled counts as a fresh sample of the pooled
size, and so overstate how much the pooled rates vary from one trial to
the next.

The test is of equal response rates, i.e. a null boundary of zero.

## Usage

``` r
pooled_binomial_power(alpha, target_data, source_data, alternative)
```

## Arguments

- alpha:

  One-sided significance level.

- target_data:

  Target data, with its true response rates.

- source_data:

  Source data.

- alternative:

  "greater" or "less".

## Value

The power.
