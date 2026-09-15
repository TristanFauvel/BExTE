# Check a results frame against a set of paper figures

Check a results frame against a set of paper figures

## Usage

``` r
paper_replication_coverage(
  results_df,
  ids,
  case_studies_config_dir,
  run_config = NULL
)
```

## Arguments

- results_df:

  A frequentist results frame.

- ids:

  Manifest ids to check.

- case_studies_config_dir:

  Directory holding the case study YAMLs.

- run_config:

  Optionally the `scenarios_config` the results were produced from (see
  [`paper_run_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/paper_run_config.md)).
  When given, a directory that falls short of the paper's fidelity
  covers no figure at all, however many rows it holds - see
  [`paper_config_shortfalls()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/paper_config_shortfalls.md).
  Tables are unaffected: they are built from the case study YAMLs, not
  from simulation output.

## Value

A data frame with columns `id`, `covered` and `reason`.
