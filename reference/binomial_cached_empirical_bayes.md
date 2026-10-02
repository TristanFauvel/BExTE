# Empirical Bayes power parameter of a dataset, cached per worker

The estimate depends on the source and target counts alone. A replicate
served from the inference cache still re-derives its prior for the ELIR,
so the estimate is kept rather than recomputed.

## Usage

``` r
binomial_cached_empirical_bayes(
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

A list with the `power_parameter` and the target `terms`, which are
`NULL` when the estimate came from the cache.
