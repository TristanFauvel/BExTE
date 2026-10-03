# A value kept in a least recently used store

A value kept in a least recently used store

## Usage

``` r
lattice_lru_cached(store, key, limit, compute)
```

## Arguments

- store:

  Environment holding the list `entries`, most recent last.

- key:

  Key of the value.

- limit:

  Number of entries kept.

- compute:

  A function of no arguments computing the value, or `NULL` to only look
  the key up.

## Value

The value, or `NULL` when it is not stored and `compute` is `NULL`.
