# TestThenPool class

This class implements the Test-Then-Pool framework for Bayesian
borrowing in clinical trials.

## Details

The TestThenPool class provides methods for testing and inference with
the Test-then-Pool method.

## Super class

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\> `TestThenPool`

## Public fields

- `pooling`:

  Pooling model

- `separate`:

  Separate model

- `pool`:

  Pooling indicator

- `inference_method`:

  Inference method

- `summary_measure_likelihood`:

  Summary measure distribution

- `source_treatment_effect_estimate`:

  Source treatment effect estimate

- `source_standard_error`:

  Source standard error

- `method`:

  Method name

- `empirical_bayes`:

  Indicator that the method uses empirical Bayes

## Methods

### Public methods

- [`TestThenPool$new()`](#method-TestThenPool-initialize)

- [`TestThenPool$test()`](#method-TestThenPool-test)

- [`TestThenPool$test_pvalue()`](#method-TestThenPool-test_pvalue)

- [`TestThenPool$vectorised_test_pvalue()`](#method-TestThenPool-vectorised_test_pvalue)

- [`TestThenPool$vectorised_pool()`](#method-TestThenPool-vectorised_pool)

- [`TestThenPool$vectorised_replicate_inference()`](#method-TestThenPool-vectorised_replicate_inference)

- [`TestThenPool$inference()`](#method-TestThenPool-inference)

- [`TestThenPool$empirical_bayes_update()`](#method-TestThenPool-empirical_bayes_update)

- [`TestThenPool$credible_interval()`](#method-TestThenPool-credible_interval)

- [`TestThenPool$posterior_median()`](#method-TestThenPool-posterior_median)

- [`TestThenPool$posterior_pdf()`](#method-TestThenPool-posterior_pdf)

- [`TestThenPool$prior_pdf()`](#method-TestThenPool-prior_pdf)

- [`TestThenPool$posterior_cdf()`](#method-TestThenPool-posterior_cdf)

- [`TestThenPool$prior_cdf()`](#method-TestThenPool-prior_cdf)

- [`TestThenPool$sample_prior()`](#method-TestThenPool-sample_prior)

- [`TestThenPool$sample_posterior()`](#method-TestThenPool-sample_posterior)

- [`TestThenPool$prior_to_RBesT()`](#method-TestThenPool-prior_to_RBesT)

- [`TestThenPool$posterior_ess()`](#method-TestThenPool-posterior_ess)

- [`TestThenPool$posterior_to_RBesT()`](#method-TestThenPool-posterior_to_RBesT)

- [`TestThenPool$test_decision()`](#method-TestThenPool-test_decision)

- [`TestThenPool$plot_test_vs_drift()`](#method-TestThenPool-plot_test_vs_drift)

- [`TestThenPool$plot_test_pvalue_vs_drift()`](#method-TestThenPool-plot_test_pvalue_vs_drift)

- [`TestThenPool$clone()`](#method-TestThenPool-clone)

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

------------------------------------------------------------------------

### `TestThenPool$new()`

Initializes a TestThenPool object.

#### Usage

    TestThenPool$new(prior, mcmc_config = NULL)

#### Arguments

- `prior`:

  The prior distribution for the treatment effect.

- `mcmc_config`:

  Configuration for the MCMC sampling.

------------------------------------------------------------------------

### `TestThenPool$test()`

Performs the test with the Test-then-Pool method.

#### Usage

    TestThenPool$test(target_data)

#### Arguments

- `target_data`:

  The data from the target study.

------------------------------------------------------------------------

### `TestThenPool$test_pvalue()`

p-value of the test

#### Usage

    TestThenPool$test_pvalue(target_data)

#### Arguments

- `target_data`:

  The data from the target study.

------------------------------------------------------------------------

### `TestThenPool$vectorised_test_pvalue()`

p-value of the test, for every replicate at once

Subclasses override this with the vectorised form of `test_pvalue()`.
Returning `NULL` means "no fast path" and keeps the replicate loop.

#### Usage

    TestThenPool$vectorised_test_pvalue(target_data, samples)

#### Arguments

- `target_data`:

  The data from the target study.

- `samples`:

  Data frame of generated replicates.

#### Returns

A vector of p-values, or `NULL`.

------------------------------------------------------------------------

### `TestThenPool$vectorised_pool()`

Whether to pool, for every replicate at once

Subclasses override this to turn `vectorised_test_pvalue()` into a
pooling decision, since the two variants read the test in opposite
directions.

#### Usage

    TestThenPool$vectorised_pool(p_value)

#### Arguments

- `p_value`:

  Vector of p-values.

#### Returns

A logical vector.

------------------------------------------------------------------------

### `TestThenPool$vectorised_replicate_inference()`

Run every replicate at once

The test picks a prior per replicate, and both branches are conjugate
Gaussian models with the same prior mean, so the whole simulation is a
single normal-prior update with a per-replicate variance.

#### Usage

    TestThenPool$vectorised_replicate_inference(
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

  Target study data.

- `samples`:

  Data frame of generated replicates.

- `to_return`:

  Character vector of requested outputs.

- `critical_value`:

  Critical value for hypothesis testing.

- `theta_0`:

  Null hypothesis value.

- `confidence_level`:

  Confidence level for the credible interval.

- `null_space`:

  The null space for hypothesis testing.

#### Returns

A list of simulation results, or `NULL` to use the replicate loop.

------------------------------------------------------------------------

### `TestThenPool$inference()`

Performs inference with the Test-then-Pool method.

#### Usage

    TestThenPool$inference(target_data)

#### Arguments

- `target_data`:

  The data from the target study.

------------------------------------------------------------------------

### `TestThenPool$empirical_bayes_update()`

Performs the empirical Bayes update with the Test-then-Pool method.

#### Usage

    TestThenPool$empirical_bayes_update(target_data)

#### Arguments

- `target_data`:

  The data from the target study.

------------------------------------------------------------------------

### `TestThenPool$credible_interval()`

Calculates the credible interval with the Test-then-Pool method.

#### Usage

    TestThenPool$credible_interval(level = 0.95)

#### Arguments

- `level`:

  The confidence level for the credible interval (default is 0.95).

------------------------------------------------------------------------

### `TestThenPool$posterior_median()`

Return the median of the posterior distribution.

#### Usage

    TestThenPool$posterior_median(...)

#### Arguments

- `...`:

  Optional argument

------------------------------------------------------------------------

### `TestThenPool$posterior_pdf()`

Calculates the posterior probability density function with the
Test-then-Pool method.

#### Usage

    TestThenPool$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The treatment effect of interest.

------------------------------------------------------------------------

### `TestThenPool$prior_pdf()`

Calculates the prior probability density function with the
Test-then-Pool method.

#### Usage

    TestThenPool$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The treatment effect of interest.

------------------------------------------------------------------------

### `TestThenPool$posterior_cdf()`

Calculates the posterior cumulative distribution function with the
Test-then-Pool method.

#### Usage

    TestThenPool$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  The treatment effect of interest.

------------------------------------------------------------------------

### `TestThenPool$prior_cdf()`

CDF of the prior distribution

#### Usage

    TestThenPool$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Treatment effect value in the target study.

------------------------------------------------------------------------

### `TestThenPool$sample_prior()`

Samples from the prior distribution with the Test-then-Pool method.

#### Usage

    TestThenPool$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `TestThenPool$sample_posterior()`

Samples from the posterior distribution with the Test-then-Pool method.

#### Usage

    TestThenPool$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `TestThenPool$prior_to_RBesT()`

Converts the prior distribution to the RBesT format.

#### Usage

    TestThenPool$prior_to_RBesT(...)

#### Arguments

- `...`:

  Optional argument

#### Returns

None

------------------------------------------------------------------------

### `TestThenPool$posterior_ess()`

Effective sample sizes of the current posterior

The posterior is the one of the component the test selected, so the
effective sample sizes are that component's. Delegating rather than
inheriting also keeps whichever fast route the component has: the
binomial branch holds two conjugate models, which report both quantities
in closed form.

#### Usage

    TestThenPool$posterior_ess(target_data, ...)

#### Arguments

- `target_data`:

  Target study data

- `...`:

  Passed on to the selected component.

#### Returns

A list with the `moment` and `precision` effective sample sizes.

------------------------------------------------------------------------

### `TestThenPool$posterior_to_RBesT()`

Convert the posterior distribution to RBesT format

#### Usage

    TestThenPool$posterior_to_RBesT(target_data, simulation_config)

#### Arguments

- `target_data`:

  Target study data

- `simulation_config`:

  Simulation configuration

------------------------------------------------------------------------

### `TestThenPool$test_decision()`

Return the test decision based on the posterior distribution. The
decision rule is: \\P(\theta_T \> \theta_0 \mid \mathbf{D}\_S,
\mathbf{D}\_T) \> ) \eta\\ (if null_space is right).

#### Usage

    TestThenPool$test_decision(
      critical_value,
      theta_0,
      null_space,
      confidence_level
    )

#### Arguments

- `critical_value`:

  Critical value

- `theta_0`:

  Boundary of the null hypothesis space

- `null_space`:

  Side of the null hypothesis space

- `confidence_level`:

  Confidence level of the test

------------------------------------------------------------------------

### `TestThenPool$plot_test_vs_drift()`

Plot the pooling test decision as a function of drift in treatment
effect

#### Usage

    TestThenPool$plot_test_vs_drift(
      source_treatment_effect_estimate,
      target_data,
      min_drift,
      max_drift,
      resolution
    )

#### Arguments

- `source_treatment_effect_estimate`:

  Treatment effect estimate in the source study

- `target_data`:

  Target study data

- `min_drift`:

  Minimum drift value

- `max_drift`:

  Maximum drift value

- `resolution`:

  Number of points on the drift grid.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `TestThenPool$plot_test_pvalue_vs_drift()`

Plot the pooling test p-value as a function of drift in treatment effect

#### Usage

    TestThenPool$plot_test_pvalue_vs_drift(
      source_treatment_effect_estimate,
      target_data,
      min_drift,
      max_drift,
      resolution
    )

#### Arguments

- `source_treatment_effect_estimate`:

  Treatment effect estimate in the source study

- `target_data`:

  Target study data

- `min_drift`:

  Minimum drift value

- `max_drift`:

  Maximum drift value

- `resolution`:

  Number of points on the drift grid.

#### Returns

The prior PDF.

------------------------------------------------------------------------

### `TestThenPool$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TestThenPool$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
