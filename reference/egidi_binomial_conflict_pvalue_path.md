# Conflict p-values at many weights at once

[`egidi_binomial_conflict_pvalue()`](https://tristanfauvel.github.io/BExTE/reference/egidi_binomial_conflict_pvalue.md)
at every weight in `psi`, for the cost of sorting the table once rather
than of one pass over it per weight.

## Usage

``` r
egidi_binomial_conflict_pvalue_path(
  table_informative,
  table_weak,
  psi,
  y_control,
  y_treatment,
  tolerance = 1e-09
)
```

## Arguments

- table_informative, table_weak:

  Component tables.

- psi:

  Weights on the weak component.

- y_control, y_treatment:

  Observed responder counts.

- tolerance:

  Relative tolerance used when comparing probabilities.

## Value

The conflict p-value at each weight.

## Details

The mixture is `A + psi (B - A)`, so whether a cell is at or below the
observed one, with the same relative tolerance, is a linear inequality
in `psi`: every cell enters or leaves the conflict set at a single
crossing weight. Sorting the crossings turns the conflict mass at each
weight into a difference of cumulative sums. A cell tied with the
observed one to rounding at exactly one of the weights may be counted
differently than by the direct computation, so a caller that must agree
with it exactly re-checks the weight it selects.
