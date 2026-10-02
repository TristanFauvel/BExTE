# Posterior of the risk difference under the binomial normalized power prior

Multiplies the prior kernel by the target likelihood and sums over the
target control rate. Only the lattice points where both target arms'
likelihoods exceed `1e-20` of their maxima are visited. With no target
patients the result is the prior.

## Usage

``` r
binomial_npp_posterior(
  kernels,
  n_control,
  n_successes_control,
  n_treatment,
  n_successes_treatment
)
```

## Arguments

- kernels:

  Output of
  [`binomial_npp_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_prior_kernels.md).

- n_control, n_successes_control:

  Target control arm.

- n_treatment, n_successes_treatment:

  Target treatment arm.

## Value

A
[`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md)
list with, in addition, `power_parameter_mean` and
`power_parameter_std`, the posterior mean and standard deviation of the
power parameter.
