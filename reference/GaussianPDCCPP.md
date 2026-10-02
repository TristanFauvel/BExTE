# GaussianPDCCPP class

This class inherits from GaussianEmpiricalBayesPP and implements the
PDCCPP method.

## Format

R6Class object.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`GaussianConjugate`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.md)
-\> `GaussianStaticBorrowing` -\> `GaussianEmpiricalBayesPP` -\>
`GaussianPDCCPP`

## Public fields

- `null_space`:

  Side of the null hypothesis space

- `method`:

  Method name

## Methods

### Public methods

- [`GaussianPDCCPP$new()`](#method-GaussianPDCCPP-initialize)

- [`GaussianPDCCPP$power_parameter_estimation()`](#method-GaussianPDCCPP-power_parameter_estimation)

- [`GaussianPDCCPP$vectorised_power_parameter()`](#method-GaussianPDCCPP-vectorised_power_parameter)

- [`GaussianPDCCPP$calibration_parameter()`](#method-GaussianPDCCPP-calibration_parameter)

- [`GaussianPDCCPP$power_parameter_from_calibration()`](#method-GaussianPDCCPP-power_parameter_from_calibration)

- [`GaussianPDCCPP$clone()`](#method-GaussianPDCCPP-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_quantile)
- [`Model$print_model_summary()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-print_model_summary)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`GaussianConjugate$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-credible_interval)
- [`GaussianConjugate$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_cdf)
- [`GaussianConjugate$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_mean)
- [`GaussianConjugate$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_median)
- [`GaussianConjugate$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_moments)
- [`GaussianConjugate$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_pdf)
- [`GaussianConjugate$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_to_RBesT)
- [`GaussianConjugate$posterior_variance()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-posterior_variance)
- [`GaussianConjugate$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-prior_cdf)
- [`GaussianConjugate$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-prior_to_RBesT)
- [`GaussianConjugate$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-sample_posterior)
- [`GaussianConjugate$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-sample_prior)
- [`GaussianConjugate$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/GaussianConjugate.html#method-vectorised_replicate_inference)
- `GaussianStaticBorrowing$summary_rows()`
- `GaussianEmpiricalBayesPP$empirical_bayes_update()`
- `GaussianEmpiricalBayesPP$inference()`
- `GaussianEmpiricalBayesPP$plot_power_parameter_vs_drift()`
- `GaussianEmpiricalBayesPP$prior_pdf()`
- `GaussianEmpiricalBayesPP$vectorised_posterior_parameters()`
- `GaussianEmpiricalBayesPP$vectorised_prior_variance()`

------------------------------------------------------------------------

### `GaussianPDCCPP$new()`

Initialize the GaussianPDCCPP object.

#### Usage

    GaussianPDCCPP$new(prior, theta_0, null_space)

#### Arguments

- `prior`:

  The prior object.

- `theta_0`:

  The theta_0 value.

- `null_space`:

  Null space

#### Returns

NULL Estimate the power parameter using the PDCCPP method.

------------------------------------------------------------------------

### `GaussianPDCCPP$power_parameter_estimation()`

#### Usage

    GaussianPDCCPP$power_parameter_estimation(target_data)

#### Arguments

- `target_data`:

  The target data.

- `source_treatment_effect_estimate`:

  The source treatment effect estimate.

- `target_treatment_effect_estimate`:

  The target treatment effect estimate.

#### Returns

The estimated power parameter.

------------------------------------------------------------------------

### `GaussianPDCCPP$vectorised_power_parameter()`

The power parameter for every replicate at once

The calibration depends on a replicate only through its target sampling
variance, and it is a smooth function of it. Rather than search for it
once per replicate, it is computed at 200 variances spaced evenly on the
log scale across the replicates' range and interpolated linearly. Near
the borrowing cut-off the power parameter is very sensitive to the
calibration, so these few searches are run to a tolerance of 1e-9 rather
than the configured one: the interpolated calibration is then closer to
the exact one than a per-replicate search at the configured tolerance
would be. Equation (9) is evaluated for every replicate, exactly as
`power_parameter_estimation()` does.

#### Usage

    GaussianPDCCPP$vectorised_power_parameter(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of power parameters, one per replicate.

------------------------------------------------------------------------

### `GaussianPDCCPP$calibration_parameter()`

The calibration parameter z_1-c/2 for one target sampling variance

#### Usage

    GaussianPDCCPP$calibration_parameter(
      target_data_sampling_variance,
      target_sample_size_per_arm,
      source_treatment_effect_estimate,
      tolerance = self$parameters$tolerance
    )

#### Arguments

- `target_data_sampling_variance`:

  Target sampling variance, per patient.

- `target_sample_size_per_arm`:

  Target sample size per arm.

- `source_treatment_effect_estimate`:

  Source estimate, after `hypothesis_space_transformation()`.

- `tolerance`:

  Tolerance of the search; the configured one by default.

#### Returns

The calibration parameter, a positive number.

------------------------------------------------------------------------

### `GaussianPDCCPP$power_parameter_from_calibration()`

The power parameter given the calibration, equation (9) of
Nikolakopoulos et al (2018)

Vectorised over its arguments, so it serves one replicate or all of
them.

#### Usage

    GaussianPDCCPP$power_parameter_from_calibration(
      target_treatment_effect_estimate,
      source_treatment_effect_estimate,
      target_data_sampling_variance,
      target_sample_size_per_arm,
      calibration_parameter
    )

#### Arguments

- `target_treatment_effect_estimate`:

  Target estimates, after `hypothesis_space_transformation()`.

- `source_treatment_effect_estimate`:

  Source estimate, after the same transformation.

- `target_data_sampling_variance`:

  Target sampling variances, per patient.

- `target_sample_size_per_arm`:

  Target sample size per arm.

- `calibration_parameter`:

  Calibration parameters z_1-c/2.

#### Returns

The power parameters.

------------------------------------------------------------------------

### `GaussianPDCCPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianPDCCPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
