# Gaussian_Gravestock_EBPP class

This class inherits from Gaussian_empirical_Bayes_PP and implements the
Gravestock's EBPP method.

## Format

R6Class object.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`ConjugateGaussian`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.md)
-\>
[`StaticBorrowingGaussian`](https://tristanfauvel.github.io/BExTE/reference/StaticBorrowingGaussian.md)
-\>
[`Gaussian_empirical_Bayes_PP`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.md)
-\> ` Gaussian_gravestock_EBPP`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [` Gaussian_gravestock_EBPP$new()`](#method-%20Gaussian_gravestock_EBPP-initialize)

- [` Gaussian_gravestock_EBPP$power_parameter_estimation()`](#method-%20Gaussian_gravestock_EBPP-power_parameter_estimation)

- [` Gaussian_gravestock_EBPP$vectorised_power_parameter()`](#method-%20Gaussian_gravestock_EBPP-vectorised_power_parameter)

- [` Gaussian_gravestock_EBPP$clone()`](#method-%20Gaussian_gravestock_EBPP-clone)

Inherited methods

- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference_cache_scope()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$prior_ESS()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`ConjugateGaussian$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-credible_interval)
- [`ConjugateGaussian$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_cdf)
- [`ConjugateGaussian$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_mean)
- [`ConjugateGaussian$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_median)
- [`ConjugateGaussian$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_moments)
- [`ConjugateGaussian$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_pdf)
- [`ConjugateGaussian$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_to_RBesT)
- [`ConjugateGaussian$posterior_variance()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_variance)
- [`ConjugateGaussian$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-prior_cdf)
- [`ConjugateGaussian$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-prior_to_RBesT)
- [`ConjugateGaussian$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-sample_posterior)
- [`ConjugateGaussian$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-sample_prior)
- [`ConjugateGaussian$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-vectorised_replicate_inference)
- [`Gaussian_empirical_Bayes_PP$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-empirical_bayes_update)
- [`Gaussian_empirical_Bayes_PP$hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-hypothesis_space_transformation)
- [`Gaussian_empirical_Bayes_PP$inference()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-inference)
- [`Gaussian_empirical_Bayes_PP$plot_power_parameter_vs_drift()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-plot_power_parameter_vs_drift)
- [`Gaussian_empirical_Bayes_PP$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-prior_pdf)
- [`Gaussian_empirical_Bayes_PP$vectorised_hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-vectorised_hypothesis_space_transformation)
- [`Gaussian_empirical_Bayes_PP$vectorised_posterior_parameters()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-vectorised_posterior_parameters)
- [`Gaussian_empirical_Bayes_PP$vectorised_prior_variance()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-vectorised_prior_variance)

------------------------------------------------------------------------

### ` Gaussian_gravestock_EBPP$new()`

Initialize the Gaussian_Gravestock_EBPP object.

#### Usage

     Gaussian_gravestock_EBPP$new(prior, null_space, theta_0)

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

### ` Gaussian_gravestock_EBPP$power_parameter_estimation()`

Estimate the power parameter using the Gravestock's EBPP method.

#### Usage

     Gaussian_gravestock_EBPP$power_parameter_estimation(target_data)

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

### ` Gaussian_gravestock_EBPP$vectorised_power_parameter()`

Estimate the power parameter for every replicate at once.

Same closed form as `power_parameter_estimation()`, evaluated on
vectors.

#### Usage

     Gaussian_gravestock_EBPP$vectorised_power_parameter(target_data, samples)

#### Arguments

- `target_data`:

  The target data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of power parameters.

------------------------------------------------------------------------

### ` Gaussian_gravestock_EBPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

     Gaussian_gravestock_EBPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
