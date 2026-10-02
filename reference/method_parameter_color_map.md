# Colours for the parameter values present in one method's rows

The plot code carries two spellings of each parameter label: the
plotmath expression the legend is drawn with, and the plain text it was
built from. Only the plain text still holds the numbers that place a
value on its method's ramp, while the scale has to be keyed by the
expression the layers map to, so the two are paired up row by row here.

## Usage

``` r
method_parameter_color_map(df_subset, method, ...)
```

## Arguments

- df_subset:

  One method's rows, carrying `parameters_labels` and
  `parameters_labels_not_latex`.

- method:

  The method key or display label.

- ...:

  Passed on to
  [`method_parameter_colors()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/method_parameter_colors.md).

## Value

A character vector of hex colours, named by the plotmath labels.
