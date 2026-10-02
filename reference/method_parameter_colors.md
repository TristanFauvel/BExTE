# Colours for the parameter values of one method

Shades of the method's hue, light for low parameter values and dark for
high ones. Returned named by the labels asked for, so that
`scale_color_manual()` is a lookup rather than a position - which is
what keeps a parameter value the same colour from one figure to the
next. These colours used to come from an unseeded
[`sample()`](https://rdrr.io/r/base/sample.html) over a 50-colour
palette, so they differed between two runs of the same figure.

## Usage

``` r
method_parameter_colors(
  method,
  parameter_labels,
  styles = methods_style,
  dict = style_methods_dict(),
  labels = style_methods_labels()
)
```

## Arguments

- method:

  A method key or display label.

- parameter_labels:

  The labels to colour, as plain text.

- styles:

  The style table.

- dict:

  The run's methods configuration.

- labels:

  The method label table.

## Value

A named character vector of hex colours.
