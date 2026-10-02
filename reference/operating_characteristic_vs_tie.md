# Plot an operating characteristic against the type I error rate

Draws one point per method and parameter combination, placing the
operating characteristic against the type I error rate that method
incurs, so that methods can be compared at the error rate they actually
spend rather than at their nominal one.

## Usage

``` r
operating_characteristic_vs_tie(
  results_metrics_df,
  case_study,
  target_sample_size_per_arm,
  treatment_effect,
  operating_characteristic,
  source_denominator_change_factor,
  target_to_source_std_ratio,
  show_tie_error_bars = FALSE
)
```

## Arguments

- results_metrics_df:

  The dataframe containing the results and metrics.

- case_study:

  The case study name.

- target_sample_size_per_arm:

  The target sample size per arm.

- treatment_effect:

  The treatment effect scenario ("consistent", "no_effect" or
  "partially_consistent").

- operating_characteristic:

  The metric to plot, as an entry of `frequentist_metrics` or
  `inference_metrics`.

- source_denominator_change_factor:

  The source denominator change factor.

- target_to_source_std_ratio:

  The target to source standard deviation ratio.

- show_tie_error_bars:

  Whether to draw the Monte Carlo interval on the type I error axis.

## Value

None
