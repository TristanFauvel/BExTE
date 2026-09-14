# Model Class

This class represents a statistical model for Bayesian borrowing
analysis. It provides methods for creating the model, performing
inference, and calculating posterior moments.

## Public fields

- `empirical_bayes`:

  Logical indicating if empirical Bayes method is used.

- `analytic_ocs`:

  Results of the analytic operating characteristics simulation.

- `posterior_parameters`:

  Parameters of the posterior distribution.

- `post_mean`:

  Mean of the posterior distribution.

- `post_median`:

  Median of the posterior distribution.

- `prior_mean`:

  Mean of the prior distribution.

- `prior_var`:

  Variance of the prior distribution.

- `post_var`:

  Variance of the posterior distribution.

- `parameters`:

  List of model parameters.

- `RBesT_prior`:

  Prior distribution from RBesT package.

- `RBesT_posterior`:

  Posterior distribution from RBesT package.

- `ess_morita`:

  Effective sample size calculated using Morita's method.

- `ess_elir`:

  Effective sample size calculated using ELIR method.

- `ess_moment`:

  Effective sample size calculated using moment matching.

- `prior`:

  Prior distribution used in the model.

- `method`:

  Method used for the analysis.

- `mcmc`:

  Logical indicating if MCMC is used.

- `RBesT_posterior_normix`:

  Normal mixture approximation to the posterior distribution

- `RBesT_prior_normix`:

  Normal mixture approximation to the prior distribution

- `summary_measure_likelihood`:

  Likelihood familly, that is, the distribution used to model the
  summary measure of the treatment effect.

- `n_components_mixture_approx`:

  Number of mixture components used for the mixture approximation

- `aic_penalty_parameter_mixture_approx`:

  AIC penalty parameter used for the mixture approximation

- `n_nonestimable_replicates`:

  Replicates dropped by the last simulation because their target summary
  measure was undefined.

- `analysis_critical_value`:

  Posterior probability threshold the analysis decides at, recorded when
  a simulation starts. Methods whose tuning depends on the decision rule
  read it, so that they are tuned for the test that is actually
  performed.

## Methods

### Public methods

- [`Model$new()`](#method-Model-initialize)

- [`Model$create()`](#method-Model-create)

- [`Model$inference()`](#method-Model-inference)

- [`Model$vectorised_replicate_inference()`](#method-Model-vectorised_replicate_inference)

- [`Model$inference_cache_scope()`](#method-Model-inference_cache_scope)

- [`Model$check_data()`](#method-Model-check_data)

- [`Model$posterior_moments()`](#method-Model-posterior_moments)

- [`Model$prior_cdf()`](#method-Model-prior_cdf)

- [`Model$empirical_bayes_update()`](#method-Model-empirical_bayes_update)

- [`Model$posterior_mean()`](#method-Model-posterior_mean)

- [`Model$posterior_quantile()`](#method-Model-posterior_quantile)

- [`Model$posterior_median()`](#method-Model-posterior_median)

- [`Model$credible_interval()`](#method-Model-credible_interval)

- [`Model$prior_ESS()`](#method-Model-prior_ESS)

- [`Model$sample_prior()`](#method-Model-sample_prior)

- [`Model$sample_posterior()`](#method-Model-sample_posterior)

- [`Model$test_decision()`](#method-Model-test_decision)

- [`Model$simulation_for_given_treatment_effect()`](#method-Model-simulation_for_given_treatment_effect)

- [`Model$prior_treatment_benefit()`](#method-Model-prior_treatment_benefit)

- [`Model$estimate_frequentist_operating_characteristics()`](#method-Model-estimate_frequentist_operating_characteristics)

- [`Model$estimate_bayesian_operating_characteristics()`](#method-Model-estimate_bayesian_operating_characteristics)

- [`Model$prior_to_RBesT()`](#method-Model-prior_to_RBesT)

- [`Model$prior_elir_ess()`](#method-Model-prior_elir_ess)

- [`Model$posterior_ess()`](#method-Model-posterior_ess)

- [`Model$posterior_to_RBesT()`](#method-Model-posterior_to_RBesT)

- [`Model$posterior_beta_mixture()`](#method-Model-posterior_beta_mixture)

- [`Model$plot_pdfs()`](#method-Model-plot_pdfs)

- [`Model$plot_prior_pdf()`](#method-Model-plot_prior_pdf)

- [`Model$plot_posterior_pdf()`](#method-Model-plot_posterior_pdf)

- [`Model$clone()`](#method-Model-clone)

------------------------------------------------------------------------

### `Model$new()`

Initialize the Model object

Create a Model object

#### Usage

    Model$new()

------------------------------------------------------------------------

### `Model$create()`

This method creates a Model object based on the specified configuration
and method.

#### Usage

    Model$create(
      case_study_config,
      method,
      method_parameters,
      source_data,
      mcmc_config = NULL
    )

#### Arguments

- `case_study_config`:

  A list containing the case study configuration.

- `method`:

  The method to be used for the analysis.

- `method_parameters`:

  A list containing the method parameters.

- `source_data`:

  Source data

- `mcmc_config`:

  An optional list containing the MCMC configuration.

#### Returns

A Model object.

------------------------------------------------------------------------

### `Model$inference()`

Perform inference on the Model object

#### Usage

    Model$inference(target_data)

#### Arguments

- `target_data`:

  The target data for the inference

#### Returns

A string "Success" if inference succeeded

------------------------------------------------------------------------

### `Model$vectorised_replicate_inference()`

Run every replicate at once, when the method allows it

Methods with a closed-form posterior can produce the whole simulation
output with vector arithmetic instead of one inference per replicate.
Subclasses that can do so override this method; returning `NULL` means
"no fast path available", and
`Model$simulation_for_given_treatment_effect()` falls back to the
replicate loop.

#### Usage

    Model$vectorised_replicate_inference(...)

#### Arguments

- `...`:

  Arguments describing the simulation, passed through by
  `Model$simulation_for_given_treatment_effect()`.

#### Returns

`NULL`, or a list shaped like the return value of
`Model$simulation_for_given_treatment_effect()`.

------------------------------------------------------------------------

### `Model$inference_cache_scope()`

Scenario identity under which replicate analyses may be shared

Two replicates may share an analysis only when everything the analysis
reads, apart from the observed data, is the same. That is what this
identifies. The drift is deliberately absent: it moves the sampling
distribution of the data rather than the posterior any particular data
set implies, so scenarios differing only in drift share this scope and
meet in the cache.

Returning `NULL` means "do not cache", which is the default. Opting in
is left to subclasses because it is only sound for a model whose
reported results are a deterministic function of the data: a model that
samples, as the Stan backed ones and the empirical Bayes prior refits
do, would otherwise have one replicate's Monte Carlo error stand in for
another's.

#### Usage

    Model$inference_cache_scope(
      target_data,
      critical_value,
      theta_0,
      confidence_level,
      null_space,
      n_samples_quantiles_estimation,
      simulation_config
    )

#### Arguments

- `target_data`:

  Target study data.

- `critical_value`:

  Critical value for hypothesis testing.

- `theta_0`:

  Null hypothesis value.

- `confidence_level`:

  Confidence level for the credible interval.

- `null_space`:

  The null space for hypothesis testing.

- `n_samples_quantiles_estimation`:

  Number of samples used for quantiles.

- `simulation_config`:

  Configuration of simulation study.

#### Returns

A scope string, or `NULL` to analyse every replicate afresh.

------------------------------------------------------------------------

### `Model$check_data()`

Check the validity of the data

#### Usage

    Model$check_data(data_list)

#### Arguments

- `data_list`:

  The list of data elements

------------------------------------------------------------------------

### `Model$posterior_moments()`

Abstract method to calculate the posterior moments

#### Usage

    Model$posterior_moments(target_data)

#### Arguments

- `target_data`:

  Data for which posterior moments need to be calculated

#### Returns

none

------------------------------------------------------------------------

### `Model$prior_cdf()`

Abstract method to calculate the cumulative distribution function of the
prior

#### Usage

    Model$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect

#### Returns

none

------------------------------------------------------------------------

### `Model$empirical_bayes_update()`

Method to update the prior

#### Usage

    Model$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Data

#### Returns

none

------------------------------------------------------------------------

### `Model$posterior_mean()`

Method to calculate the mean of the posterior distribution

#### Usage

    Model$posterior_mean(mcmc, n_samples_quantiles_estimation = NA)

#### Arguments

- `mcmc`:

  Whether to use MCMC or not

- `n_samples_quantiles_estimation`:

  Number of samples used to estimates quantiles of distributions

#### Returns

The meen of the posterior distribution

------------------------------------------------------------------------

### `Model$posterior_quantile()`

Method to compute quantiles of the posterior distribution

#### Usage

    Model$posterior_quantile(p, mcmc, n_samples_quantiles_estimation = NA)

#### Arguments

- `p`:

  Quantile

- `mcmc`:

  Whether to use MCMC estimation or not

- `n_samples_quantiles_estimation`:

  Number of samples used to estimates quantiles of distributions

#### Returns

The quantile of the posterior distribution

------------------------------------------------------------------------

### `Model$posterior_median()`

Method to calculate the median of the posterior distribution

#### Usage

    Model$posterior_median(mcmc, n_samples_quantiles_estimation = NA)

#### Arguments

- `mcmc`:

  Whether to use MCMC or not

- `n_samples_quantiles_estimation`:

  Number of samples used to estimates quantiles of distributions

#### Returns

The median of the posterior distribution Calculates the credible
interval of the posterior distribution for a given level

------------------------------------------------------------------------

### `Model$credible_interval()`

#### Usage

    Model$credible_interval(
      level = 0.95,
      mcmc = FALSE,
      n_samples_quantiles_estimation = 10000
    )

#### Arguments

- `level`:

  The level of confidence for the credible interval.

- `mcmc`:

  Whether to use MCMC or not

- `n_samples_quantiles_estimation`:

  Number of samples used to estimates quantiles of distributions

#### Returns

The credible interval.

------------------------------------------------------------------------

### `Model$prior_ESS()`

Method to calculate the effective sample size of the prior distribution

#### Usage

    Model$prior_ESS()

------------------------------------------------------------------------

### `Model$sample_prior()`

Method to sample from the prior distribution

#### Usage

    Model$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw from the prior distribution

------------------------------------------------------------------------

### `Model$sample_posterior()`

Method to sample from the posterior distribution

#### Usage

    Model$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw from the posterior distribution

------------------------------------------------------------------------

### `Model$test_decision()`

This function returns the test decision for a fitted model.

#### Usage

    Model$test_decision(critical_value, theta_0, null_space, confidence_level)

#### Arguments

- `critical_value`:

  The critical value for the test.

- `theta_0`:

  The null hypothesis value.

- `null_space`:

  The null space for the test.

- `confidence_level`:

  Confidence level for the test decision

#### Returns

A logical value indicating the decision.

------------------------------------------------------------------------

### `Model$simulation_for_given_treatment_effect()`

Method to simulate for a given treatment effect

#### Usage

    Model$simulation_for_given_treatment_effect(
      target_data,
      n_replicates,
      critical_value,
      theta_0,
      confidence_level,
      null_space,
      case_study,
      method,
      to_return = c("credible_interval", "test_decision", "posterior_mean",
        "posterior_median", "posterior_parameters", "ess_moment", "ess_precision",
        "ess_elir", "fit_success", "mcmc_diagnostics"),
      verbose = 0,
      n_samples_quantiles_estimation,
      simulation_config = NULL
    )

#### Arguments

- `target_data`:

  Data for the target treatment effect

- `n_replicates`:

  Number of replicates to simulate

- `critical_value`:

  Critical value for hypothesis testing

- `theta_0`:

  Null hypothesis value

- `confidence_level`:

  Confidence level for the credible interval

- `null_space`:

  The null space for hypothesis testing

- `case_study`:

  Case study name

- `method`:

  Method name

- `to_return`:

  List of OCs to return

- `verbose`:

  Verbosity level (0 or 1)

- `n_samples_quantiles_estimation`:

  Number of samples used to estimate distributions quantiles.

- `simulation_config`:

  Simulation configuration. Only required when `to_return` includes
  `"ess_moment"`, `"ess_precision"` or `"ess_elir"` and the method has
  no vectorised fast path, since those outputs are computed via
  `posterior_to_RBesT()`/`prior_to_RBesT()`, which need
  `simulation_config$n_samples_mixture_approx`.

#### Returns

A list of simulation results including test decisions, posterior means,
medians, credible intervals, and posterior parameters

------------------------------------------------------------------------

### `Model$prior_treatment_benefit()`

Method to calculate the prior probability of treatment benefit

#### Usage

    Model$prior_treatment_benefit(
      theta_0,
      null_space,
      n_prior_samples,
      tuning_length
    )

#### Arguments

- `theta_0`:

  Null hypothesis value

- `null_space`:

  The null space for hypothesis testing

- `n_prior_samples`:

  Number of prior samples

- `tuning_length`:

  Tuning parameter length

------------------------------------------------------------------------

### `Model$estimate_frequentist_operating_characteristics()`

Method to estimate frequentist operating characteristics

#### Usage

    Model$estimate_frequentist_operating_characteristics(
      theta_0,
      target_data,
      n_replicates,
      critical_value,
      confidence_level,
      null_space,
      n_samples_quantiles_estimation,
      case_study,
      method,
      verbose = 0,
      simulation_config = NULL
    )

#### Arguments

- `theta_0`:

  Null hypothesis value

- `target_data`:

  Data for the target treatment effect

- `n_replicates`:

  Number of replicates to simulate

- `critical_value`:

  Critical value for hypothesis testing

- `confidence_level`:

  Confidence level for the credible interval

- `null_space`:

  The null space for hypothesis testing

- `n_samples_quantiles_estimation`:

  Number of samples used to estimate distributions quantiles.

- `case_study`:

  Case study name

- `method`:

  Method name

- `verbose`:

  Verbosity level (0 or 1)

- `simulation_config`:

  Simulation configuration, needed by
  `simulation_for_given_treatment_effect()` for `ess_moment`,
  `ess_precision` and `ess_elir` on methods without a vectorised fast
  path.

#### Returns

A list of estimated frequentist operating characteristics including
coverage, MSE, bias, posterior mean, median, precision, credible
intervals, and success probability

------------------------------------------------------------------------

### `Model$estimate_bayesian_operating_characteristics()`

Method to estimate Bayesian operating characteristics

#### Usage

    Model$estimate_bayesian_operating_characteristics(
      design_prior,
      theta_0,
      source_data,
      n_replicates,
      critical_value,
      confidence_level,
      null_space,
      n_samples_design_prior,
      target_sample_size_per_arm,
      case_study_config,
      target_to_source_std_ratio,
      simulation_config,
      case_study,
      method,
      n_samples_quantiles_estimation
    )

#### Arguments

- `design_prior`:

  Design prior

- `theta_0`:

  Null hypothesis value

- `source_data`:

  Source data

- `n_replicates`:

  Number of replicates to simulate

- `critical_value`:

  Critical value for hypothesis testing

- `confidence_level`:

  Confidence level for the credible interval

- `null_space`:

  The null space for hypothesis testing

- `n_samples_design_prior`:

  Number of samples from the design prior

- `target_sample_size_per_arm`:

  Sample size per arm in the target study

- `case_study_config`:

  Configuration of the case study

- `target_to_source_std_ratio`:

  Ratio between the target and source study standard deviation

- `simulation_config`:

  Simulation configuration

- `case_study`:

  Case study name

- `method`:

  Method name

- `n_samples_quantiles_estimation`:

  Number of samples used to estimate distribution quantiles

#### Returns

A list of estimated frequentist operating characteristics including
coverage, MSE, bias, posterior mean, median, precision, credible
intervals, and success probability

------------------------------------------------------------------------

### `Model$prior_to_RBesT()`

Method to convert the model to RBesT

#### Usage

    Model$prior_to_RBesT(n_samples_mixture_approx)

#### Arguments

- `n_samples_mixture_approx`:

  Number of samples used to approximate the prior with a mixture.

------------------------------------------------------------------------

### `Model$prior_elir_ess()`

ELIR effective sample size of the current prior

The default route approximates the prior by a mixture fitted to samples
drawn from it, and refits between replicates only when the prior is data
dependent. Subclasses whose prior has a closed form override this.

#### Usage

    Model$prior_elir_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data, whose sampling standard deviation is the reference
  scale.

- `simulation_config`:

  Configuration of simulation study

#### Returns

The ELIR effective sample size.

------------------------------------------------------------------------

### `Model$posterior_ess()`

Effective sample sizes of the current posterior

Returns the moment-based and precision-based effective sample sizes the
simulation reports per replicate. The default route approximates the
posterior by a mixture fitted to samples drawn from it, which is the
only option when neither the posterior summary nor draws from it are
available. Subclasses that know their posterior standard deviation and
credible interval override this and evaluate the definitions directly.

#### Usage

    Model$posterior_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data

- `simulation_config`:

  Configuration of simulation study

#### Returns

A list with the `moment` and `precision` effective sample sizes.

------------------------------------------------------------------------

### `Model$posterior_to_RBesT()`

Convert the posterior distribution to RBesT format

#### Usage

    Model$posterior_to_RBesT(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data

- `simulation_config`:

  Configuration of simulation study

------------------------------------------------------------------------

### `Model$posterior_beta_mixture()`

Beta mixture approximation to the posterior response rate

The unit information design prior rescales the shape parameters of a
Beta mixture, so it needs the fit on the 0, 1 rate scale rather than the
one on the treatment effect scale that `posterior_to_RBesT()` produces.
It is built here on request because that construction runs once per case
study, whereas `posterior_to_RBesT()` runs once per replicate.

#### Usage

    Model$posterior_beta_mixture(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data

- `simulation_config`:

  Configuration of simulation study

#### Returns

A Beta mixture approximation to the posterior.

------------------------------------------------------------------------

### `Model$plot_pdfs()`

Plot prior and posterior probability density functions (PDF).

#### Usage

    Model$plot_pdfs(xmin = -2, xmax = 2, resolution = 100, ...)

#### Arguments

- `xmin`:

  Lower bound of the treatment effect range

- `xmax`:

  Upper bound of the treatment effect range

- `resolution`:

  Resolution of the treatment effect range

- `...`:

  Optional argument

#### Returns

A plot

------------------------------------------------------------------------

### `Model$plot_prior_pdf()`

Plot prior probability density function (PDF).

#### Usage

    Model$plot_prior_pdf(xmin = -2, xmax = 2, resolution = 100)

#### Arguments

- `xmin`:

  Lower bound of the treatment effect range

- `xmax`:

  Upper bound of the treatment effect range

- `resolution`:

  Resolution of the treatment effect range

#### Returns

A plot

------------------------------------------------------------------------

### `Model$plot_posterior_pdf()`

Plot posterior probability density function (PDF).

#### Usage

    Model$plot_posterior_pdf(xmin = -2, xmax = 2, resolution = 100)

#### Arguments

- `xmin`:

  Lower bound of the treatment effect range

- `xmax`:

  Upper bound of the treatment effect range

- `resolution`:

  Resolution of the treatment effect range

#### Returns

A plot

------------------------------------------------------------------------

### `Model$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Model$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
