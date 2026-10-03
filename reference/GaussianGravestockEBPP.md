# GaussianGravestockEBPP class

This class inherits from GaussianEmpiricalBayesPP and implements the
Gravestock's EBPP method.

## Format

R6Class object.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`GaussianConjugate`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.md)
-\> `GaussianStaticBorrowing` -\> `GaussianEmpiricalBayesPP` -\>
`GaussianGravestockEBPP`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [`GaussianGravestockEBPP$new()`](#method-GaussianGravestockEBPP-initialize)

- [`GaussianGravestockEBPP$power_parameter_estimation()`](#method-GaussianGravestockEBPP-power_parameter_estimation)

- [`GaussianGravestockEBPP$vectorised_power_parameter()`](#method-GaussianGravestockEBPP-vectorised_power_parameter)

- [`GaussianGravestockEBPP$clone()`](#method-GaussianGravestockEBPP-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-hypothesis_space_transformation)
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
- [`GaussianConjugate$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-credible_interval)
- [`GaussianConjugate$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_cdf)
- [`GaussianConjugate$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_mean)
- [`GaussianConjugate$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_median)
- [`GaussianConjugate$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_moments)
- [`GaussianConjugate$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_pdf)
- [`GaussianConjugate$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_to_RBesT)
- [`GaussianConjugate$posterior_variance()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_variance)
- [`GaussianConjugate$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-prior_cdf)
- [`GaussianConjugate$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-prior_to_RBesT)
- [`GaussianConjugate$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-sample_posterior)
- [`GaussianConjugate$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-sample_prior)
- [`GaussianConjugate$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-vectorised_replicate_inference)
- `GaussianStaticBorrowing$summary_rows()`
- `GaussianEmpiricalBayesPP$empirical_bayes_update()`
- `GaussianEmpiricalBayesPP$inference()`
- `GaussianEmpiricalBayesPP$plot_power_parameter_vs_drift()`
- `GaussianEmpiricalBayesPP$prior_pdf()`
- `GaussianEmpiricalBayesPP$vectorised_posterior_parameters()`
- `GaussianEmpiricalBayesPP$vectorised_prior_variance()`

------------------------------------------------------------------------

### `GaussianGravestockEBPP$new()`

Initialize the GaussianGravestockEBPP object.

#### Usage

    GaussianGravestockEBPP$new(prior, null_space, theta_0)

#### Arguments

- `prior`:

  The prior object.

- `null_space`:

  Side of the null hypothesis space

- `theta_0`:

  Boundary of the null hypothesis space

#### Returns

NULL

------------------------------------------------------------------------

### `GaussianGravestockEBPP$power_parameter_estimation()`

Estimate the power parameter using the Gravestock's EBPP method.

#### Usage

    GaussianGravestockEBPP$power_parameter_estimation(target_data)

#### Arguments

- `target_data`:

  The target data.

- `source_treatment_effect_estimate`:

  Treatment effect estimate in the source study

- `target_treatment_effect_estimate`:

  Treatment effect estimate in the target study

#### Returns

The estimated power parameter.

------------------------------------------------------------------------

### `GaussianGravestockEBPP$vectorised_power_parameter()`

Estimate the power parameter for every replicate at once.

Same closed form as `power_parameter_estimation()`, evaluated on
vectors.

#### Usage

    GaussianGravestockEBPP$vectorised_power_parameter(target_data, samples)

#### Arguments

- `target_data`:

  The target data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of power parameters.

------------------------------------------------------------------------

### `GaussianGravestockEBPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianGravestockEBPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
