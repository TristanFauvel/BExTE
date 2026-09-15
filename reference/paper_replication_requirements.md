# Minimal simulation config for a set of paper figures

Folds the selected manifest entries into a `scenarios_config` covering
exactly the case studies, sample size factors and methods they need.
Each case study is restricted to its own factors through
`case_study_sample_size_factors`, rather than every case study being
crossed with every factor. The fidelity settings do not scale with the
selection: `ndrift` stays at 30 because
[`forest_plot()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/forest_plot.md)
selects the three principal treatment-effect scenarios by nearest grid
point, so a coarser grid would quietly plot different drift values
rather than failing.

No paper figure varies the source denominator change factor or the
target-to-source standard deviation ratio, so both are pinned to 1.

## Usage

``` r
paper_replication_requirements(ids, case_studies_config_dir)
```

## Arguments

- ids:

  Manifest ids to cover.

- case_studies_config_dir:

  Directory holding the case study YAMLs.

## Value

A `scenarios_config` list, ready for `save_environment()`.
