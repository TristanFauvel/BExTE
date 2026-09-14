# Test decision for every replicate at once

Compares the posterior probability of the alternative hypothesis with
`critical_value`, matching `Model$test_decision()`.

## Usage

``` r
vectorised_test_decision(
  posterior_weights,
  posterior_means,
  posterior_sds,
  critical_value,
  theta_0,
  null_space
)
```

## Arguments

- posterior_weights:

  `n_replicates x n_components` posterior weights.

- posterior_means:

  `n_replicates x n_components` posterior means.

- posterior_sds:

  `n_replicates x n_components` posterior standard deviations.

- critical_value:

  Critical posterior probability.

- theta_0:

  Null hypothesis value.

- null_space:

  Either `"left"` or `"right"`.

## Value

Logical vector of decisions.
