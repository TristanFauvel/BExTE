# GaussianNPP_KL class

This class represents a normalised power prior whose `Beta` prior on the
power parameter is calibrated rather than configured.

The ordinary normalised power prior takes the mean and standard
deviation of that prior from the configuration grid, so a run uses the
same prior however precise the target trial is. Whether a given
source/target discrepancy is even distinguishable from noise depends on
the target standard error, so a prior fixed in advance cannot express
"borrow when the two studies agree, stop borrowing at a discrepancy I
would not tolerate". This class states that intention instead, as a
Kullback-Leibler criterion over two hypothetical target estimates, and
solves for the shape parameters it implies - see
[`calibrate_npp_kl()`](https://tristanfauvel.github.io/BExTE/reference/calibrate_npp_kl.md).

Everything downstream of the prior is inherited unchanged: the joint and
marginal posteriors, the quadrature mixture, the summaries and the
effective sample sizes are the ones `GaussianNPP` already computes. Only
where `p` and `q` come from differs.

The calibration reads the design, not the data, so it happens once per
scenario, in
[Model](https://tristanfauvel.github.io/BExTE/reference/Model.md)`$calibrate_for_design()`,
before any replicate is generated. `p` and `q` are left `NULL` until
then: a model analysed before it has been calibrated would otherwise
silently use whatever placeholder stood in for them.

## Super classes

[`Model`](https://tristanfauvel.github.io/BExTE/reference/Model.md) -\>
`GaussianNPP` -\> `GaussianNPP_KL`

## Public fields

- `method`:

  Name of the method

- `theta_0`:

  Boundary of the null hypothesis space

- `null_space`:

  The null hypothesis space, which gives the benefit direction

- `calibration`:

  The result of
  [`calibrate_npp_kl()`](https://tristanfauvel.github.io/BExTE/reference/calibrate_npp_kl.md)
  for this scenario

- `calibration_settings`:

  The criterion settings read from the method parameters

## Methods

### Public methods

- [`GaussianNPP_KL$new()`](#method-GaussianNPP_KL-initialize)

- [`GaussianNPP_KL$calibrate_for_design()`](#method-GaussianNPP_KL-calibrate_for_design)

- [`GaussianNPP_KL$assert_calibrated()`](#method-GaussianNPP_KL-assert_calibrated)

- [`GaussianNPP_KL$vectorised_replicate_inference()`](#method-GaussianNPP_KL-vectorised_replicate_inference)

- [`GaussianNPP_KL$sample_prior()`](#method-GaussianNPP_KL-sample_prior)

- [`GaussianNPP_KL$prior_pdf()`](#method-GaussianNPP_KL-prior_pdf)

- [`GaussianNPP_KL$inference()`](#method-GaussianNPP_KL-inference)

- [`GaussianNPP_KL$clone()`](#method-GaussianNPP_KL-clone)

Inherited methods

- [`Model$check_data()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-check_data)
- [`Model$create()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-create)
- [`Model$empirical_bayes_update()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-empirical_bayes_update)
- [`Model$estimate_bayesian_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_bayesian_operating_characteristics)
- [`Model$estimate_frequentist_operating_characteristics()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-estimate_frequentist_operating_characteristics)
- [`Model$hypothesis_space_transformation()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-hypothesis_space_transformation)
- [`Model$inference_cache_scope()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-inference_cache_scope)
- [`Model$plot_pdfs()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_pdfs)
- [`Model$plot_posterior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_posterior_pdf)
- [`Model$plot_prior_pdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-plot_prior_pdf)
- [`Model$posterior_beta_mixture()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_beta_mixture)
- [`Model$posterior_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_ess)
- [`Model$posterior_mean()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_mean)
- [`Model$posterior_moments()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_moments)
- [`Model$posterior_quantile()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_quantile)
- [`Model$posterior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-posterior_to_RBesT)
- [`Model$print_model_summary()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-print_model_summary)
- [`Model$prior_cdf()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_cdf)
- [`Model$prior_elir_ess()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_elir_ess)
- [`Model$prior_to_RBesT()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-prior_to_RBesT)
- [`Model$simulation_for_given_treatment_effect()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-simulation_for_given_treatment_effect)
- [`Model$test_decision()`](https://tristanfauvel.github.io/BExTE/reference/Model.html#method-test_decision)
- `GaussianNPP$credible_interval()`
- `GaussianNPP$normalizing_constant_power_parameter()`
- `GaussianNPP$plot_power_parameter_posterior_pdf()`
- `GaussianNPP$plot_power_parameter_vs_drift()`
- `GaussianNPP$posterior_cdf()`
- `GaussianNPP$posterior_median()`
- `GaussianNPP$posterior_pdf()`
- `GaussianNPP$power_parameter_posterior_pdf()`
- `GaussianNPP$sample_posterior()`
- `GaussianNPP$summary_rows()`
- `GaussianNPP$unnormalized_posterior_power_parameter_pdf()`

------------------------------------------------------------------------

### `GaussianNPP_KL$new()`

Initialize a new GaussianNPP_KL object.

#### Usage

    GaussianNPP_KL$new(prior, theta_0, null_space)

#### Arguments

- `prior`:

  Prior object containing method parameters.

- `theta_0`:

  Value of the treatment effect under the null hypothesis.

- `null_space`:

  The null hypothesis space, either "left" or "right".

#### Returns

A new GaussianNPP_KL object.

------------------------------------------------------------------------

### `GaussianNPP_KL$calibrate_for_design()`

Calibrate the prior on the power parameter to this design; see
[`npp_kl_calibrate_design()`](https://tristanfauvel.github.io/BExTE/reference/npp_kl_calibrate_design.md).
For a binary endpoint the expected target standard error is taken at
zero treatment drift, so that the prior does not depend on the
scenario's true treatment effect.

#### Usage

    GaussianNPP_KL$calibrate_for_design(target_data)

#### Arguments

- `target_data`:

  Target study data for the scenario.

#### Returns

The calibration, invisibly.

------------------------------------------------------------------------

### `GaussianNPP_KL$assert_calibrated()`

Stop unless the prior has been calibrated.

#### Usage

    GaussianNPP_KL$assert_calibrated()

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `GaussianNPP_KL$vectorised_replicate_inference()`

Run every replicate at once

The parent's fast path, widened by the calibration columns. They are
constant within a scenario, and are reported per replicate because the
reporting layer averages every posterior parameter over the replicates.

#### Usage

    GaussianNPP_KL$vectorised_replicate_inference(
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

A list of simulation results.

------------------------------------------------------------------------

### `GaussianNPP_KL$sample_prior()`

Sample from the prior on the treatment effect.

The prior is what the calibration chooses, so reaching for it before the
design has been seen is the same mistake as running inference early. It
is worth catching separately because this is the door the design priors
and the effective sample sizes come in through, and the shape parameters
being absent surfaces there as `rbeta`'s "invalid arguments" rather than
as anything that names the cause.

#### Usage

    GaussianNPP_KL$sample_prior(n_samples)

#### Arguments

- `n_samples`:

  Number of samples to draw.

#### Returns

A vector of samples from the prior.

------------------------------------------------------------------------

### `GaussianNPP_KL$prior_pdf()`

Density of the prior on the treatment effect.

#### Usage

    GaussianNPP_KL$prior_pdf(x)

#### Arguments

- `x`:

  Values at which to evaluate the density.

#### Returns

The prior density at `x`.

------------------------------------------------------------------------

### `GaussianNPP_KL$inference()`

Perform inference on the target data.

The scalar path, which the vignette and the reference tests use, reports
the same columns as the vectorised one so that the two can be compared.

#### Usage

    GaussianNPP_KL$inference(target_data)

#### Arguments

- `target_data`:

  Target study data.

#### Returns

A string indicating the success status of the inference.

------------------------------------------------------------------------

### `GaussianNPP_KL$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GaussianNPP_KL$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
