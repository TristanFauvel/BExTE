# Create a forest plot

This function creates a forest plot using the provided data.

## Usage

``` r
forest_subplot(
  data,
  title,
  ylabel,
  x_metric_name,
  x_metric_uncertainty_lower,
  x_metric_uncertainty_upper,
  x_metric_label,
  methods_labels,
  legend = FALSE,
  sort_by = FALSE,
  palette = NULL,
  reference_line = NULL,
  ess_limits = NULL,
  ess_midpoint = NULL,
  nominal_tie_line = NULL
)
```

## Arguments

- data:

  The data for creating the forest plot.

- title:

  The title of the forest plot.

- ylabel:

  A logical value indicating whether to display the y-axis label.

- x_metric_name:

  Name of the metric on the x-axis

- x_metric_uncertainty_lower:

  Lower limit of the metric on the x-axis

- x_metric_uncertainty_upper:

  Upper limit of the metric on the x-axis

- x_metric_label:

  Label of the metric on the x-axis

- methods_labels:

  Display labels of the methods, as defined by sourcing
  `methods_plots_config.R`.

- legend:

  Whether to draw a legend for the reference lines.

- sort_by:

  `"methods_parameters"` to order each method's rows by its parameter
  values, `"value"` to order the rows by the metric, or FALSE to keep
  the input order.

- palette:

  A colour scheme from bexte_palette() for BExTE-app's dark mode, or
  NULL for the publication figure.

- reference_line:

  x position of a dotted vertical reference line, or NULL for none.

- ess_limits:

  Limits of the moment-based ESS fill scale, so that several panels can
  share one scale, or NULL for the range of `data`.

- ess_midpoint:

  Midpoint of the ESS fill scale, or NULL for
  `forest_ess_midpoint(data)`.

- nominal_tie_line:

  x position of a dashed line marking the nominal type I error rate, or
  NULL for none.

## Value

A ggplot object representing the forest plot.
