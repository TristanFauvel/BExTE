# PoolGaussian_RBesT

An R6 class representing a pooled Gaussian model using RBesT.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`Model_RBesT`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.md)
-\> `PoolGaussian_RBesT`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [`PoolGaussian_RBesT$new()`](#method-PoolGaussian_RBesT-initialize)

- [`PoolGaussian_RBesT$prior_to_RBesT()`](#method-PoolGaussian_RBesT-prior_to_RBesT)

- [`PoolGaussian_RBesT$posterior_to_RBesT()`](#method-PoolGaussian_RBesT-posterior_to_RBesT)

- [`PoolGaussian_RBesT$vectorised_prior_components()`](#method-PoolGaussian_RBesT-vectorised_prior_components)

- [`PoolGaussian_RBesT$clone()`](#method-PoolGaussian_RBesT-clone)

Inherited methods

- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-empirical_bayes_update)
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
- [`Model_RBesT$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_moments)
- [`Model_RBesT$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_pdf)
- [`Model_RBesT$posterior_variance()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-posterior_variance)
- [`Model_RBesT$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-prior_cdf)
- [`Model_RBesT$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-prior_pdf)
- [`Model_RBesT$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-sample_posterior)
- [`Model_RBesT$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-sample_prior)
- [`Model_RBesT$vectorised_posterior_parameters()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-vectorised_posterior_parameters)
- [`Model_RBesT$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/Model_RBesT.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `PoolGaussian_RBesT$new()`

Initializes the PoolGaussian_RBesT object.

#### Usage

    PoolGaussian_RBesT$new(prior)

#### Arguments

- `prior`:

  Prior information for the analysis.

#### Returns

A new PoolGaussian_RBesT object.

------------------------------------------------------------------------

### `PoolGaussian_RBesT$prior_to_RBesT()`

Converts the prior distribution to the RBesT format.

#### Usage

    PoolGaussian_RBesT$prior_to_RBesT(...)

#### Arguments

- `...`:

  Additional arguments.

#### Returns

None

------------------------------------------------------------------------

### `PoolGaussian_RBesT$posterior_to_RBesT()`

Converts the posterior distribution to the RBesT format.

#### Usage

    PoolGaussian_RBesT$posterior_to_RBesT(target_data, ...)

#### Arguments

- `target_data`:

  Target study data object.

- `...`:

  Additional arguments.

#### Returns

None

------------------------------------------------------------------------

### `PoolGaussian_RBesT$vectorised_prior_components()`

Prior mixture components for each replicate.

#### Usage

    PoolGaussian_RBesT$vectorised_prior_components(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A list with `weights`, `means` and `sds`.

------------------------------------------------------------------------

### `PoolGaussian_RBesT$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PoolGaussian_RBesT$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
