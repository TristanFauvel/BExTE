# Whether a case study's operating characteristics are enumerated

`scenarios_config$exact_enumeration`, when present, lists the case
studies whose operating characteristics are computed exactly by
enumerating the trial outcomes rather than by simulating replicates.
Only binary endpoints analysed from their responder counts can be
enumerated: the binomial likelihood, or the normal one without the
sampling approximation.

## Usage

``` r
case_study_exact_enumeration(scenarios_config, case_study)
```

## Arguments

- scenarios_config:

  The scenarios configuration.

- case_study:

  The case study name.

## Value

`TRUE` or `FALSE`.
