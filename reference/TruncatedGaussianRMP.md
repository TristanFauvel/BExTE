# TruncatedGaussianRMP class

This class represents a Bayesian borrowing model with a truncated
Gaussian prior. It inherits from the MCMCModel class.

## Value

An R6 class object representing a TruncatedGaussianRMP model

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\> `TruncatedGaussianRMP`

## Public fields

- `w`:

  The weight parameter for the mixture prior

- `vague_prior_mean`:

  The mean of the vague prior distribution

- `vague_posterior_mean`:

  The mean of the vague posterior distribution

- `vague_prior_variance`:

  The variance of the vague prior distribution

- `vague_posterior_variance`:

  The variance of the vague posterior distribution

- `info_prior_mean`:

  The mean of the informative prior distribution

- `info_posterior_mean`:

  The mean of the informative posterior distribution

- `info_prior_variance`:

  The variance of the informative prior distribution

- `info_posterior_variance`:

  The variance of the informative posterior distribution

- `wpost`:

  The posterior weight parameter for the mixture prior

- `method`:

  Method name

## Methods

### Public methods

- [`TruncatedGaussianRMP$new()`](#method-TruncatedGaussianRMP-initialize)

- [`TruncatedGaussianRMP$empirical_bayes_update()`](#method-TruncatedGaussianRMP-empirical_bayes_update)

- [`TruncatedGaussianRMP$prior_elir_ess()`](#method-TruncatedGaussianRMP-prior_elir_ess)

- [`TruncatedGaussianRMP$prepare_data()`](#method-TruncatedGaussianRMP-prepare_data)

- [`TruncatedGaussianRMP$sample_prior()`](#method-TruncatedGaussianRMP-sample_prior)

- [`TruncatedGaussianRMP$inference()`](#method-TruncatedGaussianRMP-inference)

- [`TruncatedGaussianRMP$print_model_summary()`](#method-TruncatedGaussianRMP-print_model_summary)

- [`TruncatedGaussianRMP$clone()`](#method-TruncatedGaussianRMP-clone)

Inherited methods

- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)
- [`MCMCModel$check_mcmc_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$compute_posterior_parameters()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-compute_posterior_parameters)
- [`MCMCModel$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$draw_mcmc_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-draw_mcmc_prior)
- [`MCMCModel$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_pdf)
- [`MCMCModel$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_posterior)

------------------------------------------------------------------------

### `TruncatedGaussianRMP$new()`

Initialize the TruncatedGaussianRMP object

#### Usage

    TruncatedGaussianRMP$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object

- `mcmc_config`:

  The MCMC configuration parameters

------------------------------------------------------------------------

### `TruncatedGaussianRMP$empirical_bayes_update()`

Update the empirical Bayes parameters

#### Usage

    TruncatedGaussianRMP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  The target data for inference

------------------------------------------------------------------------

### `TruncatedGaussianRMP$prior_elir_ess()`

ELIR effective sample size of the current prior

The prior is a two-component normal mixture, each component truncated to
the interval the treatment effect is supported on, so the ELIR integral
is evaluated on it directly. The inherited route would instead draw from
the prior and fit an untruncated mixture to the draws, once per
replicate because the vague component is set by the observed target
standard error. That fit both costs a mixture fit per replicate and
overstates the local information, since it smooths away the truncation.

#### Usage

    TruncatedGaussianRMP$prior_elir_ess(target_data, ...)

#### Arguments

- `target_data`:

  Target study data, whose sampling standard deviation is the reference
  scale.

- `...`:

  Unused, kept so that the simulation can call every model the same way.

#### Returns

The ELIR effective sample size.

------------------------------------------------------------------------

### `TruncatedGaussianRMP$prepare_data()`

Prepare the data for use with Stan

#### Usage

    TruncatedGaussianRMP$prepare_data(target_data)

#### Arguments

- `target_data`:

  The target data for inference

#### Returns

A list of data prepared for Stan

------------------------------------------------------------------------

### `TruncatedGaussianRMP$sample_prior()`

Sample from the prior distribution

#### Usage

    TruncatedGaussianRMP$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to generate

#### Returns

A vector of samples from the prior distribution

------------------------------------------------------------------------

### `TruncatedGaussianRMP$inference()`

Inference

The reported prior weight is the posterior probability that the
treatment effect came from the informative component, which is what the
models with a normal summary measure report. It is taken over the same
counts and the same truncated mixture the Stan program was given, so the
two describe one model rather than an approximation of it: the prior
density at the observed estimate is not a component probability, and
unlike the normal case the truncation leaves no closed form to fall back
on.

#### Usage

    TruncatedGaussianRMP$inference(target_data)

#### Arguments

- `target_data`:

  Target data object

#### Returns

Indicator whether inference succeeded or not

------------------------------------------------------------------------

### `TruncatedGaussianRMP$print_model_summary()`

Print a summary of the model attributes

This method creates and prints a formatted table of key model
attributes.

#### Usage

    TruncatedGaussianRMP$print_model_summary()

#### Returns

A printed data frame displaying the following model attributes:

- Posterior Weight

- Vague Posterior Mean

- Vague Posterior Variance

- Informative Posterior Mean

- Informative Posterior Variance

All numeric values are formatted to 6 decimal places.

------------------------------------------------------------------------

### `TruncatedGaussianRMP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TruncatedGaussianRMP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
