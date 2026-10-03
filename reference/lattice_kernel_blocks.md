# Kernel of the binomial power prior on blocks of risk differences

For each block of risk differences k, the matrix
`kernel[j, k] = sum_i w(i - j) a_i b_{i+k}` over the target control
rates `j` of `target_rows` that keep `j + k` on the lattice for some `k`
of the block, with `i` over the source rows `source_rows`. The source
rows are restricted the same way: `b` is zero off the lattice, so the
rows left out contribute nothing.

## Usage

``` r
lattice_kernel_blocks(
  source_control,
  source_treatment,
  source_rows,
  target_rows,
  differences,
  block,
  consume
)
```

## Arguments

- source_control:

  The discounted source control likelihood `a`, zero on the source
  control rates left out.

- source_treatment:

  The discounted source treatment likelihood `b`.

- source_rows, target_rows:

  Ranges `c(lowest, highest)` of source and target control rate indices.

- differences:

  Risk differences, consecutive, in lattice units.

- block:

  Number of risk differences per block.

- consume:

  A function of the block (as from
  [`lattice_difference_blocks()`](https://tristanfauvel.github.io/BExTE/reference/lattice_difference_blocks.md),
  with `target_first` and `target_last`) and its kernel, called once per
  non-empty block.

## Value

`NULL`, invisibly.
