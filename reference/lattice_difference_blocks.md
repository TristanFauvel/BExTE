# Blocks of risk differences and the control rates each one reaches

Splits the risk differences into blocks of consecutive values and, for
each, the range of control rates in `rows` (an index range) whose
treatment rate, at some difference of the block, is on the lattice.

## Usage

``` r
lattice_difference_blocks(differences, rows, N, block)
```

## Arguments

- differences:

  Increasing consecutive risk differences, in lattice units.

- rows:

  Range of control rate indices, `c(lowest, highest)`.

- N:

  Number of lattice points.

- block:

  Number of risk differences per block.

## Value

A list of blocks, each with `columns` (positions in `differences`),
`first_shift`, and the row range `first` and `last`, which is empty when
`first > last`.
