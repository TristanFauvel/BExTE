# GaussianRMP_RBesT class

A class for Gaussian Robust Mixture Prior models using RBesT for
inference.

## Details

This class represents a Gaussian Robust Mixture Prior model. It inherits
from the Model class. Inference is performed using RBesT.

This class extends the Model_RBesT class and provides methods for
initializing the model, updating priors, calculating posterior moments,
and converting distributions to RBesT format.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`Model_RBesT`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.md)
-\> `GaussianRMP_RBesT`

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

  Method name

## Methods

### Public methods

- [`GaussianRMP_RBesT$new()`](#method-GaussianRMP_RBesT-initialize)

- [`GaussianRMP_RBesT$empirical_bayes_update()`](#method-GaussianRMP_RBesT-empirical_bayes_update)

- [`GaussianRMP_RBesT$posterior_moments()`](#method-GaussianRMP_RBesT-posterior_moments)

- [`GaussianRMP_RBesT$prior_to_RBesT()`](#method-GaussianRMP_RBesT-prior_to_RBesT)

- [`GaussianRMP_RBesT$posterior_to_RBesT()`](#method-GaussianRMP_RBesT-posterior_to_RBesT)

- [`GaussianRMP_RBesT$vectorised_prior_components()`](#method-GaussianRMP_RBesT-vectorised_prior_components)

- [`GaussianRMP_RBesT$vectorised_posterior_parameters()`](#method-GaussianRMP_RBesT-vectorised_posterior_parameters)

- [`GaussianRMP_RBesT$print_model_summary()`](#method-GaussianRMP_RBesT-print_model_summary)

- [`GaussianRMP_RBesT$clone()`](#method-GaussianRMP_RBesT-clone)

Inherited methods

- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference)
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

------------------------------------------------------------------------

### `GaussianRMP_RBesT$new()`

Initialize a new GaussianRMP_RBesT object.

#### Usage

    GaussianRMP_RBesT$new(prior)

#### Arguments

- `prior`:

  A list containing prior information for the analysis.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$empirical_bayes_update()`

Update the vague prior variance based on empirical Bayes approach.

#### Usage

    GaussianRMP_RBesT$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  A list containing the target data for the analysis.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$posterior_moments()`

Calculate the posterior moments based on the target data.

#### Usage

    GaussianRMP_RBesT$posterior_moments(target_data)

#### Arguments

- `target_data`:

  A list containing the target data for the analysis.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$prior_to_RBesT()`

Convert the prior distribution to the RBesT format.

#### Usage

    GaussianRMP_RBesT$prior_to_RBesT(...)

#### Arguments

- `...`:

  Additional arguments.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$posterior_to_RBesT()`

Convert the posterior distribution to the RBesT format.

#### Usage

    GaussianRMP_RBesT$posterior_to_RBesT(target_data, ...)

#### Arguments

- `target_data`:

  Target data for the analysis.

- `...`:

  Additional arguments.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$vectorised_prior_components()`

Prior mixture components for each replicate.

Under empirical Bayes the vague component's variance is re-derived from
each replicate, matching `empirical_bayes_update()`, so the prior varies
by row. Otherwise the same two components serve every replicate.

A degenerate weight collapses the mixture to a single component, exactly
as the scalar path does to work around an RBesT ELIR bug.

#### Usage

    GaussianRMP_RBesT$vectorised_prior_components(target_data, samples)

#### Arguments

- `target_data`:

  Target data for the analysis.

- `samples`:

  Data frame of generated replicates.

#### Returns

A list with `weights`, `means` and `sds`.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path.

The scalar path records the posterior weight on the informative
component, which is 0 or 1 when the mixture has collapsed.

#### Usage

    GaussianRMP_RBesT$vectorised_posterior_parameters(posterior)

#### Arguments

- `posterior`:

  Posterior mixture from
  [`normal_mixture_posterior()`](https://tristanfauvel.github.io/BExTE/reference/normal_mixture_posterior.md).

#### Returns

A data frame with one `prior_weight` column.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$print_model_summary()`

Print a summary of the model attributes

This method creates and prints a formatted table of key model
attributes.

#### Usage

    GaussianRMP_RBesT$print_model_summary()

#### Returns

A printed data frame displaying the following model attributes:

- Posterior Weight

- Vague Posterior Mean

- Vague Posterior Variance

- Informative Posterior Mean

- Informative Posterior Variance

All numeric values are formatted to 6 decimal places.

------------------------------------------------------------------------

### `GaussianRMP_RBesT$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianRMP_RBesT$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
