# Key for one replicate analysis

Key for one replicate analysis

## Usage

``` r
inference_cache_key(scope, sample)
```

## Arguments

- scope:

  Scenario identity, or `NULL` when the model is not cacheable.

- sample:

  One generated replicate, as a single row data frame.

## Value

A key, or `NULL` when the analysis must not be cached.
