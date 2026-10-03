# Prior kernels of the binomial commensurate priors

The prior of the target control rate and risk difference, integrated
over the source risk difference, the power parameter and the
commensurability parameter, on the lattice, with the kernels weighted by
the commensurability parameter and by the power parameter, and by their
squares, for their posterior moments.

## Usage

``` r
binomial_commensurate_prior_kernels(
  source_counts,
  tau_rule,
  borrows_power_parameter,
  tau_moments_exist,
  n_lattice = 1000L
)
```

## Arguments

- source_counts:

  List of the four source counts.

- tau_rule:

  Output of
  [`commensurate_tau_quadrature()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_tau_quadrature.md).

- borrows_power_parameter:

  `TRUE` for the commensurate power prior, `FALSE` for the commensurate
  prior (gamma = 1).

- tau_moments_exist:

  Output of
  [`commensurate_tau_moments_exist()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_tau_moments_exist.md).

- n_lattice:

  Number of lattice points N.

## Value

A list with `n_lattice`, `rates`, `differences`, `kernel` and `moments`,
as
[`binomial_npp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_posterior.md)
reads them.
