# TargetDataFactory class

A factory class for creating different types of target data objects.

## Methods

### Public methods

- [`TargetDataFactory$create()`](#method-TargetDataFactory-create)

- [`TargetDataFactory$clone()`](#method-TargetDataFactory-clone)

------------------------------------------------------------------------

### `TargetDataFactory$create()`

Creates a target data object based on the source data and configuration.

#### Usage

    TargetDataFactory$create(
      source_data,
      case_study_config,
      target_sample_size_per_arm,
      control_drift = 0,
      treatment_drift,
      summary_measure_likelihood,
      target_to_source_std_ratio = NULL,
      dropout_probability = 0,
      event_time_distribution = "exponential",
      treatment_delay = 0
    )

#### Arguments

- `source_data`:

  The source data object.

- `case_study_config`:

  The case study configuration object.

- `target_sample_size_per_arm`:

  The target sample size per arm.

- `control_drift`:

  The control drift.

- `treatment_drift`:

  The treatment drift.

- `summary_measure_likelihood`:

  The summary measure distribution.

- `target_to_source_std_ratio`:

  Ratio between the target and source study sampling standard deviation

- `dropout_probability`:

  Probability that a patient is lost to follow-up over the maximum
  follow-up time. Only used for the time-to-event endpoint.

- `event_time_distribution`:

  Distribution of the event times, either "exponential" or "weibull".
  Only used for the time-to-event endpoint.

- `treatment_delay`:

  Time before the treatment effect starts, in years. Only used for the
  time-to-event endpoint.

#### Returns

The created target data object.

------------------------------------------------------------------------

### `TargetDataFactory$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TargetDataFactory$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
