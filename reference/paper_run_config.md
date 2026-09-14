# The simulation config a results directory was produced from

`save_environment()` writes each run's `scenarios_config.yml` under
`user_configs/<env>/`, and the results directory carries the same name.
Returns `NULL` when there is no such file - some older results
directories predate the convention.

## Usage

``` r
paper_run_config(results_dir, user_configs_dir = "user_configs")
```

## Arguments

- results_dir:

  A results directory, e.g. `"results/minimal_test"`.

- user_configs_dir:

  Directory holding the per-environment configs.

## Value

The parsed `scenarios_config`, or `NULL`.
