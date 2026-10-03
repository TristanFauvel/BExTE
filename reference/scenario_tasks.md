# Split the scenarios into the tasks handed to the workers

One task per scenario, unless the scenarios share analyses across
drifts: then a task holds the scenarios that differ only in the drift,
so that one worker analyses the design's outcomes once and serves every
drift from its cache. When there are fewer such groups than workers,
each group is cut into contiguous pieces, as few as keep every worker
busy, since a group on one worker would otherwise leave the others idle.

## Usage

``` r
scenario_tasks(cases, shares_across_drifts, n_workers)
```

## Arguments

- cases:

  The scenario table, one row per scenario.

- shares_across_drifts:

  Whether the scenarios share analyses across drifts - see
  [`analyses_shared_across_drifts()`](https://tristanfauvel.github.io/BExTE/reference/analyses_shared_across_drifts.md).

- n_workers:

  Number of workers.

## Value

A list of integer vectors, the rows of `cases` in each task. Each row
appears in exactly one task, and in increasing order within it.
