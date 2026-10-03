# Terms of the binomial power prior that depend on the target data

Terms of the binomial power prior that depend on the target data

## Usage

``` r
binomial_power_prior_target_terms(
  n_control_source,
  n_successes_control_source,
  n_treatment_source,
  n_successes_treatment_source,
  n_control,
  n_successes_control,
  n_treatment,
  n_successes_treatment,
  n_lattice = 1000L
)
```

## Arguments

- n_control_source, n_successes_control_source:

  Source control arm.

- n_treatment_source, n_successes_treatment_source:

  Source treatment arm.

- n_control, n_successes_control:

  Target control arm.

- n_treatment, n_successes_treatment:

  Target treatment arm.

- n_lattice:

  Number of lattice points N on the rates.

## Value

A list with `n_lattice`, the risk `differences` (in lattice units) the
target data reach, the N x K matrices `target` (T) and
`source_log_likelihood` (l, `-Inf` where the source treatment rate
leaves \\\[0, 1\]\\), and the source arms' log likelihoods on the
lattice, `source_control_log_likelihood` and
`source_treatment_log_likelihood`.
