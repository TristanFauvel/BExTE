# GaussianCommensuratePowerPrior class

This class represents a Gaussian Commensurate Power Prior model.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`MCMCModel`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.md)
-\> `GaussianCommensuratePowerPrior`

## Public fields

- `method`:

  Method name

- `heterogeneity_prior_family`:

  Heterogeneity prior family (half_normal, inverse_gamma)

- `summary_variables`:

  Variables to summarise from the posterior draws

## Methods

### Public methods

- [`GaussianCommensuratePowerPrior$new()`](#method-GaussianCommensuratePowerPrior-initialize)

- [`GaussianCommensuratePowerPrior$prepare_data()`](#method-GaussianCommensuratePowerPrior-prepare_data)

- [`GaussianCommensuratePowerPrior$vectorised_replicate_inference()`](#method-GaussianCommensuratePowerPrior-vectorised_replicate_inference)

- [`GaussianCommensuratePowerPrior$compute_posterior_parameters()`](#method-GaussianCommensuratePowerPrior-compute_posterior_parameters)

- [`GaussianCommensuratePowerPrior$sample_prior()`](#method-GaussianCommensuratePowerPrior-sample_prior)

- [`GaussianCommensuratePowerPrior$joint_prior_pdf()`](#method-GaussianCommensuratePowerPrior-joint_prior_pdf)

- [`GaussianCommensuratePowerPrior$unnormalized_prior_pdf()`](#method-GaussianCommensuratePowerPrior-unnormalized_prior_pdf)

- [`GaussianCommensuratePowerPrior$prior_pdf()`](#method-GaussianCommensuratePowerPrior-prior_pdf)

- [`GaussianCommensuratePowerPrior$clone()`](#method-GaussianCommensuratePowerPrior-clone)

Inherited methods

- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`MCMCModel$check_mcmc_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-check_mcmc_config)
- [`MCMCModel$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-credible_interval)
- [`MCMCModel$draw_mcmc_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-draw_mcmc_prior)
- [`MCMCModel$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-inference)
- [`MCMCModel$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_cdf)
- [`MCMCModel$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_ess)
- [`MCMCModel$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_median)
- [`MCMCModel$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-posterior_pdf)
- [`MCMCModel$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-prior_cdf)
- [`MCMCModel$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/MCMCModel.html#method-sample_posterior)

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

### `GaussianCommensuratePowerPrior$sample_prior()`

Draw samples from the prior distribution. Based on equation 8 in Hobbs
et al (2011).

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

### `GaussianCommensuratePowerPrior$unnormalized_prior_pdf()`

Integrate out gamma and tau to get the marginal PDF for treatment_effect

#### Usage

    GaussianCommensuratePowerPrior$unnormalized_prior_pdf(treatment_effect)

#### Arguments

- `treatment_effect`:

  Treatment effect

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$prior_pdf()`

Prior p.d.f. of the treatment effect

#### Usage

    GaussianCommensuratePowerPrior$prior_pdf(treatment_effect)

#### Arguments

- `treatment_effect`:

  Treatment effect

------------------------------------------------------------------------

### `GaussianCommensuratePowerPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianCommensuratePowerPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
