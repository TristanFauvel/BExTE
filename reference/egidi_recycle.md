# Recycle Egidi mixture arguments to a common length

The conflict p-value is evaluated once per replicate, and each of the
replicate-varying quantities may arrive as a scalar shared by every
replicate or as one value per replicate. Recycling them here keeps every
downstream expression a plain elementwise one.

## Usage

``` r
egidi_recycle(...)
```

## Arguments

- ...:

  Named numeric vectors.

## Value

A list of the same names, each recycled to the longest length.
