# Track how many scenarios of a run have been simulated.

`total` counts the scenarios of the whole run - every case study and
method it covers - whereas the callbacks that drive the console progress
bar count within the case study/method block being worked on: `foreach`
calls `.options.snow$progress` with the number of tasks finished so far,
and the sequential loop passes its own index. `starting()` rebases on a
block boundary so `tick()` can take those block-local counts and still
record a run-wide total.

## Usage

``` r
run_progress_tracker(env, total)
```

## Arguments

- env:

  Name of the environment being run.

- total:

  Number of scenarios the run covers.

## Value

A list with `path`, `starting(case_study, method)` and `tick(n)`.

## Details

Creating a tracker resets the environment's progress file, so a relaunch
starts from zero rather than resuming whatever the previous run left.
