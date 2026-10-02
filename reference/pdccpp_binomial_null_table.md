# Where the binomial analysis rejects, for every outcome under the null

For every pair of target responder counts under the null hypothesis
(control rate `control_rate`, treatment rate `control_rate + theta_0`),
the power parameters at which the binomial conditional power prior
rejects the null hypothesis: the posterior probability that the
treatment effect lies beyond `theta_0` on the alternative side is
evaluated on a grid of 21 power parameters, and each crossing of
`critical_value` is refined by `uniroot`. Pairs whose total probability
is below `tail_mass` are omitted, as in
`BinaryTargetData$enumerate_support()`.

The table depends on the source counts and the design alone, so it is
saved under
[`pdccpp_binomial_cache_dir()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/pdccpp_binomial_cache_dir.md)
and read back by any process that needs it; `workers` computes it in
parallel.

## Usage

``` r
pdccpp_binomial_null_table(
  n_control_source,
  n_successes_control_source,
  n_treatment_source,
  n_successes_treatment_source,
  n_control,
  n_treatment,
  control_rate,
  theta_0,
  null_space,
  critical_value,
  n_lattice = 1000L,
  tail_mass = 1e-10,
  workers = 1L
)
```

## Arguments

- n_control_source, n_successes_control_source:

  Source control arm.

- n_treatment_source, n_successes_treatment_source:

  Source treatment arm.

- control_rate:

  Target control rate of the design.

- theta_0:

  Boundary of the null hypothesis space.

- null_space:

  `"left"` or `"right"`.

- critical_value:

  Posterior probability the analysis decides at.

- n_lattice:

  Number of lattice points N on the rates.

- tail_mass:

  Probability of the omitted pairs.

- workers:

  Number of processes.

## Value

A list with, per pair, the `estimate`, `standard_error`, `weight`,
`reject_at_zero` (whether it rejects at a power parameter of 0) and
`crossings` (a list of the power parameters where that changes).
