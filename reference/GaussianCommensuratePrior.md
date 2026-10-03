# GaussianCommensuratePrior class

This class represents a Gaussian Commensurate Prior model: the
commensurability link of [Hobbs et al.
(2011)](https://onlinelibrary.wiley.com/doi/10.1111/j.1541-0420.2011.01564.x)
without the power parameter, so that \\\theta_T \| \theta_S, \tau \sim
N(\theta_S, 1 / \tau)\\ and the source likelihood enters undiscounted.
Borrowing is then governed by the commensurability precision \\\tau\\
alone.

Formally it is
[GaussianCommensuratePowerPrior](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.md)
at \\\gamma = 1\\, which is why it inherits from it: the data
preparation, the three heterogeneity prior families, the Stan program
and the quadrature mixture are all the same machinery, selected by
`borrows_power_parameter`. Only the members that mention \\\gamma\\ are
overridden here.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`MCMCModel`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.md)
-\>
[`GaussianCommensuratePowerPrior`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.md)
-\> `GaussianCommensuratePrior`

## Public fields

- `method`:

  Method name

- `borrows_power_parameter`:

  Always `FALSE` for this model

- `stan_model_prefix`:

  Prefix of the compiled Stan model's name

- `summary_variables`:

  Variables to summarise from the posterior draws

## Methods

### Public methods

- [`GaussianCommensuratePrior$new()`](#method-GaussianCommensuratePrior-initialize)

- [`GaussianCommensuratePrior$compute_posterior_parameters()`](#method-GaussianCommensuratePrior-compute_posterior_parameters)

- [`GaussianCommensuratePrior$joint_prior_pdf()`](#method-GaussianCommensuratePrior-joint_prior_pdf)

- [`GaussianCommensuratePrior$clone()`](#method-GaussianCommensuratePrior-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-empirical_bayes_update)
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
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`MCMCModel$check_mcmc_config()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$draw_mcmc_prior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-draw_mcmc_prior)
- [`MCMCModel$inference()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-inference)
- [`MCMCModel$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$quadrature_posterior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-quadrature_posterior)
- [`MCMCModel$quadrature_prior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-quadrature_prior)
- [`MCMCModel$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-sample_posterior)
- [`MCMCModel$stan_sampler()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-stan_sampler)
- [`MCMCModel$summary_rows()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-summary_rows)
- [`MCMCModel$uses_quadrature()`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.html#method-uses_quadrature)
- [`GaussianCommensuratePowerPrior$prepare_data()`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.html#method-prepare_data)
- [`GaussianCommensuratePowerPrior$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.html#method-prior_cdf)
- [`GaussianCommensuratePowerPrior$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.html#method-prior_pdf)
- [`GaussianCommensuratePowerPrior$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.html#method-sample_prior)
- [`GaussianCommensuratePowerPrior$tau_posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.html#method-tau_posterior_moments)
- [`GaussianCommensuratePowerPrior$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/GaussianCommensuratePowerPrior.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `GaussianCommensuratePrior$new()`

Initialize the GaussianCommensuratePrior object

#### Usage

    GaussianCommensuratePrior$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object

- `mcmc_config`:

  The MCMC configuration parameters

------------------------------------------------------------------------

### `GaussianCommensuratePrior$compute_posterior_parameters()`

Compute posterior parameters

#### Usage

    GaussianCommensuratePrior$compute_posterior_parameters()

------------------------------------------------------------------------

### `GaussianCommensuratePrior$joint_prior_pdf()`

Joint prior p.d.f. of the treatment effect and the commensurability
parameter. Equation (8) in Hobbs et al (2011) with the power parameter
fixed at one, so the Beta factor is absent and this takes one fewer
argument than the power prior's version.

#### Usage

    GaussianCommensuratePrior$joint_prior_pdf(treatment_effect, tau)

#### Arguments

- `treatment_effect`:

  Treatment effect

- `tau`:

  Heterogeneity parameter

------------------------------------------------------------------------

### `GaussianCommensuratePrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianCommensuratePrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
