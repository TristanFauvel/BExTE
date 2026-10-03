# GaussianPValueBasedPP class

This class represents a p-value based power prior method. It inherits
from the GaussianEmpiricalBayesPP class.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`GaussianConjugate`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.md)
-\> `GaussianStaticBorrowing` -\> `GaussianEmpiricalBayesPP` -\>
`GaussianPValueBasedPP`

## Public fields

- `shape_parameter`:

  The shape parameter for the method.

- `method`:

  Method name

## Methods

### Public methods

- [`GaussianPValueBasedPP$new()`](#method-GaussianPValueBasedPP-initialize)

- [`GaussianPValueBasedPP$test()`](#method-GaussianPValueBasedPP-test)

- [`GaussianPValueBasedPP$power_parameter_estimation()`](#method-GaussianPValueBasedPP-power_parameter_estimation)

- [`GaussianPValueBasedPP$vectorised_power_parameter()`](#method-GaussianPValueBasedPP-vectorised_power_parameter)

- [`GaussianPValueBasedPP$clone()`](#method-GaussianPValueBasedPP-clone)

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
- [`Model$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$print_model_summary()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-print_model_summary)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`GaussianConjugate$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-credible_interval)
- [`GaussianConjugate$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_cdf)
- [`GaussianConjugate$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_mean)
- [`GaussianConjugate$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_median)
- [`GaussianConjugate$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_moments)
- [`GaussianConjugate$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_pdf)
- [`GaussianConjugate$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_to_RBesT)
- [`GaussianConjugate$posterior_variance()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-posterior_variance)
- [`GaussianConjugate$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-prior_cdf)
- [`GaussianConjugate$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-prior_to_RBesT)
- [`GaussianConjugate$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-sample_posterior)
- [`GaussianConjugate$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-sample_prior)
- [`GaussianConjugate$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-vectorised_replicate_inference)
- `GaussianStaticBorrowing$summary_rows()`
- `GaussianEmpiricalBayesPP$empirical_bayes_update()`
- `GaussianEmpiricalBayesPP$inference()`
- `GaussianEmpiricalBayesPP$plot_power_parameter_vs_drift()`
- `GaussianEmpiricalBayesPP$prior_pdf()`
- `GaussianEmpiricalBayesPP$vectorised_posterior_parameters()`
- `GaussianEmpiricalBayesPP$vectorised_prior_variance()`

------------------------------------------------------------------------

### `GaussianPValueBasedPP$new()`

Initialize the p_value_based_PP object.

#### Usage

    GaussianPValueBasedPP$new(prior, theta_0, null_space)

#### Arguments

- `prior`:

  The prior object.

- `theta_0`:

  Boundary of the null hypothesis space

- `null_space`:

  Null space.

#### Returns

None Test method

------------------------------------------------------------------------

### `GaussianPValueBasedPP$test()`

This method performs the test for the given target data.

#### Usage

    GaussianPValueBasedPP$test(
      target_data,
      source_treatment_effect_estimate,
      target_treatment_effect_estimate,
      test_type = "t-test"
    )

#### Arguments

- `target_data`:

  The target data object.

- `source_treatment_effect_estimate`:

  The source treatment effect estimate.

- `target_treatment_effect_estimate`:

  The target treatment effect estimate.

- `test_type`:

  Type of frequentist test used

#### Returns

The p-value. Power parameter estimation method

------------------------------------------------------------------------

### `GaussianPValueBasedPP$power_parameter_estimation()`

This method estimates the power parameter for the given target data.

#### Usage

    GaussianPValueBasedPP$power_parameter_estimation(target_data)

#### Arguments

- `target_data`:

  The target data object.

#### Returns

The power parameter.

------------------------------------------------------------------------

### `GaussianPValueBasedPP$vectorised_power_parameter()`

Estimate the power parameter for every replicate at once.

Reproduces `test()` followed by `power_parameter_estimation()`. The two
one-sided equivalence tests are the same summary-statistic t-tests that
`test()` runs through BSDA, evaluated on vectors.

#### Usage

    GaussianPValueBasedPP$vectorised_power_parameter(target_data, samples)

#### Arguments

- `target_data`:

  The target data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of power parameters.

------------------------------------------------------------------------

### `GaussianPValueBasedPP$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianPValueBasedPP$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
