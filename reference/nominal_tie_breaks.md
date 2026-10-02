# Axis breaks that always show the nominal type-I error

[`pretty()`](https://rdrr.io/r/base/pretty.html) picks breaks that
ignore the nominal TIE, so forcing the nominal value in alongside them
leaves two labels sitting on top of each other. `check.overlap` resolves
that collision the wrong way round: it draws labels leftmost-first and
discards the nominal tick, which is the one the plot is read against.
Drop the neighbouring pretty breaks instead, so the nominal value is the
only label in its neighbourhood.

## Usage

``` r
nominal_tie_breaks(nominal_tie)
```

## Arguments

- nominal_tie:

  The nominal type-I error rate, or `NULL` when the scale has no nominal
  value to mark.

## Value

A function of the scale limits returning a sorted break vector.
