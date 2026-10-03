# Posterior density of the risk difference under the binomial power prior

`sum_j c_j t_{j+k} kernel[j, k]` for every risk difference k of
`differences`, computed block by block; see the comment at the top of
`R/binomial_lattice_fast.R`.

## Usage

``` r
lattice_power_prior_density(
  source_control,
  source_treatment,
  target_control,
  target_treatment,
  source_rows,
  target_rows,
  differences,
  block = 256L
)
```

## Arguments

- source_control, source_treatment:

  Discounted source likelihoods on the lattice, the control one zero on
  the source rows left out.

- target_control, target_treatment:

  Target likelihoods on the lattice, the control one zero on the target
  control rates left out.

- source_rows, target_rows:

  Ranges of the source and target control rates with nonzero likelihood.

- differences:

  Risk differences, consecutive, in lattice units.

- block:

  Number of risk differences per block.

## Value

The unnormalised density at `differences`.
