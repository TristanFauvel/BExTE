# Prior kernels of the binomial normalized power prior

Computes, on the rate lattice, the normalized power prior integrated
over the power parameter, as a function of the target control rate and
of the risk difference, together with the same kernel weighted by the
power parameter and by its square.

## Usage

``` r
binomial_npp_prior_kernels(
  n_control_source,
  n_successes_control_source,
  n_treatment_source,
  n_successes_treatment_source,
  gamma_rule,
  n_lattice = 1000L,
  n_log_likelihood_points = 20001L
)
```

## Arguments

- n_control_source, n_successes_control_source:

  Source control arm.

- n_treatment_source, n_successes_treatment_source:

  Source treatment arm.

- gamma_rule:

  Quadrature rule for the prior of the power parameter, as returned by
  [`npp_gamma_rule()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/npp_gamma_rule.md):
  a single node of weight one gives the conditional power prior with
  that power parameter.

- n_lattice:

  Number of lattice points N on the rates.

- n_log_likelihood_points:

  Number of points on which the weight functions of the source log
  likelihood are tabulated before interpolation.

## Value

A list with `n_lattice`, the `rates`, and the N x (2N - 1) matrices
`kernel`, `kernel_gamma` and `kernel_gamma_squared`, indexed by the
target control rate and the risk difference k / N, k = -(N - 1), ...,
N - 1. They are zero where the target treatment rate would leave 0, 1.
