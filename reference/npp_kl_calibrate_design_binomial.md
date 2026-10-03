# Calibrate the KL normalized power prior on binomial likelihoods

The criterion of
[`calibrate_npp_kl()`](https://tristanfauvel.github.io/BExTE/reference/calibrate_npp_kl.md) -
the same two hypothetical target results, reference distributions,
weights, bounds and optimiser - with the posterior of the power
parameter computed from the binomial marginal likelihood of each result,
[`npp_kl_binomial_log_marginals()`](https://tristanfauvel.github.io/BExTE/reference/npp_kl_binomial_log_marginals.md),
instead of the normal one.

## Usage

``` r
npp_kl_calibrate_design_binomial(
  source_counts,
  source,
  target_data,
  theta_0,
  settings,
  n_lattice = 1000L,
  n_nodes = 80L
)
```

## Arguments

- source_counts:

  List of the four source counts.

- source:

  The source data, with `treatment_effect_estimate`.

- target_data:

  Target study data for the scenario, a binary design.

- theta_0:

  Boundary of the null hypothesis space.

- settings:

  Output of
  [`npp_kl_settings()`](https://tristanfauvel.github.io/BExTE/reference/npp_kl_settings.md).

- n_lattice:

  Number of lattice points.

- n_nodes:

  Quadrature nodes of the Beta prior.

## Value

A list with the fields of
[`calibrate_npp_kl()`](https://tristanfauvel.github.io/BExTE/reference/calibrate_npp_kl.md)'s
result.
