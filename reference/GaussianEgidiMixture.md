# GaussianEgidiMixture class

The empirical mixture prior of Egidi, Pauli and Torelli for a normal
summary measure.

## Details

The prior is the robust mixture prior's, \$\$\pi\_\psi(\theta_T) = \psi
q(\theta_T) + (1 - \psi) p(\theta_T),\$\$ with the same informative
component \\p\\ centred on the source estimate and the same weak
component \\q\\. Only the weight differs: instead of being prespecified,
\\\psi\\ is the smallest weight on the weak component at which the
prior-predictive conflict p-value reaches `alpha_pc`, computed
separately for every replicate from that replicate's own target estimate
and standard error.

The class inherits from
[GaussianRMP_RBesT](https://tristanfauvel.github.io/BExTE/reference/GaussianRMP_RBesT.md)
and supplies the weight it would otherwise read from the configuration.
Because the robust mixture prior parameterises its mixture by the weight
on the *informative* component, the weight handed over is \\1 -
\hat\psi\\. Everything after that - the conjugate update, the credible
interval, the decision rule, the effective sample sizes - is the
inherited code, so the two methods differ only in where the weight comes
from.

This is an empirically adaptive procedure. The target data are used
first to select the weight and then again to update the posterior, which
is intentional and is what distinguishes the method from a robust
mixture prior with a prespecified weight. `psi_weak` should not be
described as a prior probability chosen before the target data were
observed.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`Model_RBesT`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.md)
-\>
[`GaussianRMP_RBesT`](https://tristanfauvel.github.io/BExTE/reference/GaussianRMP_RBesT.md)
-\> `GaussianEgidiMixture`

## Public fields

- `alpha_pc`:

  Prior-predictive conflict threshold.

- `pvalue_method`:

  How the conflict p-value is computed.

- `weight_grid_step`:

  Resolution of the weight scan.

- `weight_scan_step`:

  Resolution of the coarse stage of the weight scan.

- `selection`:

  The per-replicate selection, cached so that the scalar and vectorised
  paths report the same numbers they priced the prior with.

- `quantile_summary_columns`:

  Posterior parameters also summarised by quantile, which for this
  method is the selected weight.

- `method`:

  Method name.

## Methods

### Public methods

- [`GaussianEgidiMixture$new()`](#method-GaussianEgidiMixture-initialize)

- [`GaussianEgidiMixture$empirical_bayes_update()`](#method-GaussianEgidiMixture-empirical_bayes_update)

- [`GaussianEgidiMixture$posterior_moments()`](#method-GaussianEgidiMixture-posterior_moments)

- [`GaussianEgidiMixture$vectorised_prior_components()`](#method-GaussianEgidiMixture-vectorised_prior_components)

- [`GaussianEgidiMixture$vectorised_posterior_parameters()`](#method-GaussianEgidiMixture-vectorised_posterior_parameters)

- [`GaussianEgidiMixture$clone()`](#method-GaussianEgidiMixture-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference)
- [`Model$inference_cache_scope()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$print_model_summary()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-print_model_summary)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`Model_RBesT$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-credible_interval)
- [`Model_RBesT$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_cdf)
- [`Model_RBesT$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_mean)
- [`Model_RBesT$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_median)
- [`Model_RBesT$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_pdf)
- [`Model_RBesT$posterior_variance()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_variance)
- [`Model_RBesT$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-prior_cdf)
- [`Model_RBesT$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-prior_pdf)
- [`Model_RBesT$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-sample_posterior)
- [`Model_RBesT$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-sample_prior)
- [`Model_RBesT$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-vectorised_replicate_inference)
- [`GaussianRMP_RBesT$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianRMP_RBesT.html#method-posterior_to_RBesT)
- [`GaussianRMP_RBesT$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianRMP_RBesT.html#method-prior_to_RBesT)
- [`GaussianRMP_RBesT$summary_rows()`](https://tristanfauvel.github.io/BExTE/reference/GaussianRMP_RBesT.html#method-summary_rows)

------------------------------------------------------------------------

### `GaussianEgidiMixture$new()`

Initialize a new GaussianEgidiMixture object.

#### Usage

    GaussianEgidiMixture$new(prior)

#### Arguments

- `prior`:

  A list containing prior information for the analysis.

------------------------------------------------------------------------

### `GaussianEgidiMixture$empirical_bayes_update()`

Select the mixture weight for a replicate and build its prior.

The weak component's variance is derived from the replicate first,
because it sets the weak component's prior-predictive and so enters the
conflict p-value. The inherited method then re-derives it by the same
rule and assembles the mixture with the selected weight.

#### Usage

    GaussianEgidiMixture$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  A list containing the target data for the analysis.

------------------------------------------------------------------------

### `GaussianEgidiMixture$posterior_moments()`

Calculate the posterior moments based on the target data.

#### Usage

    GaussianEgidiMixture$posterior_moments(target_data)

#### Arguments

- `target_data`:

  A list containing the target data for the analysis.

------------------------------------------------------------------------

### `GaussianEgidiMixture$vectorised_prior_components()`

Prior mixture components for each replicate.

The weight varies by replicate, so the mixture is returned as matrices
with one row each. The component order is the inherited one, informative
first, which is what makes the posterior weight the inherited code
reports the probability of the informative component.

#### Usage

    GaussianEgidiMixture$vectorised_prior_components(target_data, samples)

#### Arguments

- `target_data`:

  Target data for the analysis.

- `samples`:

  Data frame of generated replicates.

#### Returns

A list with `weights`, `means` and `sds`.

------------------------------------------------------------------------

### `GaussianEgidiMixture$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path.

#### Usage

    GaussianEgidiMixture$vectorised_posterior_parameters(posterior)

#### Arguments

- `posterior`:

  Posterior mixture from
  [`normal_mixture_posterior()`](https://tristanfauvel.github.io/BExTE/reference/normal_mixture_posterior.md).

#### Returns

A data frame with one row per replicate.

------------------------------------------------------------------------

### `GaussianEgidiMixture$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianEgidiMixture$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
