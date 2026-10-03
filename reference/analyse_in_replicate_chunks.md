# Run a vectorised analysis of the replicates in chunks

A vectorised analysis holds several `n_replicates x n_components`
matrices at once, which for a mixture of hundreds of components and ten
thousand replicates reaches gigabytes per worker, and limits how many
workers a machine can run. Every replicate is analysed on its own, so
the analysis can run on consecutive chunks of replicates and the results
be concatenated, with the same result and a peak memory bounded by the
chunk.

## Usage

``` r
analyse_in_replicate_chunks(samples, analyse, chunk_size = 1000L)
```

## Arguments

- samples:

  Data frame of generated replicates, one row each.

- analyse:

  Function of a chunk of `samples` returning the list that
  [`vectorised_normal_mixture_simulation()`](https://tristanfauvel.github.io/BExTE/reference/vectorised_normal_mixture_simulation.md)
  returns.

- chunk_size:

  Number of replicates per chunk.

## Value

The list `analyse` returns, over every replicate.
