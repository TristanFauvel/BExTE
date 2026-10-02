# GaussianNPP class

This class represents a Gaussian model using the NPP (Noninformative
Power Prior) approach. It inherits from the Model class.

## Super class

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\> `GaussianNPP`

## Public fields

- `power_parameter_mean`:

  The mean of the prior on the power parameter.

- `power_parameter_std`:

  The standard deviation of the prior on the power parameter.

- `target_treatment_effect_estimate`:

  Estimate of the treatment effect in the target study

- `target_treatment_effect_standard_error`:

  Standard error on the estimate of the treatment effect in the target
  study

- `p`:

  Parameter of the initial Beta prior on the power parameter

- `q`:

  Parameter of the initial Beta prior on the power parameter

- `prior_normconst`:

  Normalization constant of the prior

- `posterior_normconst`:

  Normalization constant of the posterior

- `max_posterior_pdf`:

  Maximum value of the posterior p.d.f., used for rejection sampling of
  the posterior p.d.f.

- `method`:

  Name of the method

- `summary_measure_likelihood`:

  Summary measure likelihood

## Methods

### Public methods

- [`GaussianNPP$summary_rows()`](#method-GaussianNPP-summary_rows)

- [`GaussianNPP$new()`](#method-GaussianNPP-initialize)

- [`GaussianNPP$unnormalized_posterior_power_parameter_pdf()`](#method-GaussianNPP-unnormalized_posterior_power_parameter_pdf)

- [`GaussianNPP$power_parameter_posterior_pdf()`](#method-GaussianNPP-power_parameter_posterior_pdf)

- [`GaussianNPP$normalizing_constant_power_parameter()`](#method-GaussianNPP-normalizing_constant_power_parameter)

- [`GaussianNPP$vectorised_replicate_inference()`](#method-GaussianNPP-vectorised_replicate_inference)

- [`GaussianNPP$inference()`](#method-GaussianNPP-inference)

- [`GaussianNPP$credible_interval()`](#method-GaussianNPP-credible_interval)

- [`GaussianNPP$posterior_median()`](#method-GaussianNPP-posterior_median)

- [`GaussianNPP$sample_posterior()`](#method-GaussianNPP-sample_posterior)

- [`GaussianNPP$sample_prior()`](#method-GaussianNPP-sample_prior)

- [`GaussianNPP$posterior_cdf()`](#method-GaussianNPP-posterior_cdf)

- [`GaussianNPP$posterior_pdf()`](#method-GaussianNPP-posterior_pdf)

- [`GaussianNPP$prior_pdf()`](#method-GaussianNPP-prior_pdf)

- [`GaussianNPP$plot_power_parameter_posterior_pdf()`](#method-GaussianNPP-plot_power_parameter_posterior_pdf)

- [`GaussianNPP$plot_power_parameter_vs_drift()`](#method-GaussianNPP-plot_power_parameter_vs_drift)

- [`GaussianNPP$clone()`](#method-GaussianNPP-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_ess)
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-print_model_summary)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_cdf)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)

------------------------------------------------------------------------

### `GaussianNPP$summary_rows()`

Rows of the model summary, with the prior on the power parameter

#### Usage

    GaussianNPP$summary_rows()

#### Returns

A data frame with columns `Attribute` and `Value`.

------------------------------------------------------------------------

### `GaussianNPP$new()`

Initialize a new GaussianNPP object.

#### Usage

    GaussianNPP$new(prior)

#### Arguments

- `prior`:

  Prior object containing method parameters.

#### Returns

A new GaussianNPP object.

------------------------------------------------------------------------

### `GaussianNPP$unnormalized_posterior_power_parameter_pdf()`

Calculate the unnormalized posterior power parameter PDF.

#### Usage

    GaussianNPP$unnormalized_posterior_power_parameter_pdf(
      power_parameter,
      target_data
    )

#### Arguments

- `power_parameter`:

  Power parameter value.

- `target_data`:

  Target study data.

#### Returns

Unnormalized posterior power parameter PDF value.

------------------------------------------------------------------------

### `GaussianNPP$power_parameter_posterior_pdf()`

Return the posterior distribution of the power parameter

#### Usage

    GaussianNPP$power_parameter_posterior_pdf(power_parameter, target_data)

#### Arguments

- `power_parameter`:

  Power parameter value.

- `target_data`:

  Target study data.

#### Returns

Posterior power parameter PDF value.

------------------------------------------------------------------------

### `GaussianNPP$normalizing_constant_power_parameter()`

Calculate the normalizing constant for the power parameter.

#### Usage

    GaussianNPP$normalizing_constant_power_parameter(target_data)

#### Arguments

- `target_data`:

  Target study data.

#### Returns

Normalizing constant value.

------------------------------------------------------------------------

### `GaussianNPP$vectorised_replicate_inference()`

Run every replicate at once

Discretising the Beta prior on the power parameter turns the method into
an ordinary normal mixture, so the posterior, its summaries and the
effective sample sizes all follow in closed form. This replaces the
nested numerical integration the replicate loop performs, in which each
evaluation of `posterior_cdf()` integrates over `posterior_pdf()`, which
itself integrates over the power parameter at every point.

The prior mixture is the same for every replicate, so it is built once.

#### Usage

    GaussianNPP$vectorised_replicate_inference(
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

A list of simulation results.

------------------------------------------------------------------------

### `GaussianNPP$inference()`

Perform inference on the target data.

#### Usage

    GaussianNPP$inference(target_data)

#### Arguments

- `target_data`:

  Target study data.

#### Returns

A string indicating the success status of the inference.

------------------------------------------------------------------------

### `GaussianNPP$credible_interval()`

Calculate the credible interval.

#### Usage

    GaussianNPP$credible_interval(level = 0.95)

#### Arguments

- `level`:

  Credible interval level (default: 0.95).

#### Returns

A vector containing the lower and upper bounds of the credible interval.

------------------------------------------------------------------------

### `GaussianNPP$posterior_median()`

Return the median of the posterior distribution.

#### Usage

    GaussianNPP$posterior_median(...)

#### Arguments

- `...`:

  Optional arguments

#### Returns

Median of the posterior distribution.

------------------------------------------------------------------------

### `GaussianNPP$sample_posterior()`

Sample from the posterior distribution.

#### Usage

    GaussianNPP$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw from the posterior distribution.

#### Returns

A vector of samples from the posterior distribution.

------------------------------------------------------------------------

### `GaussianNPP$sample_prior()`

Sample from the prior distribution.

#### Usage

    GaussianNPP$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw from the prior distribution.

#### Returns

A vector of samples from the prior distribution.

------------------------------------------------------------------------

### `GaussianNPP$posterior_cdf()`

Calculate the posterior cumulative distribution function (CDF).

#### Usage

    GaussianNPP$posterior_cdf(x)

#### Arguments

- `x`:

  Vector of points to evaluate the CDF at.

#### Returns

Vector of CDF values corresponding to the input points.

------------------------------------------------------------------------

### `GaussianNPP$posterior_pdf()`

Calculate the posterior probability density function (PDF).

#### Usage

    GaussianNPP$posterior_pdf(x)

#### Arguments

- `x`:

  Vector of points to evaluate the PDF at.

#### Returns

Vector of PDF values corresponding to the input points.

------------------------------------------------------------------------

### `GaussianNPP$prior_pdf()`

Calculate the prior probability density function (PDF).

#### Usage

    GaussianNPP$prior_pdf(x)

#### Arguments

- `x`:

  Vector of points to evaluate the PDF at.

#### Returns

Vector of PDF values corresponding to the input points.

------------------------------------------------------------------------

### `GaussianNPP$plot_power_parameter_posterior_pdf()`

Plot posterior probability density function (PDF) of the power parameter

#### Usage

    GaussianNPP$plot_power_parameter_posterior_pdf(target_data)

#### Arguments

- `target_data`:

  Target study data

#### Returns

A plot

------------------------------------------------------------------------

### `GaussianNPP$plot_power_parameter_vs_drift()`

Plot the power parameter as a function of drift in treatment effect

#### Usage

    GaussianNPP$plot_power_parameter_vs_drift(
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

### `GaussianNPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianNPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
