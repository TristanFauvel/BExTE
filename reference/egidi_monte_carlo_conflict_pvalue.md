# Prior-predictive conflict p-value by simulation

The Monte Carlo fallback of
[`egidi_normal_conflict_pvalue()`](https://tristanfauvel.github.io/BExTE/reference/egidi_normal_conflict_pvalue.md),
for checking the deterministic calculation and for sampling
distributions with no closed-form level sets. Egidi, Pauli and Torelli
used 1000 hypothetical replications; the deterministic route is
preferred in the simulation study because a nested Monte Carlo error
would propagate into every operating characteristic.

## Usage

``` r
egidi_monte_carlo_conflict_pvalue(
  t_obs,
  psi,
  mu_p,
  sigma_p,
  mu_q,
  sigma_q,
  draws = 1000L,
  seed = NULL
)
```

## Arguments

- t_obs:

  Observed target statistic, a single value.

- psi:

  Weight on the weak component, a single value.

- mu_p, sigma_p:

  Informative component predictive mean and standard deviation.

- mu_q, sigma_q:

  Weak component predictive mean and standard deviation.

- draws:

  Number of hypothetical replications.

- seed:

  Optional seed, so that a replicate's p-value is reproducible.

## Value

A list with the estimate `pvalue` and its `standard_error`.

## Details

The estimator adds one to the numerator and the denominator, which keeps
the p-value away from zero and makes it the usual randomisation-test
estimator. Drawing the component indicator and both component values up
front means the same underlying uniforms serve every candidate weight,
so the p-values compared across candidates differ only through the
weight.
