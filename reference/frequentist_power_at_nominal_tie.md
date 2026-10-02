# Compute the frequentist power at the nominal type I error rate

Computes the power of the separate and the pooled analysis at the
nominal type I error rate, which the plots use as the two baselines
every borrowing method is read against.

Both baselines are a property of the design alone, while the results
frame holds one row per design *and* method-parameter combination: the
paper's environment repeats each of its 330 designs 56 times. They are
therefore computed once per design and copied to the rows that share it.
That is exact rather than an approximation, because
[`simulate_test_p_values()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/simulate_test_p_values.md)
reseeds from `simulation_config$seed` on every call, so the repeats were
identical to the last bit anyway.

## Usage

``` r
frequentist_power_at_nominal_tie(
  results,
  analysis_config,
  simulation_config,
  parallelization = FALSE,
  n_replicates = 1000,
  trial_cache = NULL,
  cluster = NULL
)
```

## Arguments

- results:

  The results data frame.

- analysis_config:

  The analysis configuration.

- simulation_config:

  The simulation configuration.

- parallelization:

  Whether the caller asked for parallelism, as
  `analysis_runs_in_parallel()` resolves it. A design costs seconds
  here - two power computations, either of which may be a simulation -
  so a run with many of them is worth spreading over a cluster.

- n_replicates:

  Number of Monte Carlo replicates the simulated power estimates are
  built from, for the case studies analytical_power() cannot be used
  for.

- trial_cache:

  Optional environment of simulated trials left by
  [`frequentist_power_at_equivalent_tie()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/frequentist_power_at_equivalent_tie.md).
  Both baselines read the same trials, so a design found there is not
  simulated again.

- cluster:

  Optional shared cluster from `new_analysis_cluster()`. `NULL` starts
  one for this call if the work warrants it.

## Value

The results data frame with the six baseline power columns added.
