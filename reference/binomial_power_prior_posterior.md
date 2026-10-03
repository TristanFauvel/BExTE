# Posterior of the treatment effect under the binomial power prior

The binomial conditional power prior: uniform priors on the source
control rate u and the target control rate v, a uniform prior on the
common treatment effect theta over (-min(u, v), 1 - max(u, v)), which
has density 1 / (1 - \|u - v\|), and the source likelihood raised to the
power gamma.

The rates are discretised on the lattice of
[`binomial_npp_prior_kernels()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_prior_kernels.md):
the midpoints of N equal cells of \\\[0, 1\]\\, with the treatment
effect on the multiples of the cell width, so that every treatment rate
is a lattice point. The lattice covers the whole unit square, so it
follows the posterior wherever the target data move it, including far
into the tails of the source likelihood when the two studies conflict.
Nodes placed on the quantiles of the source and target control rates'
own likelihoods, as an earlier version of this function used, miss that
region: under conflict the posterior probability of benefit was off by
0.016 and the posterior mean by up to 0.07 against Stan.

Only the target control rates and treatment rates where the target
likelihood exceeds `1e-20` of its maximum are visited, and every source
control rate, so the cost is N times the number of target lattice points
per arm times the number of treatment effects they reach.

With no target patients the target counts are zero and the result is the
prior.

## Usage

``` r
binomial_power_prior_posterior(
  power_parameter,
  n_control_source,
  n_successes_control_source,
  n_treatment_source,
  n_successes_treatment_source,
  n_control,
  n_successes_control,
  n_treatment,
  n_successes_treatment,
  n_lattice = 1000L,
  control_rate = NULL
)
```

## Arguments

- power_parameter:

  The power parameter gamma, in \\\[0, 1\]\\.

- n_control_source, n_successes_control_source:

  Source control arm.

- n_treatment_source, n_successes_treatment_source:

  Source treatment arm.

- n_control, n_successes_control:

  Target control arm.

- n_treatment, n_successes_treatment:

  Target treatment arm.

- n_lattice:

  Number of lattice points N on the rates.

- control_rate:

  Target control rate to condition on, or `NULL` to integrate it out.
  Conditioning puts the target control rate's whole mass on the lattice
  cell that contains it, which confines the treatment effect to the
  differences that keep the target treatment rate in \\\[0, 1\]\\.

## Value

A
[`grid_posterior()`](https://tristanfauvel.github.io/BExTE/reference/grid_posterior.md)
list.
