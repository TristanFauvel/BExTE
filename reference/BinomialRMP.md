# BinomialRMP class

The robust mixture prior for a binary endpoint, with the binomial
likelihoods of both arms and an exact binomial informative component;
see the comment at the top of `R/binomial_rmp.R`. It replaced a
truncated normal mixture whose informative component was the normal
approximation of the source posterior.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\>
[`BinomialLatticePrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialLatticePrior.md)
-\> `BinomialRMP`

## Public fields

- `w`:

  Prior weight of the informative component.

- `method`:

  Method name.

## Methods

### Public methods

- [`BinomialRMP$new()`](#method-BinomialRMP-initialize)

- [`BinomialRMP$summary_rows()`](#method-BinomialRMP-summary_rows)

- [`BinomialRMP$components()`](#method-BinomialRMP-components)

- [`BinomialRMP$kernels()`](#method-BinomialRMP-kernels)

- [`BinomialRMP$kernel_key()`](#method-BinomialRMP-kernel_key)

- [`BinomialRMP$compute_posterior_parameters()`](#method-BinomialRMP-compute_posterior_parameters)

- [`BinomialRMP$clone()`](#method-BinomialRMP-clone)

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

### `BinomialRMP$new()`

Initialize the model.

#### Usage

    BinomialRMP$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object, with `prior_weight` among its method parameters.

- `mcmc_config`:

  The MCMC configuration; only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialRMP$summary_rows()`

Rows of the model summary, with the prior weight

#### Usage

    BinomialRMP$summary_rows()

#### Returns

A data frame with columns `Attribute` and `Value`.

------------------------------------------------------------------------

### `BinomialRMP$components()`

The two components, computed once per worker and shared.

#### Usage

    BinomialRMP$components()

#### Returns

The output of
[`binomial_rmp_components()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_rmp_components.md).

------------------------------------------------------------------------

### `BinomialRMP$kernels()`

The prior kernels at the current weight, kept until the weight changes.

#### Usage

    BinomialRMP$kernels()

#### Returns

The output of
[`binomial_rmp_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_rmp_kernels.md).

------------------------------------------------------------------------

### `BinomialRMP$kernel_key()`

What identifies the prior, for the ELIR cache.

#### Usage

    BinomialRMP$kernel_key()

#### Returns

A list.

------------------------------------------------------------------------

### `BinomialRMP$compute_posterior_parameters()`

Record the posterior weight of the informative component.

#### Usage

    BinomialRMP$compute_posterior_parameters()

------------------------------------------------------------------------

### `BinomialRMP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialRMP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
