# GaussianCommensuratePowerPrior class

This class represents a Gaussian Commensurate Power Prior model.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`MCMCModel`](https://tristanfauvel.github.io/BExTE/reference/MCMCModel.md)
-\> `GaussianCommensuratePowerPrior`

## Public fields

- `method`:

  Method name

- `heterogeneity_prior_family`:

  Heterogeneity prior family (half_normal, inverse_gamma)

- `borrows_power_parameter`:

  Whether the model samples a power parameter

- `stan_model_prefix`:

  Prefix of the compiled Stan model's name

- `summary_variables`:

  Variables to summarise from the posterior draws

## Methods

### Public methods

- [`GaussianCommensuratePowerPrior$new()`](#method-GaussianCommensuratePowerPrior-initialize)

- [`GaussianCommensuratePowerPrior$prepare_data()`](#method-GaussianCommensuratePowerPrior-prepare_data)

- [`GaussianCommensuratePowerPrior$vectorised_replicate_inference()`](#method-GaussianCommensuratePowerPrior-vectorised_replicate_inference)

- [`GaussianCommensuratePowerPrior$compute_posterior_parameters()`](#method-GaussianCommensuratePowerPrior-compute_posterior_parameters)

- [`GaussianCommensuratePowerPrior$tau_posterior_moments()`](#method-GaussianCommensuratePowerPrior-tau_posterior_moments)

- [`GaussianCommensuratePowerPrior$sample_prior()`](#method-GaussianCommensuratePowerPrior-sample_prior)

- [`GaussianCommensuratePowerPrior$joint_prior_pdf()`](#method-GaussianCommensuratePowerPrior-joint_prior_pdf)

- [`GaussianCommensuratePowerPrior$prior_pdf()`](#method-GaussianCommensuratePowerPrior-prior_pdf)

- [`GaussianCommensuratePowerPrior$prior_cdf()`](#method-GaussianCommensuratePowerPrior-prior_cdf)

- [`GaussianCommensuratePowerPrior$clone()`](#method-GaussianCommensuratePowerPrior-clone)

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

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$new()`

Initialize the GaussianCommensuratePowerPrior object

#### Usage

    GaussianCommensuratePowerPrior$new(prior, mcmc_config)

#### Arguments

- `prior`:

  The prior object

- `mcmc_config`:

  The MCMC configuration parameters

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$prepare_data()`

Prepare the data to be used by CmdStanR

#### Usage

    GaussianCommensuratePowerPrior$prepare_data(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$vectorised_replicate_inference()`

Run all simulation replicates through a quadrature mixture instead of
launching one Stan fit per replicate. The Stan implementation remains
available through `inference()` for reference and single-data-set
analyses.

#### Usage

    GaussianCommensuratePowerPrior$vectorised_replicate_inference(
      target_data,
      samples,
      to_return,
      critical_value,
      theta_0,
      confidence_level,
      null_space
    )

#### Arguments

- `target_data`:

  Target study data

- `samples`:

  Generated target-study replicates

- `to_return`:

  Requested simulation outputs

- `critical_value`:

  Critical posterior probability

- `theta_0`:

  Null treatment effect

- `confidence_level`:

  Credible interval level

- `null_space`:

  Side of the null hypothesis

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$compute_posterior_parameters()`

Compute posterior parameters

#### Usage

    GaussianCommensuratePowerPrior$compute_posterior_parameters()

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$tau_posterior_moments()`

Posterior mean and standard deviation of tau from the Stan draws,
reported as `Inf` where the moment does not exist, exactly as the
quadrature path reports them. A sample mean of such a moment would be
finite and run-dependent, or `Inf` and `NaN` once a draw overflows.

#### Usage

    GaussianCommensuratePowerPrior$tau_posterior_moments()

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$sample_prior()`

Draw samples from the prior distribution. Based on equation (8) in Hobbs
et al (2011); the plain commensurate prior shares it, with the power
parameter at one.

#### Usage

    GaussianCommensuratePowerPrior$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$joint_prior_pdf()`

Joint prior p.d.f. Based on equation (8) in Hobbs et al (2011).

#### Usage

    GaussianCommensuratePowerPrior$joint_prior_pdf(treatment_effect, gamma, tau)

#### Arguments

- `treatment_effect`:

  Treatment effect

- `gamma`:

  Power parameter

- `tau`:

  Heterogeneity parameter

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$prior_pdf()`

Prior p.d.f. of the treatment effect: the quadrature mixture the
simulations use, which covers the whole prior. Integrating tau
numerically over a finite window instead would drop most of the
heavy-tailed priors: \\\[0.001, 100\]\\ keeps 0.9% of
inverse_gamma(1/1000, 1) and 12% of a Cauchy(0, 30) on log(tau).

#### Usage

    GaussianCommensuratePowerPrior$prior_pdf(treatment_effect)

#### Arguments

- `treatment_effect`:

  Treatment effect

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$prior_cdf()`

Prior c.d.f. of the treatment effect, from the same mixture as
`prior_pdf()`. Without it the MCMC parent would take the empirical
c.d.f. of prior draws.

#### Usage

    GaussianCommensuratePowerPrior$prior_cdf(treatment_effect, ...)

#### Arguments

- `treatment_effect`:

  Treatment effect

- `...`:

  Unused; accepted for compatibility with the parent's sample-size
  argument.

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianCommensuratePowerPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
