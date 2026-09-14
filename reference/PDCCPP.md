# PDCCPP class

This class inherits from Gaussian_empirical_Bayes_PP and implements the
PDCCPP method.

## Format

R6Class object.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`ConjugateGaussian`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.md)
-\>
[`StaticBorrowingGaussian`](https://tristanfauvel.github.io/BExTE/reference/StaticBorrowingGaussian.md)
-\>
[`Gaussian_empirical_Bayes_PP`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.md)
-\> `PDCCPP`

## Public fields

- `null_space`:

  Side of the null hypothesis space

- `method`:

  Method name

## Methods

### Public methods

- [`PDCCPP$new()`](#method-PDCCPP-initialize)

- [`PDCCPP$power_parameter_estimation()`](#method-PDCCPP-power_parameter_estimation)

- [`PDCCPP$clone()`](#method-PDCCPP-clone)

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
- [`Gaussian_empirical_Bayes_PP$vectorised_power_parameter()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-vectorised_power_parameter)
- [`Gaussian_empirical_Bayes_PP$vectorised_prior_variance()`](https://tristanfauvel.github.io/BExTE/reference/Gaussian_empirical_Bayes_PP.html#method-vectorised_prior_variance)

------------------------------------------------------------------------

### `PDCCPP$new()`

Initialize the PDCCPP object.

#### Usage

    PDCCPP$new(prior, theta_0, null_space)

#### Arguments

- `prior`:

  The prior object.

- `theta_0`:

  The theta_0 value.

- `null_space`:

  Null space

#### Returns

NULL Estimate the power parameter using the PDCCPP method.

------------------------------------------------------------------------

### `PDCCPP$power_parameter_estimation()`

#### Usage

    PDCCPP$power_parameter_estimation(target_data)

#### Arguments

- `target_data`:

  The target data.

- `source_treatment_effect_estimate`:

  The source treatment effect estimate.

- `target_treatment_effect_estimate`:

  The target treatment effect estimate.

#### Returns

The estimated power parameter.

------------------------------------------------------------------------

### `PDCCPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PDCCPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
