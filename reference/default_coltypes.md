# Look up the expected types for a set of columns

Look up the expected types for a set of columns

## Usage

``` r
default_coltypes(expected_colnames)
```

## Arguments

- expected_colnames:

  The column names to look up.

## Value

The subset of
[expected_coltypes](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/expected_coltypes.md)
describing those columns. Columns the spec does not describe are omitted
rather than reported, so that a frame carrying extra bookkeeping columns
still passes.
