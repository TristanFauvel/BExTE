# Fit the Egidi, Pauli and Torelli empirical mixture prior

Selects the mixture weight from the observed target summary and then
updates the resulting prior with the same summary. The two prior
components are the ones the robust mixture prior uses, so the only
difference between the two methods is where the weight comes from.

## Usage

``` r
fit_egidi_mixture(
  theta_target_hat,
  se_target,
  informative_component,
  weak_component,
  alpha_pc = 0.05,
  pvalue_method = c("exact", "mc"),
  weight_grid_step = 0.001,
  mc_draws = 1000L,
  seed = NULL,
  theta_0 = 0,
  null_space = "left",
  confidence_level = 0.95
)
```

## Arguments

- theta_target_hat:

  Observed target treatment effect estimate.

- se_target:

  Target standard error.

- informative_component:

  A list with `mean` and `sd`, the source-based prior \\p(\theta_T)\\.

- weak_component:

  A list with `mean` and `sd`, the weak or unit-information prior
  \\q(\theta_T)\\.

- alpha_pc:

  Prior-predictive conflict threshold. 0.05 in the primary analysis;
  0.01 and 0.10 are the sensitivity values.

- pvalue_method:

  `"exact"` for the deterministic calculation, or `"mc"` for the
  prior-predictive simulation fallback.

- weight_grid_step:

  Resolution of the weight scan.

- mc_draws:

  Number of hypothetical replications when `pvalue_method` is `"mc"`.

- seed:

  Seed for the simulation fallback. The same seed is used at every
  candidate weight, which is what makes the comparison use common random
  numbers.

- theta_0:

  Null value of the treatment effect.

- null_space:

  Either `"left"` or `"right"`.

- confidence_level:

  Credible interval level.

## Value

A list with the selected and posterior weights, the three conflict
p-values, the conflict flags, the posterior mixture and its summaries,
the probability of success, and numerical diagnostics.

## Details

The procedure is deliberately adaptive: the observed target data are
used first to choose the weight on the weak component and then again to
update the mixture. `psi_weak` is therefore not a prior probability
chosen before the target data were seen, and should not be reported as
one.

The selected weight and the posterior component weight are different
quantities and are both returned. The first is the weight the prior is
given; the second is the posterior probability that the treatment effect
came from the informative component, obtained from the component
marginal likelihoods on the log scale.

The robust mixture prior parameterises its mixture by the weight on the
informative component, so `w_informative_prior` is `1 - psi_weak`.
