# BinomialEgidiMixture class

The empirical robust mixture prior of Egidi et al. (2022) for a binary
endpoint, on the components of
[BinomialRMP](https://tristanfauvel.github.io/BExTE/reference/BinomialRMP.md):
for each dataset, the weight of the weak component is the smallest on
the grid at which the prior-predictive conflict p-value of the observed
counts reaches `alpha_pc`, the p-value being computed exactly from the
components' prior-predictive tables (see
[`egidi_select_weak_weight_binomial()`](https://tristanfauvel.github.io/BExTE/reference/egidi_select_weak_weight_binomial.md)).

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`MCMCModel`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.md)
-\>
[`BinomialLatticePrior`](https://tristanfauvel.github.io/BExTE/reference/BinomialLatticePrior.md)
-\>
[`BinomialRMP`](https://tristanfauvel.github.io/BExTE/reference/BinomialRMP.md)
-\> `BinomialEgidiMixture`

## Public fields

- `alpha_pc`:

  Conflict threshold.

- `pvalue_method`:

  Conflict p-value method.

- `weight_grid_step`:

  Resolution of the weight scan.

- `selection`:

  The selection of the current dataset.

- `quantile_summary_columns`:

  Columns summarised by quantiles across replicates.

- `empirical_bayes`:

  The prior depends on the target data.

- `empirical_bayes_from_sample`:

  The prior is a function of the replicate's sample alone.

- `method`:

  Method name.

## Methods

### Public methods

- [`BinomialEgidiMixture$new()`](#method-BinomialEgidiMixture-initialize)

- [`BinomialEgidiMixture$empirical_bayes_update()`](#method-BinomialEgidiMixture-empirical_bayes_update)

- [`BinomialEgidiMixture$quadrature_posterior()`](#method-BinomialEgidiMixture-quadrature_posterior)

- [`BinomialEgidiMixture$compute_posterior_parameters()`](#method-BinomialEgidiMixture-compute_posterior_parameters)

- [`BinomialEgidiMixture$prior_elir_ess()`](#method-BinomialEgidiMixture-prior_elir_ess)

- [`BinomialEgidiMixture$clone()`](#method-BinomialEgidiMixture-clone)

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
- [`MCMCModel$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$draw_mcmc_prior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-draw_mcmc_prior)
- [`MCMCModel$inference()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-inference)
- [`MCMCModel$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prepare_data()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-prepare_data)
- [`MCMCModel$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-prior_pdf)
- [`MCMCModel$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-sample_posterior)
- [`MCMCModel$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-sample_prior)
- [`MCMCModel$stan_sampler()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-stan_sampler)
- [`MCMCModel$uses_quadrature()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-uses_quadrature)
- [`BinomialLatticePrior$prior_given_control_rate()`](https://tristanfauvel.github.io/BExTE/reference/BinomialLatticePrior.html#method-prior_given_control_rate)
- [`BinomialLatticePrior$quadrature_prior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialLatticePrior.html#method-quadrature_prior)
- [`BinomialLatticePrior$source_counts()`](https://tristanfauvel.github.io/BExTE/reference/BinomialLatticePrior.html#method-source_counts)
- [`BinomialRMP$components()`](https://tristanfauvel.github.io/BExTE/reference/BinomialRMP.html#method-components)
- [`BinomialRMP$kernel_key()`](https://tristanfauvel.github.io/BExTE/reference/BinomialRMP.html#method-kernel_key)
- [`BinomialRMP$kernels()`](https://tristanfauvel.github.io/BExTE/reference/BinomialRMP.html#method-kernels)
- [`BinomialRMP$summary_rows()`](https://tristanfauvel.github.io/BExTE/reference/BinomialRMP.html#method-summary_rows)

------------------------------------------------------------------------

### `BinomialEgidiMixture$new()`

Initialize the model.

#### Usage

    BinomialEgidiMixture$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `mcmc_config`:

  The MCMC configuration; only the quadrature engine is supported.

------------------------------------------------------------------------

### `BinomialEgidiMixture$empirical_bayes_update()`

Choose the weight from the replicate's counts.

#### Usage

    BinomialEgidiMixture$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  Target study data.

------------------------------------------------------------------------

### `BinomialEgidiMixture$quadrature_posterior()`

The posterior on a grid, from the two components' kernels and the
weight, without forming the mixture kernel; see
[`binomial_rmp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_rmp_posterior.md).

#### Usage

    BinomialEgidiMixture$quadrature_posterior(target_data)

#### Arguments

- `target_data`:

  The target study data.

#### Returns

The list
[`binomial_npp_posterior()`](https://tristanfauvel.github.io/BExTE/reference/binomial_npp_posterior.md)
returns.

------------------------------------------------------------------------

### `BinomialEgidiMixture$compute_posterior_parameters()`

Record the posterior weight and the selection.

#### Usage

    BinomialEgidiMixture$compute_posterior_parameters()

------------------------------------------------------------------------

### `BinomialEgidiMixture$prior_elir_ess()`

ELIR effective sample size of the current prior. The prior changes
between datasets only through its weight, so the unit-scale ELIR is
computed at weights 0, 0.05, ..., 1, once per worker, and interpolated
linearly.

#### Usage

    BinomialEgidiMixture$prior_elir_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data.

- `simulation_config`:

  Simulation configuration.

#### Returns

The ELIR effective sample size.

------------------------------------------------------------------------

### `BinomialEgidiMixture$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialEgidiMixture$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
