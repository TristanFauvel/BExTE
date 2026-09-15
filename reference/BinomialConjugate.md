# BinomialConjugate class

Base class for the binomial models whose posterior is available in
closed form.

Both the separate-analysis and the pooled-analysis models place a
uniform prior on the control rate and, conditionally on it, a uniform
prior on the treatment effect over `(-control_rate, 1 - control_rate)`.
That interval has width 1 whatever the control rate, so the joint prior
density is constant and the pair `(control_rate, treatment_rate)` is
uniform on the unit square, i.e. independent `Beta(1, 1)` priors on the
two arm response rates. The binomial likelihood factorises over arms, so
the posterior is a product of two independent Beta distributions:

\$\$p_c \mid D \sim Beta(s_c + 1, n_c - s_c + 1), \quad p_t \mid D \sim
Beta(s_t + 1, n_t - s_t + 1)\$\$

and the treatment effect is their difference. Moments are available
analytically; the distribution function of the difference is obtained by
one-dimensional quadrature and inverted numerically for quantiles, so no
Monte Carlo error enters the operating characteristics.

## Super class

[`Model`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.md)
-\> `BinomialConjugate`

## Public fields

- `control_shape1`:

  First shape parameter of the control rate posterior.

- `control_shape2`:

  Second shape parameter of the control rate posterior.

- `treatment_shape1`:

  First shape parameter of the treatment rate posterior.

- `treatment_shape2`:

  Second shape parameter of the treatment rate posterior.

- `n_quadrature_nodes`:

  Number of nodes used to integrate over the control rate.

- `quadrature_control_rates`:

  Quadrature nodes on the control rate posterior.

## Methods

### Public methods

- [`BinomialConjugate$new()`](#method-BinomialConjugate-initialize)

- [`BinomialConjugate$prepare_data()`](#method-BinomialConjugate-prepare_data)

- [`BinomialConjugate$posterior_moments()`](#method-BinomialConjugate-posterior_moments)

- [`BinomialConjugate$posterior_cdf()`](#method-BinomialConjugate-posterior_cdf)

- [`BinomialConjugate$posterior_pdf()`](#method-BinomialConjugate-posterior_pdf)

- [`BinomialConjugate$posterior_quantile()`](#method-BinomialConjugate-posterior_quantile)

- [`BinomialConjugate$posterior_median()`](#method-BinomialConjugate-posterior_median)

- [`BinomialConjugate$credible_interval()`](#method-BinomialConjugate-credible_interval)

- [`BinomialConjugate$posterior_ess()`](#method-BinomialConjugate-posterior_ess)

- [`BinomialConjugate$sample_posterior()`](#method-BinomialConjugate-sample_posterior)

- [`BinomialConjugate$sample_prior()`](#method-BinomialConjugate-sample_prior)

- [`BinomialConjugate$prior_pdf()`](#method-BinomialConjugate-prior_pdf)

- [`BinomialConjugate$prior_cdf()`](#method-BinomialConjugate-prior_cdf)

- [`BinomialConjugate$clone()`](#method-BinomialConjugate-clone)

Inherited methods

- [`Model$check_data()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-check_data)
- [`Model$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference)
- [`Model$inference_cache_scope()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_mean()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_mean)
- [`Model$posterior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-posterior_to_RBesT)
- [`Model$prior_ESS()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_ESS)
- [`Model$prior_elir_ess()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_to_RBesT)
- [`Model$prior_treatment_benefit()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-prior_treatment_benefit)
- [`Model$simulation_for_given_treatment_effect()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-test_decision)
- [`Model$vectorised_replicate_inference()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/Model.html#method-vectorised_replicate_inference)

------------------------------------------------------------------------

### `BinomialConjugate$new()`

Initialize the BinomialConjugate object

#### Usage

    BinomialConjugate$new(prior, mcmc_config = NULL)

#### Arguments

- `prior`:

  The prior object

- `mcmc_config`:

  Unused, kept so that the model factory can build every binomial model
  with the same call.

------------------------------------------------------------------------

### `BinomialConjugate$prepare_data()`

Assemble the event counts the posterior conditions on. Subclasses must
implement the 'prepare_data' method.

#### Usage

    BinomialConjugate$prepare_data(target_data)

#### Arguments

- `target_data`:

  The target data for inference

------------------------------------------------------------------------

### `BinomialConjugate$posterior_moments()`

Compute the posterior moments in closed form

#### Usage

    BinomialConjugate$posterior_moments(target_data)

#### Arguments

- `target_data`:

  Target study data

------------------------------------------------------------------------

### `BinomialConjugate$posterior_cdf()`

Posterior CDF of the treatment effect

#### Usage

    BinomialConjugate$posterior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior CDF

------------------------------------------------------------------------

### `BinomialConjugate$posterior_pdf()`

Posterior PDF of the treatment effect

#### Usage

    BinomialConjugate$posterior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the posterior PDF

------------------------------------------------------------------------

### `BinomialConjugate$posterior_quantile()`

Quantiles of the posterior treatment effect

#### Usage

    BinomialConjugate$posterior_quantile(probability)

#### Arguments

- `probability`:

  Probabilities at which to evaluate the quantile function

------------------------------------------------------------------------

### `BinomialConjugate$posterior_median()`

Posterior median

#### Usage

    BinomialConjugate$posterior_median(...)

#### Arguments

- `...`:

  Additional argument

#### Returns

The posterior median

------------------------------------------------------------------------

### `BinomialConjugate$credible_interval()`

Credible interval on the treatment effect

#### Usage

    BinomialConjugate$credible_interval(level = 0.95)

#### Arguments

- `level`:

  Level of the credible interval

------------------------------------------------------------------------

### `BinomialConjugate$posterior_ess()`

Effective sample sizes of the current posterior

The posterior variance is available in closed form and the credible
interval comes from the same quadrature the rest of the class uses, so
both effective sample sizes are evaluated directly. The inherited route
would instead fit a mixture to a finite sample drawn from the posterior,
which costs a mixture fit per replicate and leaves Monte Carlo error in
a quantity that has no need of it.

#### Usage

    BinomialConjugate$posterior_ess(target_data, ...)

#### Arguments

- `target_data`:

  Target study data

- `...`:

  Unused, kept so that the simulation can call every model the same way.

#### Returns

A list with the `moment` and `precision` effective sample sizes.

------------------------------------------------------------------------

### `BinomialConjugate$sample_posterior()`

Draw independent samples from the posterior

#### Usage

    BinomialConjugate$sample_posterior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw

------------------------------------------------------------------------

### `BinomialConjugate$sample_prior()`

Draw samples from the prior

#### Usage

    BinomialConjugate$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples from the prior

------------------------------------------------------------------------

### `BinomialConjugate$prior_pdf()`

Prior PDF

#### Usage

    BinomialConjugate$prior_pdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior PDF

------------------------------------------------------------------------

### `BinomialConjugate$prior_cdf()`

Prior CDF

#### Usage

    BinomialConjugate$prior_cdf(target_treatment_effect)

#### Arguments

- `target_treatment_effect`:

  Point at which to evaluate the prior CDF

------------------------------------------------------------------------

### `BinomialConjugate$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinomialConjugate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
