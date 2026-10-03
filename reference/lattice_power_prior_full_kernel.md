# Kernel of the binomial power prior at every target control rate

The kernel of
[`lattice_power_prior_density()`](https://tristanfauvel.github.io/BExTE/reference/lattice_power_prior_density.md)
for every target control rate and every risk difference of
`differences`, by default -(N - 1), ..., N - 1: zero where the treatment
rate leaves the lattice, except at the edges of a block, where the
target likelihood is zero anyway.

## Usage

``` r
lattice_power_prior_full_kernel(
  source_control,
  source_treatment,
  source_rows,
  differences = seq(-(length(source_control) - 1L), length(source_control) - 1L),
  block = 256L
)
```

## Arguments

- source_control, source_treatment:

  Discounted source likelihoods on the lattice, the control one zero on
  the source rows left out.

- differences:

  Risk differences, consecutive, in lattice units.

- block:

  Number of risk differences per block.

## Value

An N x `length(differences)` matrix; with the default differences,
column `k + N` is the risk difference k.
