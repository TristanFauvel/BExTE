# Source power posterior of the risk difference, integrated over gamma

For each commensurability node, the source power posterior
p_gamma(theta_S) averaged over gamma \| tau ~ Beta(g(tau), 1), and the
same average weighted by gamma and by gamma^2. Because p_gamma(d) is a
sum over the source control rate of exp(gamma l) / Z_S(gamma), with l
the source log likelihood, the average is a sum of h(l) over the source
control rate, where h is a function of one scalar, tabulated once per
distinct shape g(tau) and interpolated (as in
[`binomial_npp_prior_kernels()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_prior_kernels.md)).

## Usage

``` r
binomial_source_power_posteriors(
  source_counts,
  shapes,
  n_lattice,
  n_log_likelihood_points = 4001L
)
```

## Arguments

- source_counts:

  List of the four source counts.

- shapes:

  Beta shape g(tau) of each node, or `NULL` for gamma = 1.

- n_lattice:

  Number of lattice points N.

- n_log_likelihood_points:

  Points of the h tables.

## Value

A list with `differences` (in lattice units, all of -(N - 1), ...,
N - 1) and the (2N - 1) x n matrices `density`, `gamma_first` and
`gamma_second`, one column per node; the last two are `NULL` for gamma =
1.
