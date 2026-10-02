# BinaryTargetData class

A class for binary target data objects.

## Super class

[`TargetData`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TargetData.md)
-\> `BinaryTargetData`

## Public fields

- `control_rate`:

  Rate in the control arm of the target study

- `treatment_rate`:

  Rate in the treatment arm of the target study

## Methods

### Public methods

- [`BinaryTargetData$new()`](#method-BinaryTargetData-initialize)

- [`BinaryTargetData$generate()`](#method-BinaryTargetData-generate)

- [`BinaryTargetData$samples_from_counts()`](#method-BinaryTargetData-samples_from_counts)

- [`BinaryTargetData$enumerate_support()`](#method-BinaryTargetData-enumerate_support)

- [`BinaryTargetData$to_dict()`](#method-BinaryTargetData-to_dict)

- [`BinaryTargetData$clone()`](#method-BinaryTargetData-clone)

Inherited methods

- [`TargetData$plot_sample()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/TargetData.html#method-plot_sample)

------------------------------------------------------------------------

### `BinaryTargetData$new()`

Initializes the binary target data object.

#### Usage

    BinaryTargetData$new(
      source_data,
      sampling_approximation,
      target_sample_size_per_arm,
      control_drift,
      treatment_drift,
      summary_measure_likelihood
    )

#### Arguments

- `source_data`:

  The source data object.

- `sampling_approximation`:

  The sampling approximation flag.

- `target_sample_size_per_arm`:

  The target sample size per arm.

- `control_drift`:

  The control drift.

- `treatment_drift`:

  The treatment drift.

- `summary_measure_likelihood`:

  The summary measure distribution.

------------------------------------------------------------------------

### `BinaryTargetData$generate()`

Generates samples for the binary target data object.

#### Usage

    BinaryTargetData$generate(n_replicates)

#### Arguments

- `n_replicates`:

  The number of replicates to generate.

#### Returns

A data frame containing the generated samples.

------------------------------------------------------------------------

### `BinaryTargetData$samples_from_counts()`

The replicate rows a trial with the given responder counts is analysed
from. `generate()` draws the counts and `enumerate_support()` lists
them, and both build their rows here, so the two cannot disagree on what
a trial looks like to the analysis.

#### Usage

    BinaryTargetData$samples_from_counts(
      n_control_responders,
      n_treatment_responders
    )

#### Arguments

- `n_control_responders`:

  Integer vector of control-arm responders.

- `n_treatment_responders`:

  Integer vector of treatment-arm responders, the same length.

#### Returns

A data frame with one row per pair of counts.

------------------------------------------------------------------------

### `BinaryTargetData$enumerate_support()`

Every trial outcome with non-negligible probability, with its
probability, so that an operating characteristic can be computed as an
exact weighted sum over trials instead of a Monte Carlo average. Each
arm's responder count is kept between its `tail_mass / 4` and
`1 - tail_mass / 4` binomial quantiles, so at most `tail_mass` is left
out across both arms, and the weights, the product of the two binomial
probabilities, are renormalised over the pairs kept.

#### Usage

    BinaryTargetData$enumerate_support(tail_mass = 1e-10)

#### Arguments

- `tail_mass`:

  Upper bound on the probability of the trials left out.

#### Returns

A list: `samples`, the replicate rows as `generate()` builds them;
`weights`, their probabilities, summing to 1; and `omitted_mass`, the
probability of the trials left out.

------------------------------------------------------------------------

### `BinaryTargetData$to_dict()`

Converts the target data object to a dictionary.

#### Usage

    BinaryTargetData$to_dict()

#### Returns

A list representing the target data object.

------------------------------------------------------------------------

### `BinaryTargetData$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BinaryTargetData$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
