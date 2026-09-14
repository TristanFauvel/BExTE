# Value identity of an object

Drops the functions and environments an R6 object carries, so that two
separately built objects describing the same study hash alike. Hashing
them whole would key on the identity of each instance instead, and a
model is rebuilt for every scenario.

## Usage

``` r
inference_cache_identity(x)
```

## Arguments

- x:

  Object to reduce to its values.

## Value

The same structure with functions and environments removed.
