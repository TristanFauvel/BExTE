# ConjugateGaussian class

This class represents a conjugate Gaussian model (Gaussian prior and
Gaussian likelihood)

## Super class

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
`ConjugateGaussian`

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

- [`ConjugateGaussian$new()`](#method-ConjugateGaussian-initialize)

- [`ConjugateGaussian$sample_prior()`](#method-ConjugateGaussian-sample_prior)

- [`ConjugateGaussian$sample_posterior()`](#method-ConjugateGaussian-sample_posterior)

- [`ConjugateGaussian$prior_pdf()`](#method-ConjugateGaussian-prior_pdf)

- [`ConjugateGaussian$prior_cdf()`](#method-ConjugateGaussian-prior_cdf)

- [`ConjugateGaussian$posterior_cdf()`](#method-ConjugateGaussian-posterior_cdf)

- [`ConjugateGaussian$posterior_pdf()`](#method-ConjugateGaussian-posterior_pdf)

- [`ConjugateGaussian$posterior_mean()`](#method-ConjugateGaussian-posterior_mean)

- [`ConjugateGaussian$posterior_variance()`](#method-ConjugateGaussian-posterior_variance)

- [`ConjugateGaussian$posterior_moments()`](#method-ConjugateGaussian-posterior_moments)

- [`ConjugateGaussian$vectorised_replicate_inference()`](#method-ConjugateGaussian-vectorised_replicate_inference)

- [`ConjugateGaussian$vectorised_prior_variance()`](#method-ConjugateGaussian-vectorised_prior_variance)

- [`ConjugateGaussian$vectorised_posterior_parameters()`](#method-ConjugateGaussian-vectorised_posterior_parameters)

- [`ConjugateGaussian$posterior_median()`](#method-ConjugateGaussian-posterior_median)

- [`ConjugateGaussian$credible_interval()`](#method-ConjugateGaussian-credible_interval)

- [`ConjugateGaussian$prior_to_RBesT()`](#method-ConjugateGaussian-prior_to_RBesT)

- [`ConjugateGaussian$posterior_to_RBesT()`](#method-ConjugateGaussian-posterior_to_RBesT)

- [`ConjugateGaussian$clone()`](#method-ConjugateGaussian-clone)

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

------------------------------------------------------------------------

### `ConjugateGaussian$new()`

Initialize object from the ConjugateGaussian class

#### Usage

    ConjugateGaussian$new(prior)

#### Arguments

- `prior`:

  Prior

------------------------------------------------------------------------

### `ConjugateGaussian$sample_prior()`

Sample from the prior

#### Usage

    ConjugateGaussian$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples from the prior

------------------------------------------------------------------------

### `ConjugateGaussian$sample_posterior()`

Sample from the posterior

#### Usage

    ConjugateGaussian$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples from the posterior

------------------------------------------------------------------------

### `ConjugateGaussian$prior_pdf()`

Prior PDF

#### Usage

    ConjugateGaussian$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior PDF

------------------------------------------------------------------------

### `ConjugateGaussian$prior_cdf()`

Prior CDF

#### Usage

    ConjugateGaussian$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior CDF

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_cdf()`

Posterior CDF

#### Usage

    ConjugateGaussian$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior CDF

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_pdf()`

Posterior PDF

#### Usage

    ConjugateGaussian$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior PDF

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_mean()`

Posterior mean

#### Usage

    ConjugateGaussian$posterior_mean(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_variance()`

Posterior variance

#### Usage

    ConjugateGaussian$posterior_variance(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_moments()`

Posterior moments

#### Usage

    ConjugateGaussian$posterior_moments(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `ConjugateGaussian$vectorised_replicate_inference()`

Run every replicate at once

The prior is a single normal, so the posterior is available in closed
form for all replicates simultaneously. Empirical Bayes subclasses
re-derive the prior variance from each replicate; they supply it through
`vectorised_prior_variance()`.

#### Usage

    ConjugateGaussian$vectorised_replicate_inference(
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

### `ConjugateGaussian$vectorised_prior_variance()`

Prior variance for each replicate

Declines the vectorised path by default. Subclasses with a genuinely
fixed prior return it, and empirical Bayes subclasses return one
variance per replicate.

#### Usage

    ConjugateGaussian$vectorised_prior_variance(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A scalar, a vector with one entry per replicate, or `NULL`.

------------------------------------------------------------------------

### `ConjugateGaussian$vectorised_posterior_parameters()`

Posterior parameters reported by the vectorised path

The plain conjugate models report none. Empirical Bayes subclasses
override this to report the power parameter they estimated.

#### Usage

    ConjugateGaussian$vectorised_posterior_parameters(prior_variance)

#### Arguments

- `prior_variance`:

  Per-replicate prior variance.

#### Returns

A data frame, or `NULL`.

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_median()`

Posterior median

#### Usage

    ConjugateGaussian$posterior_median(...)

#### Arguments

- `...`:

  Additional argument

#### Returns

The posterior median

------------------------------------------------------------------------

### `ConjugateGaussian$credible_interval()`

Credible interval

#### Usage

    ConjugateGaussian$credible_interval(level = 0.95)

#### Arguments

- `level`:

  Level of the credible interval

------------------------------------------------------------------------

### `ConjugateGaussian$prior_to_RBesT()`

Convert the prior to RBesT format

#### Usage

    ConjugateGaussian$prior_to_RBesT(...)

#### Arguments

- `...`:

  Additional arguments

------------------------------------------------------------------------

### `ConjugateGaussian$posterior_to_RBesT()`

Convert the posterior distribution to RBesT format

#### Usage

    ConjugateGaussian$posterior_to_RBesT(target_data, ...)

#### Arguments

- `target_data`:

  Target study data

- `...`:

  Additional arguments

------------------------------------------------------------------------

### `ConjugateGaussian$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ConjugateGaussian$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
