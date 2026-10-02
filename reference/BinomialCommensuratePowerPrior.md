# BinomialCommensuratePowerPrior class

The commensurate power prior of
[GaussianCommensuratePowerPrior](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianCommensuratePowerPrior.md)
for a binary endpoint, with the binomial likelihoods of both arms of
each study instead of a normal approximation of the risk difference; see
the comment at the top of `R/binomial_commensurate.R` for the model. The
posterior is computed on the lattice of
[BinomialLatticePrior](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.md).

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\>
[`BinomialLatticePrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.md)
-\> `BinomialCommensuratePowerPrior`

## Public fields

- `method`:

  Method name.

- `heterogeneity_prior_family`:

  Family of the prior on the commensurability parameter.

- `borrows_power_parameter`:

  Whether the source likelihood is discounted by a power parameter.

- `n_tau_nodes`:

  Quadrature nodes on the commensurability parameter, before the
  adjustments of
  [`commensurate_tau_quadrature()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/commensurate_tau_quadrature.md).

## Methods

### Public methods

- [`BinomialCommensuratePowerPrior$new()`](#method-BinomialCommensuratePowerPrior-initialize)

- [`BinomialCommensuratePowerPrior$kernels()`](#method-BinomialCommensuratePowerPrior-kernels)

- [`BinomialCommensuratePowerPrior$kernel_key()`](#method-BinomialCommensuratePowerPrior-kernel_key)

- [`BinomialCommensuratePowerPrior$compute_posterior_parameters()`](#method-BinomialCommensuratePowerPrior-compute_posterior_parameters)

- [`BinomialCommensuratePowerPrior$clone()`](#method-BinomialCommensuratePowerPrior-clone)

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
- [`MCMCModel$summary_rows()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-summary_rows)
- [`MCMCModel$uses_quadrature()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-uses_quadrature)
- [`BinomialLatticePrior$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-prior_elir_ess)
- [`BinomialLatticePrior$prior_given_control_rate()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-prior_given_control_rate)
- [`BinomialLatticePrior$quadrature_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-quadrature_posterior)
- [`BinomialLatticePrior$quadrature_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-quadrature_prior)
- [`BinomialLatticePrior$source_counts()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-source_counts)

------------------------------------------------------------------------

### `BinomialCommensuratePowerPrior$new()`

Initialize the model.

#### Usage

    BinomialCommensuratePowerPrior$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `mcmc_config`:

  The MCMC configuration; only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialCommensuratePowerPrior$kernels()`

The prior kernels, computed once per worker and shared.

#### Usage

    BinomialCommensuratePowerPrior$kernels()

#### Returns

The output of
[`binomial_commensurate_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_commensurate_prior_kernels.md).

------------------------------------------------------------------------

### `BinomialCommensuratePowerPrior$kernel_key()`

What identifies the prior.

#### Usage

    BinomialCommensuratePowerPrior$kernel_key()

#### Returns

A list.

------------------------------------------------------------------------

### `BinomialCommensuratePowerPrior$compute_posterior_parameters()`

Record the posterior moments of the commensurability parameter and, for
the commensurate power prior, of the power parameter.

#### Usage

    BinomialCommensuratePowerPrior$compute_posterior_parameters()

------------------------------------------------------------------------

### `BinomialCommensuratePowerPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialCommensuratePowerPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
