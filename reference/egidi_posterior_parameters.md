# Per-replicate diagnostics reported by the Egidi mixture prior

Assembles the columns both the scalar and the vectorised paths report,
so the two cannot describe the same run differently.

## Usage

``` r
egidi_posterior_parameters(informative_posterior_weight, selection)
```

## Arguments

- informative_posterior_weight:

  Posterior probability of the informative component.

- selection:

  A data frame from
  [`egidi_select_weak_weight()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/egidi_select_weak_weight.md).

## Value

A data frame with one row per replicate.

## Details

The summariser in
`Model$estimate_frequentist_operating_characteristics()` averages each
column, so the quantities that are proportions are reported as
indicators whose mean is the proportion. The spread of the selected
weight, which no mean can give, comes from `quantile_summary_columns`
instead.

`prior_weight` is the posterior probability that the treatment effect
came from the informative component, which is what the robust mixture
prior reports under that name; the figures and tables that read it
therefore work unchanged. It is not the selected prior weight, which is
`informative_prior_weight`.
