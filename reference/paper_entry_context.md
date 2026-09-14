# Build the context one manifest entry's generator receives

The generators take the slice already narrowed to their own case study,
sample size, denominator factor and standard deviation ratio, mirroring
what the loop functions in inst/scripts/plots.R pass them.

## Usage

``` r
paper_entry_context(
  entry,
  results_df,
  results_dir,
  tables_dir,
  case_studies_config_dir,
  case_studies,
  sample_size_factors,
  analysis_config
)
```
