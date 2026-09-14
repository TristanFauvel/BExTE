# StaticBorrowingGaussian class

This class represents a model with a Gaussian prior derived from static
borrowing, and a Gaussian likelihood. It inherits from the
`ConjugateGaussian` class.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`ConjugateGaussian`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.md)
-\> `StaticBorrowingGaussian`

## Public fields

- `power_parameter`:

  The power parameter for the model. A NULL value indicates no power
  parameter, whereas a non-zero value sets the prior variance based on
  the source's standard error and the power parameter.

- `prior_var`:

  The variance of the prior. This is set based on the power parameter.

- `method`:

  Method name

## Methods

### Public methods

- [`StaticBorrowingGaussian$new()`](#method-StaticBorrowingGaussian-initialize)

- [`StaticBorrowingGaussian$vectorised_prior_variance()`](#method-StaticBorrowingGaussian-vectorised_prior_variance)

- [`StaticBorrowingGaussian$clone()`](#method-StaticBorrowingGaussian-clone)

Inherited methods

- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference)
- [`Model$inference_cache_scope()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_ess)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$prior_ESS()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`ConjugateGaussian$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-credible_interval)
- [`ConjugateGaussian$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_cdf)
- [`ConjugateGaussian$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_mean)
- [`ConjugateGaussian$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_median)
- [`ConjugateGaussian$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_moments)
- [`ConjugateGaussian$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_pdf)
- [`ConjugateGaussian$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_to_RBesT)
- [`ConjugateGaussian$posterior_variance()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-posterior_variance)
- [`ConjugateGaussian$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-prior_cdf)
- [`ConjugateGaussian$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-prior_pdf)
- [`ConjugateGaussian$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-prior_to_RBesT)
- [`ConjugateGaussian$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-sample_posterior)
- [`ConjugateGaussian$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-sample_prior)
- [`ConjugateGaussian$vectorised_posterior_parameters()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-vectorised_posterior_parameters)
- [`ConjugateGaussian$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/ConjugateGaussian.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `StaticBorrowingGaussian$new()`

#### Usage

    StaticBorrowingGaussian$new(prior)

#### Arguments

- `prior`:

  Prior

#### Returns

A Model object.

------------------------------------------------------------------------

### `StaticBorrowingGaussian$vectorised_prior_variance()`

Prior variance for each replicate

Static borrowing fixes the prior up front, so every replicate shares it.

#### Usage

    StaticBorrowingGaussian$vectorised_prior_variance(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

The prior variance.

------------------------------------------------------------------------

### `StaticBorrowingGaussian$clone()`

The objects of this class are cloneable with this method.

#### Usage

    StaticBorrowingGaussian$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
NA
#> [1] NA
```
