# Base hues for a set of methods, keyed by method

The companion to
[`method_shape_map()`](https://tristanfauvel.github.io/BExTE/reference/method_shape_map.md),
for the figures that colour by method rather than by parameter value.

## Usage

``` r
method_hue_map(
  methods,
  styles = methods_style,
  labels = style_methods_labels()
)
```

## Arguments

- methods:

  Method keys or display labels.

- styles:

  The style table.

- labels:

  The method label table.

## Value

A named character vector of hex colours.
