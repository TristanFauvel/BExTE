# GaussianConjugate class

This class represents a conjugate Gaussian model (Gaussian prior and
Gaussian likelihood)

## Super class

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\> `GaussianConjugate`

## Public fields

- `prior_mean`:

  Prior mean

- `prior_var`:

  Prior variance

- `empirical_bayes`:

  Whether the method relies on empirical Bayes or not

- `post_mean`:

  Posterior mean

- `post_var`:

  Posterior variance

- `posterior_parameters`:

  Posterior parameters

## Methods

### Public methods

- [`GaussianConjugate$new()`](#method-GaussianConjugate-initialize)

- [`GaussianConjugate$sample_prior()`](#method-GaussianConjugate-sample_prior)

- [`GaussianConjugate$sample_posterior()`](#method-GaussianConjugate-sample_posterior)

- [`GaussianConjugate$prior_pdf()`](#method-GaussianConjugate-prior_pdf)

- [`GaussianConjugate$prior_cdf()`](#method-GaussianConjugate-prior_cdf)

- [`GaussianConjugate$posterior_cdf()`](#method-GaussianConjugate-posterior_cdf)

- [`GaussianConjugate$posterior_pdf()`](#method-GaussianConjugate-posterior_pdf)

- [`GaussianConjugate$posterior_mean()`](#method-GaussianConjugate-posterior_mean)

- [`GaussianConjugate$posterior_variance()`](#method-GaussianConjugate-posterior_variance)

- [`GaussianConjugate$posterior_moments()`](#method-GaussianConjugate-posterior_moments)

- [`GaussianConjugate$vectorised_replicate_inference()`](#method-GaussianConjugate-vectorised_replicate_inference)

- [`GaussianConjugate$vectorised_prior_variance()`](#method-GaussianConjugate-vectorised_prior_variance)

- [`GaussianConjugate$vectorised_posterior_parameters()`](#method-GaussianConjugate-vectorised_posterior_parameters)

- [`GaussianConjugate$posterior_median()`](#method-GaussianConjugate-posterior_median)

- [`GaussianConjugate$credible_interval()`](#method-GaussianConjugate-credible_interval)

- [`GaussianConjugate$prior_to_RBesT()`](#method-GaussianConjugate-prior_to_RBesT)

- [`GaussianConjugate$posterior_to_RBesT()`](#method-GaussianConjugate-posterior_to_RBesT)

- [`GaussianConjugate$clone()`](#method-GaussianConjugate-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference)
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
- [`Model$summary_rows()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-summary_rows)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)

------------------------------------------------------------------------

### `GaussianConjugate$new()`

Initialize object from the GaussianConjugate class

#### Usage

    GaussianConjugate$new(prior)

#### Arguments

- `prior`:

  Prior

------------------------------------------------------------------------

### `GaussianConjugate$sample_prior()`

Sample from the prior

#### Usage

    GaussianConjugate$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples from the prior

------------------------------------------------------------------------

### `GaussianConjugate$sample_posterior()`

Sample from the posterior

#### Usage

    GaussianConjugate$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples from the posterior

------------------------------------------------------------------------

### `GaussianConjugate$prior_pdf()`

Prior PDF

#### Usage

    GaussianConjugate$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior PDF

------------------------------------------------------------------------

### `GaussianConjugate$prior_cdf()`

Prior CDF

#### Usage

    GaussianConjugate$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior CDF

------------------------------------------------------------------------

### `GaussianConjugate$posterior_cdf()`

Posterior CDF

#### Usage

    GaussianConjugate$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior CDF

------------------------------------------------------------------------

### `GaussianConjugate$posterior_pdf()`

Posterior PDF

#### Usage

    GaussianConjugate$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior PDF

------------------------------------------------------------------------

### `GaussianConjugate$posterior_mean()`

Posterior mean

#### Usage

    GaussianConjugate$posterior_mean(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `GaussianConjugate$posterior_variance()`

Posterior variance

#### Usage

    GaussianConjugate$posterior_variance(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `GaussianConjugate$posterior_moments()`

Posterior moments

#### Usage

    GaussianConjugate$posterior_moments(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `GaussianConjugate$vectorised_replicate_inference()`

Run every replicate at once

The prior is a single normal, so the posterior is available in closed
form for all replicates simultaneously. Empirical Bayes subclasses
re-derive the prior variance from each replicate; they supply it through
`vectorised_prior_variance()`.

#### Usage

    GaussianConjugate$vectorised_replicate_inference(
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

### `GaussianConjugate$vectorised_prior_variance()`

Prior variance for each replicate

Declines the vectorised path by default. Subclasses with a genuinely
fixed prior return it, and empirical Bayes subclasses return one
variance per replicate.

#### Usage

    GaussianConjugate$vectorised_prior_variance(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A scalar, a vector with one entry per replicate, or `NULL`.

------------------------------------------------------------------------

### `GaussianConjugate$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path

The plain conjugate models report none. Empirical Bayes subclasses
override this to report the power parameter they estimated.

#### Usage

    GaussianConjugate$vectorised_posterior_parameters(prior_variance)

#### Arguments

- `prior_variance`:

  Per-replicate prior variance.

#### Returns

A data frame, or `NULL`.

------------------------------------------------------------------------

### `GaussianConjugate$posterior_median()`

Posterior median

#### Usage

    GaussianConjugate$posterior_median(...)

#### Arguments

- `...`:

  Additional argument

#### Returns

The posterior median

------------------------------------------------------------------------

### `GaussianConjugate$credible_interval()`

Credible interval

#### Usage

    GaussianConjugate$credible_interval(level = 0.95)

#### Arguments

- `level`:

  Level of the credible interval

------------------------------------------------------------------------

### `GaussianConjugate$prior_to_RBesT()`

Convert the prior to RBesT format

#### Usage

    GaussianConjugate$prior_to_RBesT(...)

#### Arguments

- `...`:

  Additional arguments

------------------------------------------------------------------------

### `GaussianConjugate$posterior_to_RBesT()`

Convert the posterior distribution to RBesT format

#### Usage

    GaussianConjugate$posterior_to_RBesT(target_data, ...)

#### Arguments

- `target_data`:

  Target study data

- `...`:

  Additional arguments

------------------------------------------------------------------------

### `GaussianConjugate$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianConjugate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
