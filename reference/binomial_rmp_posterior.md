# Posterior of the binomial robust mixture prior with a given weight

The posterior
[`binomial_npp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_posterior.md)
gives for the kernels of
[`binomial_rmp_kernels()`](https://tristanfauvel.github.io/BExTE/reference/binomial_rmp_kernels.md),
computed without forming them: the mixture kernel is linear in the
weight, so the posterior mass at each risk difference is `weight` times
that of the informative component plus `1 - weight` times that of the
weak one, and the posterior weight of the informative component is the
former's share of the total. The component masses are read off the
components' kernels, which do not depend on the weight, in a single
weighted sum each; the lattice points visited are those of
[`binomial_npp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_posterior.md).

## Usage

``` r
binomial_rmp_posterior(
  components,
  weight,
  n_control,
  n_successes_control,
  n_treatment,
  n_successes_treatment
)
```

## Arguments

- components:

  Output of
  [`binomial_rmp_components()`](https://tristanfauvel.github.io/BExTE/reference/binomial_rmp_components.md).

- weight:

  Prior weight of the informative component.

- n_control, n_successes_control:

  Target control arm.

- n_treatment, n_successes_treatment:

  Target treatment arm.

## Value

The list
[`binomial_npp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_posterior.md)
returns for `binomial_rmp_kernels(components, weight)`.
