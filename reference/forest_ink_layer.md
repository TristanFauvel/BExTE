# A point/pointrange layer carrying the palette's ink. Without a palette the colour argument is omitted altogether, leaving ggplot2's default.

A point/pointrange layer carrying the palette's ink. Without a palette
the colour argument is omitted altogether, leaving ggplot2's default.

## Usage

``` r
forest_ink_layer(geom, palette, ...)
```

## Arguments

- geom:

  The ggplot2 layer constructor to call.

- palette:

  A colour scheme from bexte_palette(), or NULL.

- ...:

  Further arguments for `geom`.

## Value

A ggplot2 layer.
