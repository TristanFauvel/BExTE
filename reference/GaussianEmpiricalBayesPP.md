# GaussianEmpiricalBayesPP class

This is a parent class for variants of empirical Bayes PP methods for
normally distributed summary measure of the treatment effect.

## Format

R6Class object.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`GaussianConjugate`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.md)
-\> `GaussianStaticBorrowing` -\> `GaussianEmpiricalBayesPP`

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

- [`GaussianEmpiricalBayesPP$new()`](#method-GaussianEmpiricalBayesPP-initialize)

- [`GaussianEmpiricalBayesPP$empirical_bayes_update()`](#method-GaussianEmpiricalBayesPP-empirical_bayes_update)

- [`GaussianEmpiricalBayesPP$inference()`](#method-GaussianEmpiricalBayesPP-inference)

- [`GaussianEmpiricalBayesPP$power_parameter_estimation()`](#method-GaussianEmpiricalBayesPP-power_parameter_estimation)

- [`GaussianEmpiricalBayesPP$vectorised_power_parameter()`](#method-GaussianEmpiricalBayesPP-vectorised_power_parameter)

- [`GaussianEmpiricalBayesPP$vectorised_prior_variance()`](#method-GaussianEmpiricalBayesPP-vectorised_prior_variance)

- [`GaussianEmpiricalBayesPP$vectorised_posterior_parameters()`](#method-GaussianEmpiricalBayesPP-vectorised_posterior_parameters)

- [`GaussianEmpiricalBayesPP$prior_pdf()`](#method-GaussianEmpiricalBayesPP-prior_pdf)

- [`GaussianEmpiricalBayesPP$plot_power_parameter_vs_drift()`](#method-GaussianEmpiricalBayesPP-plot_power_parameter_vs_drift)

- [`GaussianEmpiricalBayesPP$clone()`](#method-GaussianEmpiricalBayesPP-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$print_model_summary()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-print_model_summary)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`GaussianConjugate$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-credible_interval)
- [`GaussianConjugate$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_cdf)
- [`GaussianConjugate$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_mean)
- [`GaussianConjugate$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_median)
- [`GaussianConjugate$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_moments)
- [`GaussianConjugate$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_pdf)
- [`GaussianConjugate$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_to_RBesT)
- [`GaussianConjugate$posterior_variance()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_variance)
- [`GaussianConjugate$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-prior_cdf)
- [`GaussianConjugate$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-prior_to_RBesT)
- [`GaussianConjugate$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-sample_posterior)
- [`GaussianConjugate$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-sample_prior)
- [`GaussianConjugate$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-vectorised_replicate_inference)
- `GaussianStaticBorrowing$summary_rows()`

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$new()`

Initialize the GaussianEmpiricalBayesPP object.

#### Usage

    GaussianEmpiricalBayesPP$new(prior, null_space, theta_0)

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

### `GaussianEmpiricalBayesPP$empirical_bayes_update()`

Empirical Bayes update

#### Usage

    GaussianEmpiricalBayesPP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Target study data

#### Returns

NULL Perform inference using the GaussianEmpiricalBayesPP method.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$inference()`

#### Usage

    GaussianEmpiricalBayesPP$inference(target_data)

#### Arguments

- `target_data`:

  The target data.

#### Returns

The inference result. Estimate the power parameter.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$power_parameter_estimation()`

#### Usage

    GaussianEmpiricalBayesPP$power_parameter_estimation()

#### Returns

The estimated power parameter.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$vectorised_power_parameter()`

Estimate the power parameter for every replicate at once

Subclasses whose estimator is closed form override this. Returning
`NULL` means "no fast path", which keeps subclasses with an iterative
estimator (PDCCPP calibrates by search) on the replicate loop.

#### Usage

    GaussianEmpiricalBayesPP$vectorised_power_parameter(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of power parameters, or `NULL`.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$vectorised_prior_variance()`

Prior variance for each replicate

Mirrors `empirical_bayes_update()`: the power prior is equivalent to a
Gaussian prior with variance
`source standard error^2 / power parameter`, and a power parameter of
zero means a vague prior.

#### Usage

    GaussianEmpiricalBayesPP$vectorised_prior_variance(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of prior variances, or `NULL`.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path

#### Usage

    GaussianEmpiricalBayesPP$vectorised_posterior_parameters(prior_variance)

#### Arguments

- `prior_variance`:

  Per-replicate prior variance.

#### Returns

A data frame with one `power_parameter` column.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$prior_pdf()`

Calculate the prior probability density function (PDF) for a given
target treatment effect.

#### Usage

    GaussianEmpiricalBayesPP$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `GaussianEmpiricalBayesPP$plot_power_parameter_vs_drift()`

Plot the power parameter as a function of drift in treatment effect

#### Usage

    GaussianEmpiricalBayesPP$plot_power_parameter_vs_drift(
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

### `GaussianEmpiricalBayesPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianEmpiricalBayesPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
