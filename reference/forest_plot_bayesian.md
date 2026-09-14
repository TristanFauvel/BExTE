# Generate a forest plot for bayesian metrics

This function generates a forest plot based on the provided results
dataframe, selected case study, and selected target sample size per arm.

## Usage

``` r
forest_plot_bayesian(results_bayes_df, x_metric, palette = NULL)
```

## Arguments

- results_bayes_df:

  The results dataframe.

- x_metric:

  Metric on the x-axis

- palette:

  A colour scheme from bexte_palette() for the Shiny app's dark mode, or
  NULL for the publication figure.

- selected_case_study:

  The selected case study.

- selected_target_sample_size_per_arm:

  The selected target sample size per arm.

## Value

None
