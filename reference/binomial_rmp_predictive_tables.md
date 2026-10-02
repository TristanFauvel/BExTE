# Prior-predictive tables of the binomial robust mixture components

The prior-predictive probability of every pair of target responder
counts under each component, as the matrices
[`egidi_binomial_conflict_pvalue()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/egidi_binomial_conflict_pvalue.md)
reads: one row per control count and one column per treatment count. On
the lattice, the table is `t(B_c) K B_t`, with `K` the component in
target control and treatment rates and `B` the binomial probabilities of
each count at each rate.

## Usage

``` r
binomial_rmp_predictive_tables(
  components,
  source_counts,
  n_control,
  n_treatment
)
```

## Arguments

- components:

  Output of
  [`binomial_rmp_components()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_rmp_components.md).

- source_counts:

  The source counts the components were built from, which identify them
  in the cache.

- n_control, n_treatment:

  Target arm sizes.

## Value

A list with `informative` and `weak` tables.
