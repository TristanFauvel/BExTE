# Forest-plot colours for a Shiny colour scheme

The forest plots are the only charts the app renders as static images
(they are multi-panel gtables, so they cannot go through bexte_plotly()
like every other chart) and therefore cannot inherit the page's
stylesheet. These helpers take one of bexte_palette()'s schemes and
recolour a subplot for it. `palette = NULL` is the publication figure,
unchanged.

## Usage

``` r
forest_palette_theme(palette)
```

## Arguments

- palette:

  A colour scheme from bexte_palette(), or NULL.

## Value

A ggplot2 theme, or NULL when there is no palette.
