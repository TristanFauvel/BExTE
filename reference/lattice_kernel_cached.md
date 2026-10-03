# A lattice prior kernel, kept in memory and on disk

Kept in
[binomial_npp_cache_store](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_cache_store.md)
for the process, and on disk through
[`disk_cached()`](https://tristanfauvel.github.io/BExTE/reference/disk_cached.md)
so that the other workers of a run, and later runs, read it instead of
computing it again. A kernel set is up to five N x (2N - 1) matrices, 80
MB at N = 1000; a worker runs one method's priors at a time, so a few
are kept in memory and no more.

## Usage

``` r
lattice_kernel_cached(key, compute, limit = 6L)
```

## Arguments

- key:

  A list identifying the kernel.

- compute:

  A function of no arguments computing it.

- limit:

  Number of entries kept in memory.

## Value

The kernel.
