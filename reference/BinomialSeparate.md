# BinomialSeparate class

This class analyses the target study on its own, with a uniform prior on
each arm response rate. The posterior is available in closed form, so it
inherits from the `BinomialConjugate` class rather than sampling.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
`BinomialConjugate` -\> `BinomialSeparate`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [`BinomialSeparate$prepare_data()`](#method-BinomialSeparate-prepare_data)

- [`BinomialSeparate$clone()`](#method-BinomialSeparate-clone)

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
- [`Model$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_mean)
- [`Model$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_to_RBesT)
- [`Model$prior_ESS()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-vectorised_replicate_inference)
- `BinomialConjugate$credible_interval()`
- `BinomialConjugate$initialize()`
- `BinomialConjugate$posterior_cdf()`
- `BinomialConjugate$posterior_ess()`
- `BinomialConjugate$posterior_median()`
- `BinomialConjugate$posterior_moments()`
- `BinomialConjugate$posterior_pdf()`
- `BinomialConjugate$posterior_quantile()`
- `BinomialConjugate$prior_cdf()`
- `BinomialConjugate$prior_pdf()`
- `BinomialConjugate$sample_posterior()`
- `BinomialConjugate$sample_prior()`

------------------------------------------------------------------------

### `BinomialSeparate$prepare_data()`

Assemble the event counts of the target study

#### Usage

    BinomialSeparate$prepare_data(target_data)

#### Arguments

- `target_data`:

  The target data for the analysis.

#### Returns

List of event counts the posterior conditions on

------------------------------------------------------------------------

### `BinomialSeparate$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialSeparate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
