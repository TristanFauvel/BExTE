# BinomialPDCCPP class

The calibrated power prior of
[GaussianPDCCPP](https://tristanfauvel.github.io/BExTE/reference/GaussianPDCCPP.md)
for a binary endpoint: the power parameter is given by the same rule,
applied to the estimated risk differences and their standard errors, the
target data are analysed with the binomial conditional power prior of
[BinomialCPP](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.md)
at that power parameter, and the calibration parameter is calibrated on
the exact type I error of this binomial analysis rather than on the
closed form of a normal one; see the comment at the top of
`R/binomial_pdccpp.R`.

The calibration needs the design, which
[Model](https://tristanfauvel.github.io/BExTE/reference/Model.md)`$calibrate_for_design()`
records, and the critical value the analysis decides at, which is only
known once a replicate is analysed, so it runs at the first replicate.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`MCMCModel`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.md)
-\>
[`BinomialCPP`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.md)
-\> `BinomialPDCCPP`

## Public fields

- `method`:

  Method name.

- `empirical_bayes`:

  The prior depends on the target data.

- `empirical_bayes_from_sample`:

  The prior is a function of the replicate's sample alone.

- `fixed_power_parameter`:

  The power parameter changes between replicates.

- `null_space`:

  Side of the null hypothesis space.

- `theta_0`:

  Boundary of the null hypothesis space.

- `design`:

  The target data of the design calibrated against.

- `calibration`:

  The calibration parameter and its exact type I error.

## Methods

### Public methods

- [`BinomialPDCCPP$new()`](#method-BinomialPDCCPP-initialize)

- [`BinomialPDCCPP$calibrate_for_design()`](#method-BinomialPDCCPP-calibrate_for_design)

- [`BinomialPDCCPP$ensure_calibrated()`](#method-BinomialPDCCPP-ensure_calibrated)

- [`BinomialPDCCPP$empirical_bayes_update()`](#method-BinomialPDCCPP-empirical_bayes_update)

- [`BinomialPDCCPP$prior_elir_ess()`](#method-BinomialPDCCPP-prior_elir_ess)

- [`BinomialPDCCPP$clone()`](#method-BinomialPDCCPP-clone)

Inherited methods

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
- [`BinomialCPP$quadrature_posterior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-quadrature_posterior)
- [`BinomialCPP$quadrature_prior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-quadrature_prior)
- [`BinomialCPP$summary_rows()`](https://tristanfauvel.github.io/BExTE/reference/BinomialCPP.html#method-summary_rows)

------------------------------------------------------------------------

### `BinomialPDCCPP$new()`

Initialize a BinomialPDCCPP model.

#### Usage

    BinomialPDCCPP$new(prior, theta_0, null_space, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `theta_0`:

  Boundary of the null hypothesis space.

- `null_space`:

  Side of the null hypothesis space.

- `mcmc_config`:

  The MCMC configuration; only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialPDCCPP$calibrate_for_design()`

Record the design the calibration is computed for.

#### Usage

    BinomialPDCCPP$calibrate_for_design(target_data)

#### Arguments

- `target_data`:

  Target study data for the scenario.

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `BinomialPDCCPP$ensure_calibrated()`

Calibrate, if not done yet for the current design and critical value.

#### Usage

    BinomialPDCCPP$ensure_calibrated(workers = 1L)

#### Arguments

- `workers`:

  Number of processes for the null table.

#### Returns

The calibration, invisibly.

------------------------------------------------------------------------

### `BinomialPDCCPP$empirical_bayes_update()`

Set the power parameter from the replicate's estimates.

#### Usage

    BinomialPDCCPP$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Target study data.

------------------------------------------------------------------------

### `BinomialPDCCPP$prior_elir_ess()`

ELIR effective sample size of the current prior, interpolated over the
power parameter; see
[`binomial_power_prior_unit_elir()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_unit_elir.md).

#### Usage

    BinomialPDCCPP$prior_elir_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data.

- `simulation_config`:

  Configuration of the simulation study.

#### Returns

The ELIR effective sample size.

------------------------------------------------------------------------

### `BinomialPDCCPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialPDCCPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
