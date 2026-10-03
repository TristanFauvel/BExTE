# BinomialPooling class

This class pools the source and target studies before analysing them
with a uniform prior on each arm response rate. The posterior is
available in closed form, so it inherits from the `BinomialConjugate`
class rather than sampling.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
[`BinomialConjugate`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.md)
-\> `BinomialPooling`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [`BinomialPooling$prepare_data()`](#method-BinomialPooling-prepare_data)

- [`BinomialPooling$prior_given_control_rate()`](#method-BinomialPooling-prior_given_control_rate)

- [`BinomialPooling$clone()`](#method-BinomialPooling-clone)

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
- [`Model$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_mean)
- [`Model$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-print_model_summary)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-vectorised_replicate_inference)
- [`BinomialConjugate$credible_interval()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-credible_interval)
- [`BinomialConjugate$initialize()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-initialize)
- [`BinomialConjugate$posterior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-posterior_cdf)
- [`BinomialConjugate$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-posterior_ess)
- [`BinomialConjugate$posterior_median()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-posterior_median)
- [`BinomialConjugate$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-posterior_moments)
- [`BinomialConjugate$posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-posterior_pdf)
- [`BinomialConjugate$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-posterior_quantile)
- [`BinomialConjugate$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-prior_cdf)
- [`BinomialConjugate$prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-prior_pdf)
- [`BinomialConjugate$sample_posterior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-sample_posterior)
- [`BinomialConjugate$sample_prior()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-sample_prior)
- [`BinomialConjugate$summary_rows()`](https://tristanfauvel.github.io/BExTE/reference/BinomialConjugate.html#method-summary_rows)

------------------------------------------------------------------------

### `BinomialPooling$prepare_data()`

Assemble the pooled event counts of the source and target studies

#### Usage

    BinomialPooling$prepare_data(target_data)

#### Arguments

- `target_data`:

  The target data for the analysis.

#### Returns

List of event counts the posterior conditions on

------------------------------------------------------------------------

### `BinomialPooling$prior_given_control_rate()`

The prior of the treatment effect given the target control rate

Pooling treats the source study's patients as the target's, so before
any target patient is seen the response rates follow the source
posterior under uniform priors, the two arms independently. Given the
control rate, the treatment effect is the treatment rate less that rate,
the treatment rate following its source posterior. The inherited
marginal prior, a uniform prior on each arm, is the one pooling updates
rather than the one its analysis assumes about the target.

#### Usage

    BinomialPooling$prior_given_control_rate(control_rate)

#### Arguments

- `control_rate`:

  The target control rate.

#### Returns

A list of three functions of the treatment effect: `cdf`, `pdf`, and
`sample`, which takes the number of draws.

------------------------------------------------------------------------

### `BinomialPooling$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialPooling$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
