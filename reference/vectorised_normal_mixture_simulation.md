# Run a whole normal-mixture simulation without looping over replicates

Shared implementation behind the vectorised fast path. Given the prior
mixture for every replicate, this reproduces exactly what the replicate
loop would have produced: posterior moments, medians, credible
intervals, test decisions and effective sample sizes.

## Usage

``` r
vectorised_normal_mixture_simulation(
  weights,
  means,
  sds,
  samples,
  target_data,
  to_return,
  critical_value,
  theta_0,
  confidence_level,
  null_space,
  posterior_parameters = NULL,
  posterior = NULL,
  mcmc = FALSE
)
```

## Arguments

- weights:

  Prior component weights, shared across replicates (a vector) or one
  row per replicate (a matrix).

- means:

  Prior component means, shaped like `weights`.

- sds:

  Prior component standard deviations, shaped like `weights`.

- samples:

  Data frame of generated replicates, with columns
  `treatment_effect_estimate`, `treatment_effect_standard_error` and
  `standard_deviation`.

- target_data:

  Target data object, used for its sample size per arm.

- to_return:

  Character vector of requested outputs.

- critical_value:

  Critical value for the test decision.

- theta_0:

  Null hypothesis value.

- confidence_level:

  Credible interval level.

- null_space:

  Either `"left"` or `"right"`.

- posterior_parameters:

  Optional data frame of per-replicate posterior parameters to report.

- posterior:

  Optional output from
  [`normal_mixture_posterior()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/normal_mixture_posterior.md)
  when the caller already needed it for method-specific parameter
  summaries.

- mcmc:

  Whether the calling model samples when it is not on this fast path,
  which decides what the MCMC diagnostics report.

## Value

A list shaped like the return value of
`Model$simulation_for_given_treatment_effect()`.
