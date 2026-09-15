# TestThenPoolEquivalence class

This class extends the TestThenPool class to implement the
Test-Then-Pool framework for equivalence trials.

## Details

The TestThenPoolEquivalence class provides methods for testing and
inference in equivalence trials using the Test-Then-Pool framework.

## Super classes

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\>
[`TestThenPool`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.md)
-\> `TestThenPoolEquivalence`

## Public fields

- `significance_level`:

  Significance level for the test

- `equivalence_margin`:

  Equivalence margin for the test

- `method`:

  Method name

## Methods

### Public methods

- [`TestThenPoolEquivalence$new()`](#method-TestThenPoolEquivalence-initialize)

- [`TestThenPoolEquivalence$test_pvalue()`](#method-TestThenPoolEquivalence-test_pvalue)

- [`TestThenPoolEquivalence$test()`](#method-TestThenPoolEquivalence-test)

- [`TestThenPoolEquivalence$vectorised_test_pvalue()`](#method-TestThenPoolEquivalence-vectorised_test_pvalue)

- [`TestThenPoolEquivalence$vectorised_pool()`](#method-TestThenPoolEquivalence-vectorised_pool)

- [`TestThenPoolEquivalence$clone()`](#method-TestThenPoolEquivalence-clone)

Inherited methods

- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
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
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`TestThenPool$credible_interval()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-credible_interval)
- [`TestThenPool$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-empirical_bayes_update)
- [`TestThenPool$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-inference)
- [`TestThenPool$plot_test_pvalue_vs_drift()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-plot_test_pvalue_vs_drift)
- [`TestThenPool$plot_test_vs_drift()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-plot_test_vs_drift)
- [`TestThenPool$posterior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-posterior_cdf)
- [`TestThenPool$posterior_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-posterior_ess)
- [`TestThenPool$posterior_median()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-posterior_median)
- [`TestThenPool$posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-posterior_pdf)
- [`TestThenPool$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-posterior_to_RBesT)
- [`TestThenPool$prior_cdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-prior_cdf)
- [`TestThenPool$prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-prior_pdf)
- [`TestThenPool$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-prior_to_RBesT)
- [`TestThenPool$sample_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-sample_posterior)
- [`TestThenPool$sample_prior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-sample_prior)
- [`TestThenPool$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-test_decision)
- [`TestThenPool$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TestThenPool.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `TestThenPoolEquivalence$new()`

Initializes a TestThenPoolEquivalence object.

#### Usage

    TestThenPoolEquivalence$new(prior, mcmc_config = NULL)

#### Arguments

- `prior`:

  The prior distribution for the treatment effect.

- `mcmc_config`:

  Configuration for the MCMC sampling.

------------------------------------------------------------------------

### `TestThenPoolEquivalence$test_pvalue()`

Performs the test in the Test-Then-Pool framework for equivalence.

#### Usage

    TestThenPoolEquivalence$test_pvalue(target_data, test_type = "t-test")

#### Arguments

- `target_data`:

  The data from the target study.

- `test_type`:

  Test type

------------------------------------------------------------------------

### `TestThenPoolEquivalence$test()`

#### Usage

    TestThenPoolEquivalence$test(target_data, test_type = "t-test")

#### Arguments

- `target_data`:

  Target study data

- `test_type`:

  Frequentist test

------------------------------------------------------------------------

### `TestThenPoolEquivalence$vectorised_test_pvalue()`

Equivalence test p-value for every replicate at once.

`inference()` calls `test()` without a test type, so the t-test default
is the one that runs in the simulation.

#### Usage

    TestThenPoolEquivalence$vectorised_test_pvalue(target_data, samples)

#### Arguments

- `target_data`:

  Target study data.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of p-values.

------------------------------------------------------------------------

### `TestThenPoolEquivalence$vectorised_pool()`

Rejecting equivalence's null means the studies are close enough to pool.

#### Usage

    TestThenPoolEquivalence$vectorised_pool(p_value)

#### Arguments

- `p_value`:

  Vector of p-values.

#### Returns

A logical vector.

------------------------------------------------------------------------

### `TestThenPoolEquivalence$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TestThenPoolEquivalence$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
