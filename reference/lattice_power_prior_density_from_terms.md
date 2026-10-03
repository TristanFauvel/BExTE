# Posterior density from the target terms

`sum_i a_i b_{i+k} T(i, k)` over the source rows kept, with
`T(i, k) = sum_j w(i - j) c_j t_{j+k}` the target terms of
[`binomial_power_prior_target_terms()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_target_terms.md):
the same double sum as
[`lattice_power_prior_density()`](https://tristanfauvel.github.io/BExTE/reference/lattice_power_prior_density.md),
summed over the target control rate first.

## Usage

``` r
lattice_power_prior_density_from_terms(
  terms,
  source_control,
  source_treatment,
  source_rows,
  differences
)
```

## Arguments

- terms:

  The N x K matrix T, zero where `i + k` leaves the lattice except at
  the edges of a block.

- source_control, source_treatment:

  Discounted source likelihoods on the lattice, the control one zero on
  the source rows left out.

- differences:

  Risk differences, consecutive, in lattice units.

## Value

The unnormalised density at `differences`.
