# GaussianRMP class

A class for Gaussian Robust Mixture Prior models.

## Details

This class represents a Gaussian Robust Mixture Prior model. It inherits
from the Model class.

This class extends the Model class and provides methods for initializing
the model, updating priors, calculating posterior moments, and sampling
from prior and posterior distributions.

## Super class

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\> `GaussianRMP`

## Public fields

- `w`:

  The weight of the prior distribution.

- `vague_prior_mean`:

  The mean of the vague prior distribution.

- `vague_prior_variance`:

  The variance of the vague prior distribution.

- `info_prior_mean`:

  The mean of the informative prior distribution.

- `info_prior_variance`:

  The variance of the informative prior distribution.

- `wpost`:

  The weight of the posterior distribution.

- `vague_posterior_mean`:

  The mean of the vague posterior distribution.

- `info_posterior_mean`:

  The mean of the informative posterior distribution.

- `vague_posterior_variance`:

  The variance of the vague posterior distribution.

- `info_posterior_variance`:

  The variance of the informative posterior distribution.

- `method`:

  Name of the method

## Methods

### Public methods

- [`GaussianRMP$new()`](#method-GaussianRMP-initialize)

- [`GaussianRMP$empirical_bayes_update()`](#method-GaussianRMP-empirical_bayes_update)

- [`GaussianRMP$prior_weight()`](#method-GaussianRMP-prior_weight)

- [`GaussianRMP$prior_pdf()`](#method-GaussianRMP-prior_pdf)

- [`GaussianRMP$prior_cdf()`](#method-GaussianRMP-prior_cdf)

- [`GaussianRMP$posterior_moments()`](#method-GaussianRMP-posterior_moments)

- [`GaussianRMP$posterior_pdf()`](#method-GaussianRMP-posterior_pdf)

- [`GaussianRMP$posterior_cdf()`](#method-GaussianRMP-posterior_cdf)

- [`GaussianRMP$sample_prior()`](#method-GaussianRMP-sample_prior)

- [`GaussianRMP$sample_posterior()`](#method-GaussianRMP-sample_posterior)

- [`GaussianRMP$posterior_mean()`](#method-GaussianRMP-posterior_mean)

- [`GaussianRMP$posterior_variance()`](#method-GaussianRMP-posterior_variance)

- [`GaussianRMP$prior_to_RBesT()`](#method-GaussianRMP-prior_to_RBesT)

- [`GaussianRMP$posterior_to_RBesT()`](#method-GaussianRMP-posterior_to_RBesT)

- [`GaussianRMP$print_model_summary()`](#method-GaussianRMP-print_model_summary)

- [`GaussianRMP$clone()`](#method-GaussianRMP-clone)

Inherited methods

- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-credible_interval)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_ess)
- [`Model$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_median)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `GaussianRMP$new()`

Initialize a new GaussianRMP object.

#### Usage

    GaussianRMP$new(prior)

#### Arguments

- `prior`:

  A list containing prior information for the analysis.

------------------------------------------------------------------------

### `GaussianRMP$empirical_bayes_update()`

Update the vague prior variance based on empirical Bayes approach.

#### Usage

    GaussianRMP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  The target data for the analysis.

------------------------------------------------------------------------

### `GaussianRMP$prior_weight()`

Calculate the posterior weight based on the target data.

#### Usage

    GaussianRMP$prior_weight(target_data)

#### Arguments

- `target_data`:

  The target data for the analysis.

#### Returns

The posterior weight.

------------------------------------------------------------------------

### `GaussianRMP$prior_pdf()`

Calculate the prior probability density function (PDF) for a given
target treatment effect.

#### Usage

    GaussianRMP$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `GaussianRMP$prior_cdf()`

Calculate the prior cumulative distribution function (CDF) for a given
target treatment effect.

#### Usage

    GaussianRMP$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior CDF.

------------------------------------------------------------------------

### `GaussianRMP$posterior_moments()`

Calculate the posterior moments based on the target data.

#### Usage

    GaussianRMP$posterior_moments(target_data)

#### Arguments

- `target_data`:

  A list containing the target data for the analysis.

------------------------------------------------------------------------

### `GaussianRMP$posterior_pdf()`

Calculate the posterior probability density function (PDF) for a given
target treatment effect.

#### Usage

    GaussianRMP$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The posterior PDF.

------------------------------------------------------------------------

### `GaussianRMP$posterior_cdf()`

Calculate the posterior cumulative distribution function (CDF) for a
given target treatment effect.

#### Usage

    GaussianRMP$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The posterior CDF.

------------------------------------------------------------------------

### `GaussianRMP$sample_prior()`

Sample from the prior distribution.

#### Usage

    GaussianRMP$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

#### Returns

The samples from the prior distribution.

------------------------------------------------------------------------

### `GaussianRMP$sample_posterior()`

Sample from the posterior distribution.

#### Usage

    GaussianRMP$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

#### Returns

The samples from the posterior distribution.

------------------------------------------------------------------------

### `GaussianRMP$posterior_mean()`

Calculate the posterior mean.

#### Usage

    GaussianRMP$posterior_mean()

#### Returns

The posterior mean.

------------------------------------------------------------------------

### `GaussianRMP$posterior_variance()`

Calculate the posterior variance.

#### Usage

    GaussianRMP$posterior_variance()

#### Returns

The posterior variance.

------------------------------------------------------------------------

### `GaussianRMP$prior_to_RBesT()`

Convert the prior distribution to the RBesT format.

#### Usage

    GaussianRMP$prior_to_RBesT(...)

#### Arguments

- `...`:

  Additional arguments.

------------------------------------------------------------------------

### `GaussianRMP$posterior_to_RBesT()`

Convert the posterior distribution to the RBesT format.

#### Usage

    GaussianRMP$posterior_to_RBesT(target_data, ...)

#### Arguments

- `target_data`:

  Target data for the analysis.

- `...`:

  Additional arguments.

------------------------------------------------------------------------

### `GaussianRMP$print_model_summary()`

Print a summary of the model attributes

This method creates and prints a formatted table of key model
attributes.

#### Usage

    GaussianRMP$print_model_summary()

#### Returns

A printed data frame displaying the following model attributes:

- Posterior Weight

- Vague Posterior Mean

- Vague Posterior Variance

- Informative Posterior Mean

- Informative Posterior Variance

All numeric values are formatted to 6 decimal places.

------------------------------------------------------------------------

### `GaussianRMP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianRMP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
