# Generate a metric vs drift table

Generate a metric vs drift table

## Usage

``` r
table_metric_vs_drift(
  metric,
  results_metrics_df,
  theta_0,
  case_study,
  method,
  category,
  control_drift,
  target_sample_size_per_arm,
  parameters_combinations,
  xvars,
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

- theta_0:

  The null hypothesis value

- case_study:

  The case study being analyzed

- method:

  The method being used

- category:

  The category of analysis ('parameters' or
  'target_sample_size_per_arm')

- control_drift:

  Boolean indicating whether to control for drift

- target_sample_size_per_arm:

  The target sample size per arm

- parameters_combinations:

  The combinations of parameters

- xvars:

  A list containing x-axis variable information

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
