# Hankel matrix of shifted lattice values

The `n_rows` x `n_shifts` matrix whose (r, c) entry is
`values[first_row + r - 1 + first_shift + c - 1]`, and `fill` where that
index leaves 1, ..., N. The same as
[`lattice_shift_matrix()`](https://tristanfauvel.github.io/BExTE/reference/lattice_shift_matrix.md)
for contiguous rows and shifts, built from one contiguous segment of the
vector, whose index vector
[`sequence()`](https://rdrr.io/r/base/sequence.html) builds in a single
pass.

## Usage

``` r
lattice_hankel(values, first_row, n_rows, first_shift, n_shifts, fill = 0)
```

## Arguments

- values:

  A vector of length N.

- first_row, n_rows:

  First row position and number of rows.

- first_shift, n_shifts:

  First shift and number of shifts.

- fill:

  Value outside the lattice.

## Value

A `n_rows` x `n_shifts` matrix.
