# Generate a forest plot

This function generates a forest plot based on the provided results
dataframe, selected case study, and selected target sample size per arm.

## Usage

``` r
forest_plot(
  results_freq_df,
  x_metric,
  panels = TRUE,
  palette = NULL,
  relative_to_separate = FALSE,
  filename_suffix = "",
  subtitle = NULL
)
```

## Arguments

- results_freq_df:

  The results dataframe.

- x_metric:

  Metric on the x-axis

- panels:

  If TRUE, draw one panel per treatment effect (no effect, partially
  consistent, consistent); otherwise draw the three in a single combined
  plot.

- palette:

  A colour scheme from bexte_palette() for BExTE-app's dark mode, or
  NULL for the publication figure.

- relative_to_separate:

  When TRUE, divide the metric and its confidence bounds by the separate
  analysis's value in the same scenario, label the axis accordingly, and
  draw a reference line at 1. Used by supplementary figures S9, S14,
  S17, S27, S32 and S37.

- filename_suffix:

  Appended to the generated filename, to keep apart plots of the same
  slice under different time-to-event designs (figures S45-S47), which
  would otherwise share one file.

- subtitle:

  Optional line drawn above the panels.

## Value

None
