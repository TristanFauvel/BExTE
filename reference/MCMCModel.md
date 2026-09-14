# MCMCModel class

This class represents a Bayesian borrowing model using MCMC sampling. It
inherits from the Model class.

## Super class

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
`MCMCModel`

## Public fields

- `stan_model_code`:

  Code of the Stan model

- `stan_model`:

  The compiled Stan model

- `summary_variables`:

  Variables to summarise from the posterior draws

- `fit`:

  The MCMC fit object

- `fit_summary`:

  Summary of the Stan fit

- `treatment_effect_summary`:

  Summary statistics of the treatment effect posterior distribution

- `credible_interval_97.5`:

  The upper bound of the credible interval

- `credible_interval_2.5`:

  The lower bound of the credible interval

- `mcmc_config`:

  The MCMC configuration parameters

- `mcmc_ess`:

  MCMC ESS

- `n_divergences`:

  Number of divergences in MCMC inference

- `rhat`:

  r-hat statistics

- `draws_dir`:

  Directory where to store MCMC draws (used by Stan)

- `prior_draws`:

  Draws from the prior

- `prior_pdf_approx`:

  Approximation to the prior probability density function

- `prior_cdf_approx`:

  Approximation to the prior cumulative density function

- `posterior_pdf_approx`:

  Approximation to the posterior probability density function

- `posterior_cdf_approx`:

  Approximation to the posterior cumulative density function

## Methods

### Public methods

- [`MCMCModel$new()`](#method-MCMCModel-initialize)

- [`MCMCModel$check_mcmc_config()`](#method-MCMCModel-check_mcmc_config)

- [`MCMCModel$prepare_data()`](#method-MCMCModel-prepare_data)

- [`MCMCModel$inference()`](#method-MCMCModel-inference)

- [`MCMCModel$credible_interval()`](#method-MCMCModel-credible_interval)

- [`MCMCModel$posterior_ess()`](#method-MCMCModel-posterior_ess)

- [`MCMCModel$posterior_median()`](#method-MCMCModel-posterior_median)

- [`MCMCModel$sample_posterior()`](#method-MCMCModel-sample_posterior)

- [`MCMCModel$compute_posterior_parameters()`](#method-MCMCModel-compute_posterior_parameters)

- [`MCMCModel$draw_mcmc_prior()`](#method-MCMCModel-draw_mcmc_prior)

- [`MCMCModel$posterior_pdf()`](#method-MCMCModel-posterior_pdf)

- [`MCMCModel$posterior_cdf()`](#method-MCMCModel-posterior_cdf)

- [`MCMCModel$prior_pdf()`](#method-MCMCModel-prior_pdf)

- [`MCMCModel$prior_cdf()`](#method-MCMCModel-prior_cdf)

- [`MCMCModel$sample_prior()`](#method-MCMCModel-sample_prior)

- [`MCMCModel$clone()`](#method-MCMCModel-clone)

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
- [`Model$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_to_RBesT)
- [`Model$prior_ESS()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `MCMCModel$new()`

Initialize the MCMCModel object

#### Usage

    MCMCModel$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object

- `mcmc_config`:

  The MCMC configuration parameters

------------------------------------------------------------------------

### `MCMCModel$check_mcmc_config()`

Check validity of the MCMC configuration

#### Usage

    MCMCModel$check_mcmc_config(mcmc_config)

#### Arguments

- `mcmc_config`:

  MCMC configuration

------------------------------------------------------------------------

### `MCMCModel$prepare_data()`

Prepare the data for inference. Subclasses must implement the
'prepare_data' method.

#### Usage

    MCMCModel$prepare_data(target_data)

#### Arguments

- `target_data`:

  The target data for inference

------------------------------------------------------------------------

### `MCMCModel$inference()`

Perform inference using MCMC sampling

#### Usage

    MCMCModel$inference(target_data)

#### Arguments

- `target_data`:

  The target data for inference

------------------------------------------------------------------------

### `MCMCModel$credible_interval()`

Calculate the credible interval

#### Usage

    MCMCModel$credible_interval(level = 0.95)

#### Arguments

- `level`:

  The confidence level for the credible interval (default is 0.95)

#### Returns

The credible interval as a numeric vector

------------------------------------------------------------------------

### `MCMCModel$posterior_ess()`

Effective sample sizes of the current posterior

The single summary pass over the draws already produced the posterior
standard deviation and the credible interval bounds, so both effective
sample sizes read straight off it. The inherited route would resample
the draws and fit a mixture to the resample, which costs a mixture fit
per replicate and adds a second layer of Monte Carlo error on top of the
one the sampler already carries.

#### Usage

    MCMCModel$posterior_ess(target_data, ...)

#### Arguments

- `target_data`:

  Target study data

- `...`:

  Unused, kept so that the simulation can call every model the same way.

#### Returns

A list with the `moment` and `precision` effective sample sizes.

------------------------------------------------------------------------

### `MCMCModel$posterior_median()`

Get the posterior median

#### Usage

    MCMCModel$posterior_median(...)

#### Arguments

- `...`:

  Optional argument

#### Returns

The posterior median as a numeric value

------------------------------------------------------------------------

### `MCMCModel$sample_posterior()`

Sample from the posterior distribution

#### Usage

    MCMCModel$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to draw from the posterior distribution

#### Returns

The sampled treatment effect values as a numeric vector

------------------------------------------------------------------------

### `MCMCModel$compute_posterior_parameters()`

Compute the posterior parameters. If there are posterior borrowing
parameters, the following method must be overriden in the subclass.

#### Usage

    MCMCModel$compute_posterior_parameters()

------------------------------------------------------------------------

### `MCMCModel$draw_mcmc_prior()`

Draw samples from the prior using MCMC

#### Usage

    MCMCModel$draw_mcmc_prior()

------------------------------------------------------------------------

### `MCMCModel$posterior_pdf()`

Posterior PDF

#### Usage

    MCMCModel$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior PDF

------------------------------------------------------------------------

### `MCMCModel$posterior_cdf()`

Calculates the posterior cumulative distribution function (CDF) for a
given target treatment effect.

#### Usage

    MCMCModel$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The posterior CDF.

------------------------------------------------------------------------

### `MCMCModel$prior_pdf()`

Prior PDF

#### Usage

    MCMCModel$prior_pdf(
      target_treatment_effect,
      n_samples_quantile_estimation = 10000
    )

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior PDF

- `n_samples_quantile_estimation`:

  Number of samples used to estimate the quantiles of the distribution

------------------------------------------------------------------------

### `MCMCModel$prior_cdf()`

Prior CDF

#### Usage

    MCMCModel$prior_cdf(
      target_treatment_effect,
      n_samples_quantile_estimation = 10000
    )

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior CDF

- `n_samples_quantile_estimation`:

  Number of samples used to estimate the quantiles of the distribution

------------------------------------------------------------------------

### `MCMCModel$sample_prior()`

Sample from the prior distribution

#### Usage

    MCMCModel$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw

#### Returns

A vector of samples

------------------------------------------------------------------------

### `MCMCModel$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MCMCModel$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
