# BinomialGravestockEBPP class

The empirical Bayes power prior of Gravestock and Held (2017) for a
binary endpoint: the power parameter maximizes the marginal likelihood
of the target data under the binomial power prior of
[BinomialCPP](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.md),
and the target data are analysed with that power prior. Unlike
[GaussianGravestockEBPP](https://tristanfauvel.github.io/BExTE/reference/GaussianGravestockEBPP.md),
which uses the closed form of a normal likelihood, the marginal
likelihood is that of the binomial likelihoods of both arms, computed on
the lattice of
[`binomial_power_prior_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_posterior.md).

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`MCMCModel`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.md)
-\>
[`BinomialCPP`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.md)
-\> `BinomialGravestockEBPP`

## Public fields

- `empirical_bayes`:

  The prior depends on the target data.

- `empirical_bayes_from_sample`:

  The prior is a function of the replicate's sample alone.

- `fixed_power_parameter`:

  The power parameter changes between replicates.

- `method`:

  Method name.

## Methods

### Public methods

- [`BinomialGravestockEBPP$new()`](#method-BinomialGravestockEBPP-initialize)

- [`BinomialGravestockEBPP$empirical_bayes_update()`](#method-BinomialGravestockEBPP-empirical_bayes_update)

- [`BinomialGravestockEBPP$quadrature_posterior()`](#method-BinomialGravestockEBPP-quadrature_posterior)

- [`BinomialGravestockEBPP$prior_elir_ess()`](#method-BinomialGravestockEBPP-prior_elir_ess)

- [`BinomialGravestockEBPP$clone()`](#method-BinomialGravestockEBPP-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference_cache_scope()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-print_model_summary)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-vectorised_replicate_inference)
- [`MCMCModel$check_mcmc_config()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$compute_posterior_parameters()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-compute_posterior_parameters)
- [`MCMCModel$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$inference()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-inference)
- [`MCMCModel$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-prior_pdf)
- [`MCMCModel$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-sample_posterior)
- [`MCMCModel$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-sample_prior)
- [`MCMCModel$stan_sampler()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-stan_sampler)
- [`MCMCModel$uses_quadrature()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-uses_quadrature)
- [`BinomialCPP$draw_mcmc_prior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-draw_mcmc_prior)
- [`BinomialCPP$prepare_data()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-prepare_data)
- [`BinomialCPP$prior_given_control_rate()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-prior_given_control_rate)
- [`BinomialCPP$quadrature_prior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-quadrature_prior)
- [`BinomialCPP$summary_rows()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-summary_rows)

------------------------------------------------------------------------

### `BinomialGravestockEBPP$new()`

Initialize a BinomialGravestockEBPP model.

#### Usage

    BinomialGravestockEBPP$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `mcmc_config`:

  The MCMC configuration. Only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialGravestockEBPP$empirical_bayes_update()`

Set the power parameter from the replicate's counts.

#### Usage

    BinomialGravestockEBPP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Target study data.

------------------------------------------------------------------------

### `BinomialGravestockEBPP$quadrature_posterior()`

The posterior on a grid, at the estimated power parameter.

#### Usage

    BinomialGravestockEBPP$quadrature_posterior(target_data)

#### Arguments

- `target_data`:

  The target study data.

#### Returns

A
[`grid_posterior()`](https://tristanfauvel.github.io/BExTE/reference/grid_posterior.md)
list.

------------------------------------------------------------------------

### `BinomialGravestockEBPP$prior_elir_ess()`

ELIR effective sample size of the current prior, interpolated over the
power parameter as for the p-value-based power prior; see
[`binomial_power_prior_unit_elir()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_unit_elir.md).

#### Usage

    BinomialGravestockEBPP$prior_elir_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data.

- `simulation_config`:

  Configuration of the simulation study.

#### Returns

The ELIR effective sample size.

------------------------------------------------------------------------

### `BinomialGravestockEBPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialGravestockEBPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
