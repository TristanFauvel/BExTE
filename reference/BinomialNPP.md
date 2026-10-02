# BinomialNPP class

The normalized power prior for a binary endpoint, with the binomial
likelihoods of the two arms of each study and a risk difference shared
by the source and target studies, as in
[BinomialCPP](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialCPP.md).
The power parameter has a Beta prior, specified by its mean and standard
deviation as in
[GaussianNPP](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianNPP.md),
and is integrated out exactly rather than through a normal approximation
of the likelihood. The posterior is computed on a lattice of response
rates; see
[`binomial_npp_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_prior_kernels.md).

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\>
[`BinomialLatticePrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.md)
-\> `BinomialNPP`

## Public fields

- `power_parameter_mean`:

  Mean of the Beta prior on the power parameter.

- `power_parameter_std`:

  Standard deviation of the Beta prior.

- `p`:

  Shape parameter of the Beta prior.

- `q`:

  Shape parameter of the Beta prior.

- `method`:

  Name of the method.

## Methods

### Public methods

- [`BinomialNPP$summary_rows()`](#method-BinomialNPP-summary_rows)

- [`BinomialNPP$new()`](#method-BinomialNPP-initialize)

- [`BinomialNPP$kernels()`](#method-BinomialNPP-kernels)

- [`BinomialNPP$kernel_key()`](#method-BinomialNPP-kernel_key)

- [`BinomialNPP$compute_posterior_parameters()`](#method-BinomialNPP-compute_posterior_parameters)

- [`BinomialNPP$clone()`](#method-BinomialNPP-clone)

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
- [`MCMCModel$uses_quadrature()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-uses_quadrature)
- [`BinomialLatticePrior$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-prior_elir_ess)
- [`BinomialLatticePrior$prior_given_control_rate()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-prior_given_control_rate)
- [`BinomialLatticePrior$quadrature_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-quadrature_posterior)
- [`BinomialLatticePrior$quadrature_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-quadrature_prior)
- [`BinomialLatticePrior$source_counts()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.html#method-source_counts)

------------------------------------------------------------------------

### `BinomialNPP$summary_rows()`

Rows of the model summary, with the prior on the power parameter

#### Usage

    BinomialNPP$summary_rows()

#### Returns

A data frame with columns `Attribute` and `Value`.

------------------------------------------------------------------------

### `BinomialNPP$new()`

Initialize a BinomialNPP model.

#### Usage

    BinomialNPP$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object, with `power_parameter_mean` and
  `power_parameter_std` among its method parameters.

- `mcmc_config`:

  The MCMC configuration; only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialNPP$kernels()`

The prior kernels, computed once per worker and shared.

#### Usage

    BinomialNPP$kernels()

#### Returns

The output of
[`binomial_npp_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_prior_kernels.md).

------------------------------------------------------------------------

### `BinomialNPP$kernel_key()`

What identifies the prior, for the ELIR cache.

#### Usage

    BinomialNPP$kernel_key()

#### Returns

A list.

------------------------------------------------------------------------

### `BinomialNPP$compute_posterior_parameters()`

Record the posterior mean and standard deviation of the power parameter.

#### Usage

    BinomialNPP$compute_posterior_parameters()

------------------------------------------------------------------------

### `BinomialNPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialNPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
