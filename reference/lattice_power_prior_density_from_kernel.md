# Posterior density from a full kernel

Posterior density from a full kernel

## Usage

``` r
lattice_power_prior_density_from_kernel(
  kernel,
  target_control,
  target_treatment,
  target_rows,
  differences
)
```

## Arguments

- kernel:

  Output of
  [`lattice_power_prior_full_kernel()`](https://tristanfauvel.github.io/BExTE/reference/lattice_power_prior_full_kernel.md).

- target_control, target_treatment:

  Target likelihoods on the lattice, the control one zero on the target
  control rates left out.

- differences:

  Risk differences, consecutive, in lattice units.

## Value

The unnormalised density at `differences`.
