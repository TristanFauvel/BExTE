# Exact discrete conflict p-value for a two-arm binomial target

The discrete counterpart of
[`egidi_normal_conflict_pvalue()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/egidi_normal_conflict_pvalue.md):
the total prior-predictive probability of every pair of response counts
whose probability is at or below that of the observed pair.

## Usage

``` r
egidi_binomial_conflict_pvalue(
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

  Component tables from
  [`binomial_rmp_predictive_tables()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_rmp_predictive_tables.md).

- psi:

  Weight on the weak component, one value.

- y_control, y_treatment:

  Observed responder counts.

- tolerance:

  Relative tolerance used when comparing probabilities.

## Value

The conflict p-value.

## Details

Ties are possible on a finite sample space and matter, because a cell
excluded by a rounding difference removes its whole probability from the
sum rather than an infinitesimal amount. The comparison therefore
carries a relative tolerance.
