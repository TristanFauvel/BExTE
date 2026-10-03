# Cached prior kernels of the binomial normalized power prior

Cached prior kernels of the binomial normalized power prior

## Usage

``` r
binomial_npp_cached_kernels(
  n_control_source,
  n_successes_control_source,
  n_treatment_source,
  n_successes_treatment_source,
  p,
  q,
  n_lattice = 1000L
)
```

## Arguments

- n_control_source, n_successes_control_source:

  Source control arm.

- n_treatment_source, n_successes_treatment_source:

  Source treatment arm.

- p, q:

  Shape parameters of the Beta prior of the power parameter.

- n_lattice:

  Number of lattice points N on the rates.

## Value

The output of
[`binomial_npp_prior_kernels()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_prior_kernels.md).
