# How a results directory falls short of the paper's fidelity

Which scenarios a directory holds is visible in its rows, and
[`paper_replication_coverage()`](https://tristanfauvel.github.io/BExTE/reference/paper_replication_coverage.md)
checks that. How they were simulated is not: a directory holding 2 of
the 11 methods at 1000 replicates yields figures that look like the
paper's but compare two methods at a tenth of the Monte Carlo precision.
Only the config the run was launched from can show that, so the two
checks are kept separate - this one is a property of the whole directory
rather than of any single figure.

## Usage

``` r
paper_config_shortfalls(run_config, requirements)
```

## Arguments

- run_config:

  A parsed `scenarios_config`, or `NULL` if none was found.

- requirements:

  A
  [`paper_replication_requirements()`](https://tristanfauvel.github.io/BExTE/reference/paper_replication_requirements.md)
  list.

## Value

A character vector of shortfalls; empty when the config is faithful.
