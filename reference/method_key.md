# Resolve a method to its configuration key

The plot code overwrites `results_df$method` with the display label
before it builds the scales, so a method reaches the style helpers as
either `"conditional_power_prior"` or `"Conditional PP"`. Both have to
land on the same entry.

## Usage

``` r
method_key(method, labels = style_methods_labels())
```

## Arguments

- method:

  A method key or display label.

- labels:

  The method label table.

## Value

The method key, or the input unchanged when no label matches.
