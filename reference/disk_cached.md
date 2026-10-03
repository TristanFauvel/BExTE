# Read a value from the disk cache, computing and storing it if absent

Shares the binomial prior kernels between the worker processes of a run,
and between runs: a kernel takes from seconds to minutes to compute and
depends only on its key. Writes are atomic, so a process never reads a
partly written file; two processes computing the same value at once both
store the same result.

## Usage

``` r
disk_cached(key, compute, subdirectory = "lattice_kernels")
```

## Arguments

- key:

  A list identifying the value.

- compute:

  A function of no arguments returning the value.

- subdirectory:

  Subdirectory of
  [`bexte_cache_dir()`](https://tristanfauvel.github.io/BExTE/reference/bexte_cache_dir.md).

## Value

The value.
