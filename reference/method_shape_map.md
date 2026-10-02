# Shapes for a set of methods, keyed by method

A named vector, so `scale_shape_manual()` matches by name instead of by
position. The codes used to be handed out as
`shape_codes[1:length(unique_methods)]` over the methods present in one
figure, which meant a case study missing a method shifted the shape of
every method after it.

## Usage

``` r
method_shape_map(
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

A named numeric vector of plotting characters.
