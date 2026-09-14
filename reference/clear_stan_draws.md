# Remove the Stan draws of one model across every process

Each process writes to its own directory, so one run leaves a directory
per worker behind. They hold intermediate MCMC output that runs to
gigabytes for the larger case studies, so a finished run clears them.
The prefix is taken from `stan_draws_directory()` rather than rebuilt
here, so the two cannot drift apart.

## Usage

``` r
clear_stan_draws(
  case_study,
  method,
  root = dirname(stan_draws_directory(case_study, method))
)
```

## Arguments

- case_study:

  Case study name.

- method:

  Method name.

- root:

  Directory the per-process directories sit in.

## Value

Paths of the directories that were removed, invisibly.
