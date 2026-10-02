# Sort every row of a matrix

The same as `t(apply(m, 1, sort, na.last = TRUE))`, from one call to
[`order()`](https://rdrr.io/r/base/order.html) on the whole matrix
rather than one call to [`sort()`](https://rdrr.io/r/base/sort.html) per
row, which on ten thousand rows is over a hundred times faster.

## Usage

``` r
sort_rows(m)
```

## Arguments

- m:

  A numeric matrix.

## Value

`m` with each row sorted increasingly and its missing values last.
