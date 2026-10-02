# Values of a lattice vector at shifted positions

The matrix whose (r, c) entry is `values[rows[r] + shifts[c]]`, and
`fill` where that position leaves 1, ..., N: one lookup into a padded
copy of the vector, rather than building the index matrices with
[`outer()`](https://rdrr.io/r/base/outer.html).

## Usage

``` r
lattice_shift_matrix(values, rows, shifts, fill = 0)
```

## Arguments

- values:

  A vector of length N.

- rows:

  Row positions, in 1, ..., N.

- shifts:

  Shifts, in -(N - 1), ..., N - 1.

- fill:

  Value outside the lattice.

## Value

A `length(rows)` x `length(shifts)` matrix.
