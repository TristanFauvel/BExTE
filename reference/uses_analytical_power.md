# Whether power can be computed analytically for this target data

The analytical power formulas apply to a normal summary measure on a
continuous endpoint; the remaining endpoints have to be simulated.
Sharing the predicate keeps the power computation and the propagation of
its uncertainty on the same branch.

## Usage

``` r
uses_analytical_power(target_data, case_study = NULL)
```

## Arguments

- target_data:

  Target data object.

- case_study:

  Optional case-study name.

## Value

`TRUE` when power has a closed form for this target data.
