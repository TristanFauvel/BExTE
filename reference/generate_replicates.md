# Generate the replicates of a scenario, reusing them across methods

Equivalent to `target_data$generate(n_replicates)`, with the same result
and the same random number generator state afterwards. When `cache_dir`
is given and generation is slow enough to be worth storing, the
replicates are written there, and a later call with the same target
data, replicate count and generator state reads them back instead.

## Usage

``` r
generate_replicates(
  target_data,
  n_replicates,
  cache_dir = NULL,
  min_seconds = 0.25
)
```

## Arguments

- target_data:

  Target data object.

- n_replicates:

  Number of replicates.

- cache_dir:

  Directory to store replicates in, or `NULL` to generate them every
  time.

- min_seconds:

  Generation time below which replicates are not stored, because
  regenerating them is cheaper than reading them back.

## Value

The generated replicates.
