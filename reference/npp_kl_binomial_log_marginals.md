# Binomial marginal likelihood of the KL calibration's hypothetical results

The KL criterion compares the posterior of the power parameter under two
hypothetical target results. With binomial likelihoods that posterior is
the Beta prior times the marginal likelihood m(gamma) = Z_T(gamma) /
Z_S(gamma) of the binomial power prior (see
[`binomial_power_prior_log_marginal()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_log_marginal.md)),
which does not depend on the Beta prior. It is therefore tabulated once
per hypothetical result, on a grid of power parameters dense near 0
where Beta priors with small shapes put their quadrature nodes, and
interpolated during the optimisation.

The hypothetical results are the expected responder counts of the
design: the control arm at the design's control rate, the treatment arm
at that rate plus the hypothetical risk difference. The binomial
likelihood is defined for fractional counts, as the normal criterion's
hypothetical estimate is the expected one.

## Usage

``` r
npp_kl_binomial_log_marginals(
  source_counts,
  n_control,
  n_treatment,
  control_rate,
  effects,
  n_lattice = 1000L,
  n_grid = 801L
)
```

## Arguments

- source_counts:

  List of the four source counts.

- n_control, n_treatment:

  Target arm sizes.

- control_rate:

  The design's target control rate.

- effects:

  Named vector of hypothetical risk differences.

- n_lattice:

  Number of lattice points.

- n_grid:

  Number of power parameters in the table.

## Value

A list with `gamma` and one vector of log marginal likelihoods per
element of `effects`.
