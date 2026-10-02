# BinomialNPP_KL class

The KL-calibrated normalized power prior of
[GaussianNPP_KL](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianNPP_KL.md)
for a binary endpoint: the Beta prior on the power parameter is
calibrated to the design with the criterion of
[`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md),
the posterior of the power parameter under the two hypothetical results
being computed from the binomial marginal likelihood
([`npp_kl_calibrate_design_binomial()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/npp_kl_calibrate_design_binomial.md)),
and the target data are analysed with the binomial normalized power
prior,
[BinomialNPP](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialNPP.md),
under that prior. The shape parameters are `NULL` until
[Model](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)`$calibrate_for_design()`
has run.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\>
[`BinomialLatticePrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.md)
-\>
[`BinomialNPP`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialNPP.md)
-\> `BinomialNPP_KL`

## Public fields

- `method`:

  Name of the method.

- `theta_0`:

  Boundary of the null hypothesis space.

- `null_space`:

  The null hypothesis space, which gives the benefit direction.

- `calibration`:

  The result of
  [`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md)
  for this scenario.

- `calibration_settings`:

  The criterion settings read from the method parameters.

## Methods

### Public methods

- [`BinomialNPP_KL$new()`](#method-BinomialNPP_KL-initialize)

- [`BinomialNPP_KL$calibrate_for_design()`](#method-BinomialNPP_KL-calibrate_for_design)

- [`BinomialNPP_KL$compute_posterior_parameters()`](#method-BinomialNPP_KL-compute_posterior_parameters)

- [`BinomialNPP_KL$clone()`](#method-BinomialNPP_KL-clone)

Inherited methods

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
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)
- [`MCMCModel$check_mcmc_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$draw_mcmc_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-draw_mcmc_prior)
- [`MCMCModel$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-inference)
- [`MCMCModel$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prepare_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prepare_data)
- [`MCMCModel$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_pdf)
- [`MCMCModel$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_posterior)
- [`MCMCModel$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_prior)
- [`MCMCModel$stan_sampler()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-stan_sampler)
- [`MCMCModel$uses_quadrature()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-uses_quadrature)
- [`BinomialLatticePrior$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-prior_elir_ess)
- [`BinomialLatticePrior$prior_given_control_rate()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-prior_given_control_rate)
- [`BinomialLatticePrior$quadrature_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-quadrature_posterior)
- [`BinomialLatticePrior$quadrature_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-quadrature_prior)
- [`BinomialLatticePrior$source_counts()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-source_counts)
- [`BinomialNPP$kernel_key()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialNPP.html#method-kernel_key)
- [`BinomialNPP$kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialNPP.html#method-kernels)
- [`BinomialNPP$summary_rows()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialNPP.html#method-summary_rows)

------------------------------------------------------------------------

### `BinomialNPP_KL$new()`

Initialize a BinomialNPP_KL model.

#### Usage

    BinomialNPP_KL$new(prior, theta_0, null_space, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `theta_0`:

  Value of the treatment effect under the null hypothesis.

- `null_space`:

  The null hypothesis space, either "left" or "right".

- `mcmc_config`:

  The MCMC configuration; only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialNPP_KL$calibrate_for_design()`

Calibrate the prior on the power parameter to this design, with the
criterion of
[`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md)
evaluated on the binomial marginal likelihood; see
[`npp_kl_calibrate_design_binomial()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/npp_kl_calibrate_design_binomial.md).

#### Usage

    BinomialNPP_KL$calibrate_for_design(target_data)

#### Arguments

- `target_data`:

  Target study data for the scenario.

#### Returns

The calibration, invisibly.

------------------------------------------------------------------------

### `BinomialNPP_KL$compute_posterior_parameters()`

Record the posterior moments of the power parameter and the calibration,
which is constant within a scenario.

#### Usage

    BinomialNPP_KL$compute_posterior_parameters()

------------------------------------------------------------------------

### `BinomialNPP_KL$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialNPP_KL$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
