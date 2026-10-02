# Are there parameters left to condition a plot or table on?

The metric-versus-parameters plots and tables loop over one of a
method's parameters at a time and condition on the rest, taken as
`parameters[, -i]`. Whether any rest remain is not the same question as
whether that frame has rows. A method carrying a single parameter -
separate and pooling carry only `initial_prior` - loses its only column,
and a data frame with no columns keeps every one of its rows, so
[`nrow()`](https://rdrr.io/r/base/nrow.html) still reports something to
loop over. The loop then asks for a label for a row that holds nothing,
which fails with `invalid subscript type 'list'`.

A remainder that has collapsed to a bare vector also counts as nothing,
which is what these call sites have always done.

## Usage

``` r
has_other_parameters(other_parameters)
```

## Arguments

- other_parameters:

  The remaining parameters, as returned by `parameters[, -i]`.

## Value

`TRUE` when there is at least one parameter left to condition on.
