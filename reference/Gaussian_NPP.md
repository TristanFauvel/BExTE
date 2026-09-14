# Gaussian_NPP class

This class represents a Gaussian model using the NPP (Noninformative
Power Prior) approach. It inherits from the Model class.

## Super class

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
`Gaussian_NPP`

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

- [`Gaussian_NPP$new()`](#method-Gaussian_NPP-initialize)

- [`Gaussian_NPP$unnormalized_posterior_power_parameter_pdf()`](#method-Gaussian_NPP-unnormalized_posterior_power_parameter_pdf)

- [`Gaussian_NPP$power_parameter_posterior_pdf()`](#method-Gaussian_NPP-power_parameter_posterior_pdf)

- [`Gaussian_NPP$normalizing_constant_power_parameter()`](#method-Gaussian_NPP-normalizing_constant_power_parameter)

- [`Gaussian_NPP$vectorised_replicate_inference()`](#method-Gaussian_NPP-vectorised_replicate_inference)

- [`Gaussian_NPP$inference()`](#method-Gaussian_NPP-inference)

- [`Gaussian_NPP$credible_interval()`](#method-Gaussian_NPP-credible_interval)

- [`Gaussian_NPP$posterior_median()`](#method-Gaussian_NPP-posterior_median)

- [`Gaussian_NPP$sample_posterior()`](#method-Gaussian_NPP-sample_posterior)

- [`Gaussian_NPP$sample_prior()`](#method-Gaussian_NPP-sample_prior)

- [`Gaussian_NPP$posterior_cdf()`](#method-Gaussian_NPP-posterior_cdf)

- [`Gaussian_NPP$posterior_pdf()`](#method-Gaussian_NPP-posterior_pdf)

- [`Gaussian_NPP$prior_pdf()`](#method-Gaussian_NPP-prior_pdf)

- [`Gaussian_NPP$plot_power_parameter_posterior_pdf()`](#method-Gaussian_NPP-plot_power_parameter_posterior_pdf)

- [`Gaussian_NPP$plot_power_parameter_vs_drift()`](#method-Gaussian_NPP-plot_power_parameter_vs_drift)

- [`Gaussian_NPP$clone()`](#method-Gaussian_NPP-clone)

Inherited methods

- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference_cache_scope()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_ess)
- [`Model$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_to_RBesT)
- [`Model$prior_ESS()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_ESS)
- [`Model$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_cdf)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)

------------------------------------------------------------------------

### `Gaussian_NPP$new()`

Initialize a new Gaussian_NPP object.

#### Usage

    Gaussian_NPP$new(prior)

#### Arguments

- `prior`:

  Prior object containing method parameters.

#### Returns

A new Gaussian_NPP object.

------------------------------------------------------------------------

### `Gaussian_NPP$unnormalized_posterior_power_parameter_pdf()`

Calculate the unnormalized posterior power parameter PDF.

#### Usage

    Gaussian_NPP$unnormalized_posterior_power_parameter_pdf(
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

### `Gaussian_NPP$power_parameter_posterior_pdf()`

Return the posterior distribution of the power parameter

#### Usage

    Gaussian_NPP$power_parameter_posterior_pdf(power_parameter, target_data)

#### Arguments

- `power_parameter`:

  Power parameter value.

- `target_data`:

  Target study data.

#### Returns

Posterior power parameter PDF value.

------------------------------------------------------------------------

### `Gaussian_NPP$normalizing_constant_power_parameter()`

Calculate the normalizing constant for the power parameter.

#### Usage

    Gaussian_NPP$normalizing_constant_power_parameter(target_data)

#### Arguments

- `target_data`:

  Target study data.

#### Returns

Normalizing constant value.

------------------------------------------------------------------------

### `Gaussian_NPP$vectorised_replicate_inference()`

Run every replicate at once

Discretising the Beta prior on the power parameter turns the method into
an ordinary normal mixture, so the posterior, its summaries and the
effective sample sizes all follow in closed form. This replaces the
nested numerical integration the replicate loop performs, in which each
evaluation of `posterior_cdf()` integrates over `posterior_pdf()`, which
itself integrates over the power parameter at every point.

The prior mixture is the same for every replicate, so it is built once.

#### Usage

    Gaussian_NPP$vectorised_replicate_inference(
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

### `Gaussian_NPP$inference()`

Perform inference on the target data.

#### Usage

    Gaussian_NPP$inference(target_data)

#### Arguments

- `target_data`:

  Target study data.

#### Returns

A string indicating the success status of the inference.

------------------------------------------------------------------------

### `Gaussian_NPP$credible_interval()`

Calculate the credible interval.

#### Usage

    Gaussian_NPP$credible_interval(level = 0.95)

#### Arguments

- `level`:

  Credible interval level (default: 0.95).

#### Returns

A vector containing the lower and upper bounds of the credible interval.

------------------------------------------------------------------------

### `Gaussian_NPP$posterior_median()`

Return the median of the posterior distribution.

#### Usage

    Gaussian_NPP$posterior_median(...)

#### Arguments

- `...`:

  Optional arguments

#### Returns

Median of the posterior distribution.

------------------------------------------------------------------------

### `Gaussian_NPP$sample_posterior()`

Sample from the posterior distribution.

#### Usage

    Gaussian_NPP$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw from the posterior distribution.

#### Returns

A vector of samples from the posterior distribution.

------------------------------------------------------------------------

### `Gaussian_NPP$sample_prior()`

Sample from the prior distribution.

#### Usage

    Gaussian_NPP$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw from the prior distribution.

#### Returns

A vector of samples from the prior distribution.

------------------------------------------------------------------------

### `Gaussian_NPP$posterior_cdf()`

Calculate the posterior cumulative distribution function (CDF).

#### Usage

    Gaussian_NPP$posterior_cdf(x)

#### Arguments

- `x`:

  Vector of points to evaluate the CDF at.

#### Returns

Vector of CDF values corresponding to the input points.

------------------------------------------------------------------------

### `Gaussian_NPP$posterior_pdf()`

Calculate the posterior probability density function (PDF).

#### Usage

    Gaussian_NPP$posterior_pdf(x)

#### Arguments

- `x`:

  Vector of points to evaluate the PDF at.

#### Returns

Vector of PDF values corresponding to the input points.

------------------------------------------------------------------------

### `Gaussian_NPP$prior_pdf()`

Calculate the prior probability density function (PDF).

#### Usage

    Gaussian_NPP$prior_pdf(x)

#### Arguments

- `x`:

  Vector of points to evaluate the PDF at.

#### Returns

Vector of PDF values corresponding to the input points.

------------------------------------------------------------------------

### `Gaussian_NPP$plot_power_parameter_posterior_pdf()`

Plot posterior probability density function (PDF) of the power parameter

#### Usage

    Gaussian_NPP$plot_power_parameter_posterior_pdf(target_data)

#### Arguments

- `target_data`:

  Target study data

#### Returns

A plot

------------------------------------------------------------------------

### `Gaussian_NPP$plot_power_parameter_vs_drift()`

Plot the power parameter as a function of drift in treatment effect

#### Usage

    Gaussian_NPP$plot_power_parameter_vs_drift(
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

### `Gaussian_NPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Gaussian_NPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
