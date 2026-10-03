# Function to plot metric vs sample size

This function plots a metric against the sample size for a given method,
case study, and parameters combinations.

## Usage

``` r
plot_metric_vs_sample_size_methods(
  metric,
  results_metrics_df,
  case_study,
  theta_0 = 0,
  target_to_source_std_ratio = 1,
  source_denominator_change_factor = 1,
  dodging = FALSE,
  join_points = FALSE,
  target_treatment_effect = target_treatment_effect
)
```

## Arguments

- metric:

  The metric to plot.

- results_metrics_df:

  The data frame containing the results and metrics.

- case_study:

  The case study to plot the metric for.

- theta_0:

  Boundary of the null hypothesis space.

- target_to_source_std_ratio:

  Ratio between the target and source studies sampling standard
  deviation.

- source_denominator_change_factor:

  The source denominator change factor of the scenario to keep.

- dodging:

  Currently unused.

- join_points:

  Whether to join the point with a line or not.

- target_treatment_effect:

  Which of the three main treatment effects to keep: "No effect",
  "Partially consistent effect" or "Consistent effect".

## Value

None
