# Compute the frequentist power at equivalent tie

This function computes the frequentist power at equivalent tie for a
given set of results and analysis configuration.

## Usage

``` r
frequentist_power_at_equivalent_tie(
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

- n_replicates:

  Number of Monte Carlo replicates the simulated power estimates are
  built from, for the case studies analytical_power() cannot be used
  for.

- trial_cache:

  Optional environment holding the simulated trials of each design,
  filled here and read back by
  [`frequentist_power_at_nominal_tie()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/frequentist_power_at_nominal_tie.md),
  whose separate and pooled powers read the same trials. `NULL` keeps
  them for this call only.

- cluster:

  Optional shared cluster from `new_analysis_cluster()`, as
  [`simulation_analysis()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/simulation_analysis.md)
  passes it. `NULL` starts one for this call if the work warrants it.

## Value

The final results data frame with power and frequentist test columns
added.
