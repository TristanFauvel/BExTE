# Effective sample sizes of a posterior summarised against a normal reference

Both effective sample sizes reported per replicate compare the posterior
against a normal reference of known scale. The moment version uses the
posterior variance directly; the precision version uses the variance a
normal distribution would need in order to have the same 95% credible
interval width. Both are expressed relative to the target study, by
subtracting its per-arm sample size.

Models whose posterior summary is available exactly, or already
computed, evaluate these definitions directly rather than fitting a
mixture to samples drawn from the posterior.

## Usage

``` r
normal_reference_ess(
  reference_scale,
  posterior_sd,
  lower,
  upper,
  sample_size_per_arm
)
```

## Arguments

- reference_scale:

  Reference scale, i.e. the sampling standard deviation of the target
  study.

- posterior_sd:

  Standard deviation of the posterior treatment effect.

- lower:

  Lower bound of the 95% credible interval.

- upper:

  Upper bound of the 95% credible interval.

- sample_size_per_arm:

  Per-arm sample size of the target study.

## Value

A list with the `moment` and `precision` effective sample sizes.
