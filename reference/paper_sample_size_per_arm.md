# Resolve a sample size factor to a target sample size per arm

Mirrors the arithmetic the simulation itself uses
(R/simulation_scenarios.R): the total target sample size is the source
study's arm sizes summed and divided by the factor, and the per-arm size
is half of that, floored. Note this uses `control + treatment` rather
than the `total:` field, which is stale for aprepitant.

## Usage

``` r
paper_sample_size_per_arm(case_study, factor, case_studies_config_dir)
```

## Arguments

- case_study:

  Case study name.

- factor:

  Sample size factor.

- case_studies_config_dir:

  Directory holding the case study YAMLs, trailing slash included.

## Value

The target sample size per arm, as an integer.
