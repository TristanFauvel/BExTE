# Key of a set of generated replicates

Hashes everything the generated replicates depend on: the target data's
class, every field it holds except the per-replicate `sample`, which the
replicate loop overwrites, the code of its `generate()` method, the
replicate count and the random number generator state.

## Usage

``` r
generation_cache_key(target_data, n_replicates)
```

## Arguments

- target_data:

  Target data object.

- n_replicates:

  Number of replicates.

## Value

A hash string.
