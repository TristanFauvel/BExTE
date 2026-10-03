# Time To Event Target Data

This class represents target data for time-to-event analysis. It
inherits from the TargetData class.

The target trial follows the modified fixed-calendar design: patients
enter uniformly over an accrual window, each may be followed for at most
`max_follow_up_time`, and the database closes `final_follow_up` after
the end of recruitment. See `R/simulation_time_to_event.R` for the
generator and the Cox fit.

## Super class

[`TargetData`](https://tristanfauvel.github.io/BExTE/reference/TargetData.md)
-\> `TimeToEventTargetData`

## Public fields

- `control_rate`:

  Rate in the control arm of the target study

- `treatment_rate`:

  Rate in the treatment arm of the target study

- `max_follow_up_time`:

  Maximum individual follow-up time, L

- `accrual_period`:

  Length of the recruitment window, A

- `final_follow_up`:

  Time from the end of recruitment to database closure, F

- `dropout_probability`:

  Probability of loss to follow-up over the maximum follow-up time

- `event_time_distribution`:

  Either "exponential" or "weibull"

- `weibull_shape`:

  Common Weibull shape parameter, q

- `weibull_scale`:

  Control-arm Weibull scale, calibrated to the reported relapse-free
  probability

- `treatment_delay`:

  Time before the treatment effect starts, in years; 0 for proportional
  hazards

- `late_log_hr`:

  Log hazard ratio once the effect has started, chosen so that the Cox
  model's large-sample limit equals the treatment effect

## Methods

### Public methods

- [`TimeToEventTargetData$new()`](#method-TimeToEventTargetData-initialize)

- [`TimeToEventTargetData$dropout_rate()`](#method-TimeToEventTargetData-dropout_rate)

- [`TimeToEventTargetData$arm_parameters()`](#method-TimeToEventTargetData-arm_parameters)

- [`TimeToEventTargetData$generate()`](#method-TimeToEventTargetData-generate)

- [`TimeToEventTargetData$to_dict()`](#method-TimeToEventTargetData-to_dict)

- [`TimeToEventTargetData$clone()`](#method-TimeToEventTargetData-clone)

Inherited methods

- [`TargetData$plot_sample()`](https://tristanfauvel.github.io/BExTE/reference/TargetData.html#method-plot_sample)

------------------------------------------------------------------------

### `TimeToEventTargetData$new()`

Initialize the TimeToEventTargetData object

#### Usage

    TimeToEventTargetData$new(
      source_data,
      sampling_approximation,
      target_sample_size_per_arm,
      control_drift = 0,
      treatment_drift,
      summary_measure_likelihood,
      max_follow_up_time,
      accrual_period = NULL,
      final_follow_up = NULL,
      weibull_shape = NULL,
      weibull_relapse_free_probability = NULL,
      dropout_probability = 0,
      event_time_distribution = "exponential",
      treatment_delay = 0
    )

#### Arguments

- `source_data`:

  The source data used for generating the target data.

- `sampling_approximation`:

  A flag indicating whether to use sampling approximation.

- `target_sample_size_per_arm`:

  The target sample size per arm.

- `control_drift`:

  The control drift.

- `treatment_drift`:

  The treatment drift.

- `summary_measure_likelihood`:

  The summary measure distribution.

- `max_follow_up_time`:

  The maximum individual follow-up time.

- `accrual_period`:

  The length of the recruitment window.

- `final_follow_up`:

  The time between the end of recruitment and database closure.

- `weibull_shape`:

  The common Weibull shape parameter.

- `weibull_relapse_free_probability`:

  The control-arm relapse-free probability at the maximum follow-up
  time, used to calibrate the Weibull scale.

- `dropout_probability`:

  The probability of loss to follow-up over the maximum follow-up time.

- `event_time_distribution`:

  Either "exponential" or "weibull".

- `treatment_delay`:

  Time before the treatment effect starts, in years. Zero, the default,
  is the proportional-hazards design.

------------------------------------------------------------------------

### `TimeToEventTargetData$dropout_rate()`

The loss-to-follow-up rate implied by the dropout probability.

#### Usage

    TimeToEventTargetData$dropout_rate()

#### Returns

A single number, zero when there is no loss to follow-up.

------------------------------------------------------------------------

### `TimeToEventTargetData$arm_parameters()`

The event-time parameters of each arm: rates under the exponential
model, scales under the Weibull model.

#### Usage

    TimeToEventTargetData$arm_parameters()

#### Returns

A list with elements `control` and `treatment`. Generate target data

------------------------------------------------------------------------

### `TimeToEventTargetData$generate()`

This function generates target data based on the specified parameters.

#### Usage

    TimeToEventTargetData$generate(n_replicates)

#### Arguments

- `n_replicates`:

  The number of replicates to generate.

#### Returns

A data frame containing the generated target data.

------------------------------------------------------------------------

### `TimeToEventTargetData$to_dict()`

Converts the target data object to a dictionary.

#### Usage

    TimeToEventTargetData$to_dict()

#### Returns

A list representing the target data object.

------------------------------------------------------------------------

### `TimeToEventTargetData$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeToEventTargetData$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
