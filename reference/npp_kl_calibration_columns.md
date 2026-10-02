# The calibration columns reported with every replicate

These are constant within a scenario: the prior is calibrated once from
the design and reused for every replicate. They are repeated for each
replicate anyway because the reporting layer averages every column of
the posterior parameters over the replicates
(`estimate_frequentist_operating_characteristics()`), so a constant
column arrives in the results as that constant.

`calibration_id` is deliberately absent: that averaging would turn a
character column into `NA`. The calibration unit is identifiable in the
results from `alpha_gamma`, `beta_gamma`, `d_mtd` and
`se_target_expected`.

## Usage

``` r
npp_kl_calibration_columns(calibration, n_replicates)
```

## Arguments

- calibration:

  A list from
  [`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md).

- n_replicates:

  Number of rows to produce.

## Value

A data frame of `n_replicates` identical rows.
