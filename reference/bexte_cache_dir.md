# Directory of BExTE's disk caches

Under `BEXTE_CACHE_DIR` when it is set, and
`tools::R_user_dir("BExTE", "cache")` otherwise. Everything stored there
is a deterministic function of its key, so it can be deleted at any
time.

## Usage

``` r
bexte_cache_dir(subdirectory)
```

## Arguments

- subdirectory:

  The cache's own subdirectory.

## Value

A directory path, created if needed.
