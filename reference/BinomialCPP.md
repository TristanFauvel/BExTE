# BinomialCPP Class

A class representing a Binomial Conditional Power Prior model.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\> `BinomialCPP`

## Public fields

- `power_parameter`:

  The power parameter for the model

- `method`:

  Method name

- `stan_prior`:

  Stan prior model

- `stan_prior_code`:

  Stan code for the prior

- `fixed_power_parameter`:

  Whether the power parameter is the same for every replicate, so that
  the posterior is read off a cached prior kernel.

## Methods

### Public methods

- [`BinomialCPP$summary_rows()`](#method-BinomialCPP-summary_rows)

- [`BinomialCPP$new()`](#method-BinomialCPP-initialize)

- [`BinomialCPP$prepare_data()`](#method-BinomialCPP-prepare_data)

- [`BinomialCPP$quadrature_posterior()`](#method-BinomialCPP-quadrature_posterior)

- [`BinomialCPP$quadrature_prior()`](#method-BinomialCPP-quadrature_prior)

- [`BinomialCPP$prior_given_control_rate()`](#method-BinomialCPP-prior_given_control_rate)

- [`BinomialCPP$draw_mcmc_prior()`](#method-BinomialCPP-draw_mcmc_prior)

- [`BinomialCPP$clone()`](#method-BinomialCPP-clone)

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
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-print_model_summary)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)
- [`MCMCModel$check_mcmc_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$compute_posterior_parameters()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-compute_posterior_parameters)
- [`MCMCModel$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-inference)
- [`MCMCModel$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_pdf)
- [`MCMCModel$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_posterior)
- [`MCMCModel$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_prior)
- [`MCMCModel$stan_sampler()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-stan_sampler)
- [`MCMCModel$uses_quadrature()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-uses_quadrature)

------------------------------------------------------------------------

### `BinomialCPP$summary_rows()`

Rows of the model summary, with the power parameter

A power parameter set from each replicate's data is already among the
`posterior_parameters` rows, so it is only added when it is fixed.

#### Usage

    BinomialCPP$summary_rows()

#### Returns

A data frame with columns `Attribute` and `Value`.

------------------------------------------------------------------------

### `BinomialCPP$new()`

Initialize an instance of the BinomialCPP class.

#### Usage

    BinomialCPP$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object

- `mcmc_config`:

  The MCMC configuration parameters

------------------------------------------------------------------------

### `BinomialCPP$prepare_data()`

Prepare data for the model

#### Usage

    BinomialCPP$prepare_data(target_data)

#### Arguments

- `target_data`:

  The target study data

#### Returns

A list of prepared data

------------------------------------------------------------------------

### `BinomialCPP$quadrature_posterior()`

The posterior on a grid, under the quadrature engine

The same model as the Stan program, with the current power parameter.

#### Usage

    BinomialCPP$quadrature_posterior(target_data)

#### Arguments

- `target_data`:

  The target study data

#### Returns

A
[`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md)
list.

------------------------------------------------------------------------

### `BinomialCPP$quadrature_prior()`

The prior on a grid, under the quadrature engine: the same model without
target patients, as in the Stan prior program.

#### Usage

    BinomialCPP$quadrature_prior(power_parameter = self$power_parameter)

#### Arguments

- `power_parameter`:

  The power parameter of the prior, by default the model's own.

#### Returns

A
[`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md)
list.

------------------------------------------------------------------------

### `BinomialCPP$prior_given_control_rate()`

The prior of the treatment effect given the target control rate

The power prior of `quadrature_prior()` with the target control rate
fixed rather than integrated out, so the effect is confined to the range
that rate leaves it.

#### Usage

    BinomialCPP$prior_given_control_rate(control_rate)

#### Arguments

- `control_rate`:

  The target control rate.

#### Returns

A list of three functions of the treatment effect: `cdf`, `pdf`, and
`sample`, which takes the number of draws.

------------------------------------------------------------------------

### `BinomialCPP$draw_mcmc_prior()`

Sample from the prior using Stan

#### Usage

    BinomialCPP$draw_mcmc_prior()

------------------------------------------------------------------------

### `BinomialCPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialCPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
