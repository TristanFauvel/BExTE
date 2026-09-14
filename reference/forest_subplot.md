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
  reference_line = NULL
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

- palette:

  A colour scheme from bexte_palette() for the Shiny app's dark mode, or
  NULL for the publication figure.

- reference_line:

  x position of a dotted vertical reference line, or NULL for none.

## Value

A ggplot2::ggplot( object representing the forest plot.
