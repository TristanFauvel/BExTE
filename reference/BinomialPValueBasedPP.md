# GaussianEmpiricalBayesPP class

This is a parent class for variants of empirical Bayes PP methods for
normally distributed summary measure of the treatment effect.

## Format

R6Class object.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\>
[`BinomialCPP`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.md)
-\> `BinomialPValueBasedPP`

## Public fields

- `power_parameter`:

  The power parameter.

- `summary_measure_likelihood`:

  The summary measure distribution.

- `null_space`:

  Null hypothesis space.

- `empirical_bayes`:

  Boolean indicating if empirical Bayes is used.

- `shape_parameter`:

  Shape parameter

- `method`:

  Method name

- `prior_var`:

  Prior variance

- `mcmc_config`:

  MCMC configuration

- `fixed_power_parameter`:

  Whether the power parameter is the same for every replicate, so that
  the posterior is read off a cached prior kernel.

- `empirical_bayes_from_sample`:

  Whether the empirical Bayes quantities are a function of the
  replicate's sample alone, so that a deterministic model may still
  share an analysis between replicates with equal samples.

## Methods

### Public methods

- [`BinomialPValueBasedPP$new()`](#method-BinomialPValueBasedPP-initialize)

- [`BinomialPValueBasedPP$empirical_bayes_update()`](#method-BinomialPValueBasedPP-empirical_bayes_update)

- [`BinomialPValueBasedPP$inference()`](#method-BinomialPValueBasedPP-inference)

- [`BinomialPValueBasedPP$prior_elir_ess()`](#method-BinomialPValueBasedPP-prior_elir_ess)

- [`BinomialPValueBasedPP$test()`](#method-BinomialPValueBasedPP-test)

- [`BinomialPValueBasedPP$power_parameter_estimation()`](#method-BinomialPValueBasedPP-power_parameter_estimation)

- [`BinomialPValueBasedPP$prior_pdf()`](#method-BinomialPValueBasedPP-prior_pdf)

- [`BinomialPValueBasedPP$plot_power_parameter_vs_drift()`](#method-BinomialPValueBasedPP-plot_power_parameter_vs_drift)

- [`BinomialPValueBasedPP$clone()`](#method-BinomialPValueBasedPP-clone)

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
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-print_model_summary)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)
- [`MCMCModel$check_mcmc_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$compute_posterior_parameters()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-compute_posterior_parameters)
- [`MCMCModel$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_posterior)
- [`MCMCModel$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_prior)
- [`MCMCModel$stan_sampler()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-stan_sampler)
- [`MCMCModel$uses_quadrature()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-uses_quadrature)
- [`BinomialCPP$draw_mcmc_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.html#method-draw_mcmc_prior)
- [`BinomialCPP$prepare_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.html#method-prepare_data)
- [`BinomialCPP$prior_given_control_rate()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.html#method-prior_given_control_rate)
- [`BinomialCPP$quadrature_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.html#method-quadrature_posterior)
- [`BinomialCPP$quadrature_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.html#method-quadrature_prior)
- [`BinomialCPP$summary_rows()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.html#method-summary_rows)

------------------------------------------------------------------------

### `BinomialPValueBasedPP$new()`

Initialize the p_value_based_PP object.

#### Usage

    BinomialPValueBasedPP$new(prior, theta_0, null_space, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `theta_0`:

  Boundary of the null hypothesis space

- `null_space`:

  Null space.

- `mcmc_config`:

  MCMC configuration.

#### Returns

None

------------------------------------------------------------------------

### `BinomialPValueBasedPP$empirical_bayes_update()`

Empirical Bayes update

#### Usage

    BinomialPValueBasedPP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Target study data

#### Returns

NULL Perform inference using the GaussianEmpiricalBayesPP method.

------------------------------------------------------------------------

### `BinomialPValueBasedPP$inference()`

#### Usage

    BinomialPValueBasedPP$inference(target_data)

#### Arguments

- `target_data`:

  The target data.

#### Returns

The inference result.

------------------------------------------------------------------------

### `BinomialPValueBasedPP$prior_elir_ess()`

ELIR effective sample size of the current prior

The prior changes between replicates only through the power parameter,
so under the quadrature engine the ELIR is interpolated from a table
over the power parameter, shared across scenarios - see
[`binomial_power_prior_unit_elir()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_power_prior_unit_elir.md).
Refitting a mixture to fresh prior draws for every replicate, as the
inherited route does, was most of the method's run time. Under Stan the
prior can only be sampled, so that route is kept.

#### Usage

    BinomialPValueBasedPP$prior_elir_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data, whose sampling standard deviation is the reference
  scale.

- `simulation_config`:

  Configuration of simulation study

#### Returns

The ELIR effective sample size. Test method

------------------------------------------------------------------------

### `BinomialPValueBasedPP$test()`

This method performs the test for the given target data.

#### Usage

    BinomialPValueBasedPP$test(
      target_data,
      source_treatment_effect_estimate,
      target_treatment_effect_estimate
    )

#### Arguments

- `target_data`:

  The target data object.

- `source_treatment_effect_estimate`:

  The source treatment effect estimate.

- `target_treatment_effect_estimate`:

  The target treatment effect estimate.

#### Returns

The p-value. Power parameter estimation method

------------------------------------------------------------------------

### `BinomialPValueBasedPP$power_parameter_estimation()`

This method estimates the power parameter for the given target data.

#### Usage

    BinomialPValueBasedPP$power_parameter_estimation(target_data)

#### Arguments

- `target_data`:

  The target data object.

- `source_treatment_effect_estimate`:

  The source treatment effect estimate.

- `target_treatment_effect_estimate`:

  The target treatment effect estimate.

#### Returns

The power parameter.

------------------------------------------------------------------------

### `BinomialPValueBasedPP$prior_pdf()`

Calculate the prior probability density function (PDF) for a given
target treatment effect.

#### Usage

    BinomialPValueBasedPP$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The target treatment effect.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `BinomialPValueBasedPP$plot_power_parameter_vs_drift()`

Plot the power parameter as a function of drift in treatment effect

#### Usage

    BinomialPValueBasedPP$plot_power_parameter_vs_drift(
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

### `BinomialPValueBasedPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialPValueBasedPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
