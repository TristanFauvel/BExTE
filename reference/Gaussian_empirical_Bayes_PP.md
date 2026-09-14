# Gaussian_empirical_Bayes_PP class

This is a parent class for variants of empirical Bayes PP methods for
normally distributed summary measure of the treatment effect.

## Format

R6Class object.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`ConjugateGaussian`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.md)
-\>
[`StaticBorrowingGaussian`](https://tristanfauvel.github.io/BExTE/reference/StaticBorrowingGaussian.md)
-\> `Gaussian_empirical_Bayes_PP`

## Public fields

- `power_parameter`:

  The power parameter.

- `summary_measure_likelihood`:

  The summary measure distribution.

- `null_space`:

  Null hypothesis space.

- `empirical_bayes`:

  Boolean indicating if empirical Bayes is used.

## Methods

### Public methods

- [`Gaussian_empirical_Bayes_PP$new()`](#method-Gaussian_empirical_Bayes_PP-initialize)

- [`Gaussian_empirical_Bayes_PP$hypothesis_space_transformation()`](#method-Gaussian_empirical_Bayes_PP-hypothesis_space_transformation)

- [`Gaussian_empirical_Bayes_PP$empirical_bayes_update()`](#method-Gaussian_empirical_Bayes_PP-empirical_bayes_update)

- [`Gaussian_empirical_Bayes_PP$inference()`](#method-Gaussian_empirical_Bayes_PP-inference)

- [`Gaussian_empirical_Bayes_PP$power_parameter_estimation()`](#method-Gaussian_empirical_Bayes_PP-power_parameter_estimation)

- [`Gaussian_empirical_Bayes_PP$vectorised_power_parameter()`](#method-Gaussian_empirical_Bayes_PP-vectorised_power_parameter)

- [`Gaussian_empirical_Bayes_PP$vectorised_hypothesis_space_transformation()`](#method-Gaussian_empirical_Bayes_PP-vectorised_hypothesis_space_transformation)

- [`Gaussian_empirical_Bayes_PP$vectorised_prior_variance()`](#method-Gaussian_empirical_Bayes_PP-vectorised_prior_variance)

- [`Gaussian_empirical_Bayes_PP$vectorised_posterior_parameters()`](#method-Gaussian_empirical_Bayes_PP-vectorised_posterior_parameters)

- [`Gaussian_empirical_Bayes_PP$prior_pdf()`](#method-Gaussian_empirical_Bayes_PP-prior_pdf)

- [`Gaussian_empirical_Bayes_PP$plot_power_parameter_vs_drift()`](#method-Gaussian_empirical_Bayes_PP-plot_power_parameter_vs_drift)

- [`Gaussian_empirical_Bayes_PP$clone()`](#method-Gaussian_empirical_Bayes_PP-clone)

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

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$new()`

Initialize the Gaussian_empirical_Bayes_PP object.

#### Usage

    Gaussian_empirical_Bayes_PP$new(prior, null_space, theta_0)

#### Arguments

- `prior`:

  The prior object.

- `null_space`:

  Null space

- `theta_0`:

  The theta_0 value.

#### Returns

NULL

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$hypothesis_space_transformation()`

Transform the hypothesis space.

#### Usage

    Gaussian_empirical_Bayes_PP$hypothesis_space_transformation(target_data)

#### Arguments

- `target_data`:

  The target data.

#### Returns

A list containing transformed treatment effect estimates.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$empirical_bayes_update()`

Empirical Bayes update

#### Usage

    Gaussian_empirical_Bayes_PP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Target study data

#### Returns

NULL Perform inference using the Gaussian_empirical_Bayes_PP method.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$inference()`

#### Usage

    Gaussian_empirical_Bayes_PP$inference(target_data)

#### Arguments

- `target_data`:

  The target data.

#### Returns

The inference result. Estimate the power parameter.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$power_parameter_estimation()`

#### Usage

    Gaussian_empirical_Bayes_PP$power_parameter_estimation()

#### Returns

The estimated power parameter.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$vectorised_power_parameter()`

Estimate the power parameter for every replicate at once

Subclasses whose estimator is closed form override this. Returning
`NULL` means "no fast path", which keeps subclasses with an iterative
estimator (PDCCPP calibrates by search) on the replicate loop.

#### Usage

    Gaussian_empirical_Bayes_PP$vectorised_power_parameter(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of power parameters, or `NULL`.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$vectorised_hypothesis_space_transformation()`

Transform the hypothesis space for every replicate at once

Vectorised counterpart of `hypothesis_space_transformation()`.

#### Usage

    Gaussian_empirical_Bayes_PP$vectorised_hypothesis_space_transformation(samples)

#### Arguments

- `samples`:

  Data frame of generated replicates.

#### Returns

A list of transformed source and target treatment effect estimates.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$vectorised_prior_variance()`

Prior variance for each replicate

Mirrors `empirical_bayes_update()`: the power prior is equivalent to a
Gaussian prior with variance
`source standard error^2 / power parameter`, and a power parameter of
zero means a vague prior.

#### Usage

    Gaussian_empirical_Bayes_PP$vectorised_prior_variance(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of prior variances, or `NULL`.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path

#### Usage

    Gaussian_empirical_Bayes_PP$vectorised_posterior_parameters(prior_variance)

#### Arguments

- `prior_variance`:

  Per-replicate prior variance.

#### Returns

A data frame with one `power_parameter` column.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$prior_pdf()`

Calculate the prior probability density function (PDF) for a given
target treatment effect.

#### Usage

    Gaussian_empirical_Bayes_PP$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$plot_power_parameter_vs_drift()`

Plot the power parameter as a function of drift in treatment effect

#### Usage

    Gaussian_empirical_Bayes_PP$plot_power_parameter_vs_drift(
      source_treatment_effect_estimate,
      target_data,
      min_drift,
      max_drift,
      resolution
    )

#### Arguments

- `source_treatment_effect_estimate`:

  Treatment effect estimate in the source study

- `target_data`:

  Target study data

- `min_drift`:

  Minimum drift value

- `max_drift`:

  Maximum drift value

- `resolution`:

  Number of points on the drift grid.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `Gaussian_empirical_Bayes_PP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Gaussian_empirical_Bayes_PP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
