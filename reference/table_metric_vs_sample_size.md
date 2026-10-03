# Plot metric vs sample size

Plot metric vs sample size

## Usage

``` r
table_metric_vs_sample_size(
  metric,
  results_metrics_df,
  case_study,
  method,
  theta_0 = 0,
  source_denominator_change_factor = 1,
  target_to_source_std_ratio = 1,
  wide_table = TRUE
)
```

## Arguments

- metric:

  The metric to be plotted

- results_metrics_df:

  A dataframe containing the results metrics

- case_study:

  The case study being analyzed

- method:

  The method being used

- theta_0:

  The null hypothesis value

- source_denominator_change_factor:

  The source denominator change factor of the scenario to keep.

- target_to_source_std_ratio:

  Ratio between the target and source studies sampling standard
  deviation.

- wide_table:

  Whether to pivot the table so that each parameter combination gets its
  own column.

## Value

Generates and saves tables in HTML, PDF, and LaTeX formats
