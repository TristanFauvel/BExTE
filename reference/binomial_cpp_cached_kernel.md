# Cached prior kernel of the binomial conditional power prior

The power prior with a fixed power parameter, on the lattice of
[`binomial_npp_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_prior_kernels.md),
as a function of the target control rate and the risk difference.
[BinomialCPP](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.md)
reads its posterior off this kernel with
[`binomial_npp_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_posterior.md),
which costs a fraction of computing it afresh for every dataset with
[`binomial_power_prior_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_power_prior_posterior.md);
the two give the same posterior.

## Usage

``` r
binomial_cpp_cached_kernel(
  n_control_source,
  n_successes_control_source,
  n_treatment_source,
  n_successes_treatment_source,
  power_parameter,
  n_lattice = 1000L
)
```

## Arguments

- n_control_source, n_successes_control_source:

  Source control arm.

- n_treatment_source, n_successes_treatment_source:

  Source treatment arm.

- power_parameter:

  The power parameter, in 0, 1.

- n_lattice:

  Number of lattice points N on the rates.

## Value

A list with `n_lattice`, `rates`, `differences` and `kernel`, as
[`binomial_npp_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_prior_kernels.md)
returns but without the power parameter's moments.
