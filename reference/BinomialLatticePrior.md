# BinomialLatticePrior class

Base class of the binomial models whose prior, integrated over every
source parameter and hyperparameter, is a fixed prior on the target
control rate and the risk difference, tabulated on the lattice of
[`binomial_npp_prior_kernels()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_prior_kernels.md).
The posterior of a dataset is that prior times the target likelihood, so
it costs one weighted sum; the prior, the prior given a control rate and
the prior ELIR follow from the same table.

A subclass implements `kernels()`, returning a list with `n_lattice`,
`rates`, `differences`, the prior `kernel` and, optionally, the moment
kernels read by
[`binomial_npp_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/binomial_npp_posterior.md);
`kernel_key()`, identifying the prior for the ELIR cache; and
`compute_posterior_parameters()`.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\> `BinomialLatticePrior`

## Public fields

- `n_lattice`:

  Number of lattice points on the response rates.

- `quadrature_available`:

  The posterior is computed by quadrature.

## Methods

### Public methods

- [`BinomialLatticePrior$new()`](#method-BinomialLatticePrior-initialize)

- [`BinomialLatticePrior$kernels()`](#method-BinomialLatticePrior-kernels)

- [`BinomialLatticePrior$kernel_key()`](#method-BinomialLatticePrior-kernel_key)

- [`BinomialLatticePrior$source_counts()`](#method-BinomialLatticePrior-source_counts)

- [`BinomialLatticePrior$quadrature_posterior()`](#method-BinomialLatticePrior-quadrature_posterior)

- [`BinomialLatticePrior$quadrature_prior()`](#method-BinomialLatticePrior-quadrature_prior)

- [`BinomialLatticePrior$prior_given_control_rate()`](#method-BinomialLatticePrior-prior_given_control_rate)

- [`BinomialLatticePrior$prior_elir_ess()`](#method-BinomialLatticePrior-prior_elir_ess)

- [`BinomialLatticePrior$clone()`](#method-BinomialLatticePrior-clone)

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
- [`MCMCModel$compute_posterior_parameters()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-compute_posterior_parameters)
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

------------------------------------------------------------------------

### `BinomialLatticePrior$new()`

Initialize a binomial lattice model.

#### Usage

    BinomialLatticePrior$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object.

- `mcmc_config`:

  The MCMC configuration. Only its `engine` is read, and only
  `"quadrature"` is supported: these models have no Stan program.

------------------------------------------------------------------------

### `BinomialLatticePrior$kernels()`

The prior kernels. Subclasses must implement it.

#### Usage

    BinomialLatticePrior$kernels()

------------------------------------------------------------------------

### `BinomialLatticePrior$kernel_key()`

What identifies the prior, for the ELIR cache. Subclasses must implement
it.

#### Usage

    BinomialLatticePrior$kernel_key()

------------------------------------------------------------------------

### `BinomialLatticePrior$source_counts()`

The source counts of the prior.

#### Usage

    BinomialLatticePrior$source_counts()

#### Returns

A list with the four source counts.

------------------------------------------------------------------------

### `BinomialLatticePrior$quadrature_posterior()`

The posterior on a grid

#### Usage

    BinomialLatticePrior$quadrature_posterior(target_data)

#### Arguments

- `target_data`:

  The target study data.

#### Returns

A
[`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md)
list.

------------------------------------------------------------------------

### `BinomialLatticePrior$quadrature_prior()`

The prior of the treatment effect on a grid.

#### Usage

    BinomialLatticePrior$quadrature_prior()

#### Returns

A
[`grid_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_posterior.md)
list.

------------------------------------------------------------------------

### `BinomialLatticePrior$prior_given_control_rate()`

The prior of the treatment effect given the target control rate

The kernel's row for the lattice cell that contains `control_rate`,
which confines the treatment effect to the differences that keep the
target treatment rate in 0, 1.

#### Usage

    BinomialLatticePrior$prior_given_control_rate(control_rate)

#### Arguments

- `control_rate`:

  The target control rate.

#### Returns

A list of three functions of the treatment effect: `cdf`, `pdf`, and
`sample`, which takes the number of draws.

------------------------------------------------------------------------

### `BinomialLatticePrior$prior_elir_ess()`

ELIR effective sample size of the prior

The prior does not depend on the target data, so its unit-scale ELIR is
computed once per worker, as the mean over several mixture fits under a
fixed seed (see
[`grid_prior_unit_elir()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/grid_prior_unit_elir.md)),
and rescaled by the target's sampling standard deviation.

#### Usage

    BinomialLatticePrior$prior_elir_ess(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data.

- `simulation_config`:

  Simulation configuration, for `n_samples_mixture_approx`.

#### Returns

The ELIR effective sample size.

------------------------------------------------------------------------

### `BinomialLatticePrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialLatticePrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
