# Model_RBesT

An R6 class representing a Bayesian model using RBesT.

## Super class

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\> `Model_RBesT`

## Public fields

- `posterior_summary`:

  Summary of the posterior distribution

## Methods

### Public methods

- [`Model_RBesT$new()`](#method-Model_RBesT-initialize)

- [`Model_RBesT$prior_pdf()`](#method-Model_RBesT-prior_pdf)

- [`Model_RBesT$prior_cdf()`](#method-Model_RBesT-prior_cdf)

- [`Model_RBesT$posterior_moments()`](#method-Model_RBesT-posterior_moments)

- [`Model_RBesT$posterior_mean()`](#method-Model_RBesT-posterior_mean)

- [`Model_RBesT$posterior_variance()`](#method-Model_RBesT-posterior_variance)

- [`Model_RBesT$posterior_median()`](#method-Model_RBesT-posterior_median)

- [`Model_RBesT$posterior_pdf()`](#method-Model_RBesT-posterior_pdf)

- [`Model_RBesT$posterior_cdf()`](#method-Model_RBesT-posterior_cdf)

- [`Model_RBesT$sample_prior()`](#method-Model_RBesT-sample_prior)

- [`Model_RBesT$sample_posterior()`](#method-Model_RBesT-sample_posterior)

- [`Model_RBesT$prior_to_RBesT()`](#method-Model_RBesT-prior_to_RBesT)

- [`Model_RBesT$posterior_to_RBesT()`](#method-Model_RBesT-posterior_to_RBesT)

- [`Model_RBesT$credible_interval()`](#method-Model_RBesT-credible_interval)

- [`Model_RBesT$vectorised_prior_components()`](#method-Model_RBesT-vectorised_prior_components)

- [`Model_RBesT$vectorised_posterior_parameters()`](#method-Model_RBesT-vectorised_posterior_parameters)

- [`Model_RBesT$vectorised_replicate_inference()`](#method-Model_RBesT-vectorised_replicate_inference)

- [`Model_RBesT$clone()`](#method-Model_RBesT-clone)

Inherited methods

- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)

------------------------------------------------------------------------

### `Model_RBesT$new()`

Initializes the GaussianRMP object

#### Usage

    Model_RBesT$new(prior)

#### Arguments

- `prior`:

  The prior information for the analysis.

------------------------------------------------------------------------

### `Model_RBesT$prior_pdf()`

Calculates the prior probability density function (PDF) for a given
target treatment effect.

#### Usage

    Model_RBesT$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `Model_RBesT$prior_cdf()`

Calculates the prior cumulative distribution function (CDF) for a given
target treatment effect.

#### Usage

    Model_RBesT$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior CDF.

------------------------------------------------------------------------

### `Model_RBesT$posterior_moments()`

Calculates the posterior moments based on the target data.

#### Usage

    Model_RBesT$posterior_moments(target_data)

#### Arguments

- `target_data`:

  The target data for the analysis.

#### Returns

None

------------------------------------------------------------------------

### `Model_RBesT$posterior_mean()`

Calculates the posterior mean.

#### Usage

    Model_RBesT$posterior_mean()

#### Returns

The posterior mean.

------------------------------------------------------------------------

### `Model_RBesT$posterior_variance()`

Calculates the posterior variance.

#### Usage

    Model_RBesT$posterior_variance()

#### Returns

The posterior variance.

------------------------------------------------------------------------

### `Model_RBesT$posterior_median()`

Calculates the posterior median.

#### Usage

    Model_RBesT$posterior_median(...)

#### Arguments

- `...`:

  Additional arguments

#### Returns

The posterior median.

------------------------------------------------------------------------

### `Model_RBesT$posterior_pdf()`

Calculates the posterior probability density function (PDF) for a given
target treatment effect.

#### Usage

    Model_RBesT$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The posterior PDF.

------------------------------------------------------------------------

### `Model_RBesT$posterior_cdf()`

Calculates the posterior cumulative distribution function (CDF) for a
given target treatment effect.

#### Usage

    Model_RBesT$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The posterior CDF.

------------------------------------------------------------------------

### `Model_RBesT$sample_prior()`

Samples from the prior distribution.

#### Usage

    Model_RBesT$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

#### Returns

The samples from the prior distribution.

------------------------------------------------------------------------

### `Model_RBesT$sample_posterior()`

Samples from the posterior distribution.

#### Usage

    Model_RBesT$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

#### Returns

The samples from the posterior distribution.

------------------------------------------------------------------------

### `Model_RBesT$prior_to_RBesT()`

Converts the prior distribution to the RBesT format.

#### Usage

    Model_RBesT$prior_to_RBesT(...)

#### Arguments

- `...`:

  Additional arguments

#### Returns

None

------------------------------------------------------------------------

### `Model_RBesT$posterior_to_RBesT()`

Converts the posterior distribution to the RBesT format.

#### Usage

    Model_RBesT$posterior_to_RBesT(target_data, ...)

#### Arguments

- `target_data`:

  Target study data

- `...`:

  Additional arguments

------------------------------------------------------------------------

### `Model_RBesT$credible_interval()`

Calculates the credible interval.

#### Usage

    Model_RBesT$credible_interval(level = 0.95)

#### Arguments

- `level`:

  Level of the credible interval.

#### Returns

A vector containing the lower and upper bounds of the credible interval.

------------------------------------------------------------------------

### `Model_RBesT$vectorised_prior_components()`

Prior mixture components for each replicate

Subclasses return the `weights`, `means` and `sds` of their prior,
either as vectors shared by every replicate or as matrices with one row
per replicate. Returning `NULL` disables the vectorised path.

#### Usage

    Model_RBesT$vectorised_prior_components(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A list with `weights`, `means` and `sds`, or `NULL`.

------------------------------------------------------------------------

### `Model_RBesT$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path

#### Usage

    Model_RBesT$vectorised_posterior_parameters(posterior)

#### Arguments

- `posterior`:

  Posterior mixture returned by
  [`normal_mixture_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/normal_mixture_posterior.md).

#### Returns

A data frame, or `NULL`.

------------------------------------------------------------------------

### `Model_RBesT$vectorised_replicate_inference()`

Run every replicate at once

#### Usage

    Model_RBesT$vectorised_replicate_inference(
      target_data,
      samples,
      to_return,
      critical_value,
      theta_0,
      confidence_level,
      null_space
    )

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

- `to_return`:

  Character vector of requested outputs.

- `critical_value`:

  Critical value for hypothesis testing.

- `theta_0`:

  Null hypothesis value.

- `confidence_level`:

  Confidence level for the credible interval.

- `null_space`:

  The null space for hypothesis testing.

#### Returns

A list of simulation results, or `NULL` to use the replicate loop.

------------------------------------------------------------------------

### `Model_RBesT$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Model_RBesT$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
