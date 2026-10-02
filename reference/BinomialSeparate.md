# BinomialSeparate class

This class analyses the target study on its own, with a uniform prior on
each arm response rate. The posterior is available in closed form, so it
inherits from the `BinomialConjugate` class rather than sampling.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`BinomialConjugate`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.md)
-\> `BinomialSeparate`

## Public fields

- `method`:

  Method name

## Methods

### Public methods

- [`BinomialSeparate$prepare_data()`](#method-BinomialSeparate-prepare_data)

- [`BinomialSeparate$clone()`](#method-BinomialSeparate-clone)

Inherited methods

- [`Model$calibrate_for_design()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-calibrate_for_design)
- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-print_model_summary)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)
- [`BinomialConjugate$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-credible_interval)
- [`BinomialConjugate$initialize()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-initialize)
- [`BinomialConjugate$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-posterior_cdf)
- [`BinomialConjugate$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-posterior_ess)
- [`BinomialConjugate$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-posterior_median)
- [`BinomialConjugate$posterior_moments()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-posterior_moments)
- [`BinomialConjugate$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-posterior_pdf)
- [`BinomialConjugate$posterior_quantile()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-posterior_quantile)
- [`BinomialConjugate$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-prior_cdf)
- [`BinomialConjugate$prior_given_control_rate()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-prior_given_control_rate)
- [`BinomialConjugate$prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-prior_pdf)
- [`BinomialConjugate$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-sample_posterior)
- [`BinomialConjugate$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-sample_prior)
- [`BinomialConjugate$summary_rows()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/BinomialConjugate.html#method-summary_rows)

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
