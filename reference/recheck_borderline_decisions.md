# Recompute, on the full mixture, test decisions too close to call

The compressed mixture reproduces the posterior probability of the
alternative to within its tolerance, so a replicate whose probability
lies within `margin` of the critical value could in principle be decided
differently. Those few are decided again on the full mixture, so that
the compression cannot change a decision.

## Usage

``` r
recheck_borderline_decisions(
  test_decisions,
  posterior,
  mixture,
  estimate,
  standard_error,
  critical_value,
  theta_0,
  null_space,
  margin = 1e-08
)
```

## Arguments

- test_decisions:

  Decisions taken on the compressed mixture.

- posterior:

  Compressed posterior, from
  [`normal_mixture_posterior()`](https://tristanfauvel.github.io/BExTE/reference/normal_mixture_posterior.md).

- mixture:

  Full prior mixture.

- estimate:

  Treatment effect estimates.

- standard_error:

  Their standard errors.

- critical_value:

  Critical posterior probability.

- theta_0:

  Null hypothesis value.

- null_space:

  Either `"left"` or `"right"`.

- margin:

  Distance from the critical value within which a decision is
  recomputed.

## Value

The decisions, with the borderline ones taken on the full mixture.
