# GaussianSeparate class

This class represents a model with separate Gaussian components,
inheriting from `GaussianStaticBorrowing`. The power parameter is set to
0.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`GaussianConjugate`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.md)
-\> `GaussianStaticBorrowing` -\> `GaussianSeparate`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [`GaussianSeparate$new()`](#method-GaussianSeparate-initialize)

- [`GaussianSeparate$clone()`](#method-GaussianSeparate-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference)
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
- [`GaussianConjugate$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-prior_pdf)
- [`GaussianConjugate$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-prior_to_RBesT)
- [`GaussianConjugate$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-sample_posterior)
- [`GaussianConjugate$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-sample_prior)
- [`GaussianConjugate$vectorised_posterior_parameters()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-vectorised_posterior_parameters)
- [`GaussianConjugate$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/GaussianConjugate.html#method-vectorised_replicate_inference)
- `GaussianStaticBorrowing$summary_rows()`
- `GaussianStaticBorrowing$vectorised_prior_variance()`

------------------------------------------------------------------------

### `GaussianSeparate$new()`

#### Usage

    GaussianSeparate$new(prior)

#### Arguments

- `prior`:

  Prior

#### Returns

A Model object.

------------------------------------------------------------------------

### `GaussianSeparate$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianSeparate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
NA
#> [1] NA
```
