# Discretised marginal posterior of the discounting parameter

For a hypothetical target estimate `x`, the marginal posterior of the
discounting parameter is \$\$p(\gamma \mid x) \propto N(x; \hat\theta_S,
s_T^2 + s_S^2/\gamma) \\ \mathrm{Beta}(\gamma; a, b).\$\$ Evaluated on
the quadrature nodes this becomes a discrete distribution, whose masses
are the normalised products of the Beta measure and the normal
likelihood. Normalising through
[`npp_kl_log_sum_exp()`](https://tristanfauvel.github.io/BExTE/reference/npp_kl_log_sum_exp.md)
keeps the very small likelihoods reached at the maximum tolerable
discrepancy from underflowing.

This is a hypothetical posterior, used only to calibrate `a` and `b`. It
is not the posterior of any simulated replicate.

## Usage

``` r
npp_kl_posterior_masses(
  x,
  theta_source,
  se_source,
  se_target_expected,
  alpha_gamma,
  beta_gamma,
  rule
)
```

## Arguments

- x:

  Hypothetical target treatment effect estimate.

- theta_source:

  Source treatment effect estimate.

- se_source:

  Standard error of the source estimate.

- se_target_expected:

  Expected standard error of the target estimate.

- alpha_gamma:

  First shape parameter of the Beta prior.

- beta_gamma:

  Second shape parameter of the Beta prior.

- rule:

  A rule from
  [`npp_kl_beta_quadrature()`](https://tristanfauvel.github.io/BExTE/reference/npp_kl_beta_quadrature.md).

## Value

A list with the quadrature `nodes`, the posterior `masses` at those
nodes, which sum to one, and `log_density`, the log posterior density
there.
