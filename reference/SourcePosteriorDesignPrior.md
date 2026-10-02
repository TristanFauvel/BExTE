# SourcePosteriorDesignPrior class

A class representing the source posterior design prior for Bayesian
borrowing.

## Super class

[`DesignPrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/DesignPrior.md)
-\> `SourcePosteriorDesignPrior`

## Public fields

- `parameters`:

  Parameters

- `summary_measure_likelihood`:

  Treatment effect distribution

- `n_successes_control`:

  Number of successes in the control arm

- `n_successes_treatment`:

  Number of successes in the treatment arm

- `n_control`:

  Number of participants in the control arm

- `n_treatment`:

  Number of participants in the treatment arm

## Methods

### Public methods

- [`SourcePosteriorDesignPrior$new()`](#method-SourcePosteriorDesignPrior-initialize)

- [`SourcePosteriorDesignPrior$sample()`](#method-SourcePosteriorDesignPrior-sample)

- [`SourcePosteriorDesignPrior$cdf()`](#method-SourcePosteriorDesignPrior-cdf)

- [`SourcePosteriorDesignPrior$given_control_rate()`](#method-SourcePosteriorDesignPrior-given_control_rate)

- [`SourcePosteriorDesignPrior$pdf()`](#method-SourcePosteriorDesignPrior-pdf)

- [`SourcePosteriorDesignPrior$clone()`](#method-SourcePosteriorDesignPrior-clone)

Inherited methods

- [`DesignPrior$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/DesignPrior.html#method-create)

------------------------------------------------------------------------

### `SourcePosteriorDesignPrior$new()`

Initializes a new instance of SourcePosteriorDesignPrior.

#### Usage

    SourcePosteriorDesignPrior$new(
      source_data,
      case_study_config,
      simulation_config,
      mcmc_config = NULL
    )

#### Arguments

- `source_data`:

  The source data object.

- `case_study_config`:

  Case study configuration

- `simulation_config`:

  Simulation configuration

- `mcmc_config`:

  MCMC configuration

------------------------------------------------------------------------

### `SourcePosteriorDesignPrior$sample()`

Samples from the source posterior design prior.

#### Usage

    SourcePosteriorDesignPrior$sample(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `SourcePosteriorDesignPrior$cdf()`

Computes the cumulative distribution function (CDF) of the source
posterior design prior.

#### Usage

    SourcePosteriorDesignPrior$cdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the CDF.

------------------------------------------------------------------------

### `SourcePosteriorDesignPrior$given_control_rate()`

The source posterior given the target control rate

Under a binomial likelihood the source posterior is independent Beta
posteriors on the two arms' response rates, so given the control rate
the effect is the treatment rate, from its source posterior, less that
rate. Otherwise the inherited truncation applies.

#### Usage

    SourcePosteriorDesignPrior$given_control_rate(control_rate)

#### Arguments

- `control_rate`:

  The target control rate.

#### Returns

A
[FunctionalDesignPrior](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/FunctionalDesignPrior.md).

------------------------------------------------------------------------

### `SourcePosteriorDesignPrior$pdf()`

Computes the cumulative distribution function (PDF) of the source
posterior design prior.

#### Usage

    SourcePosteriorDesignPrior$pdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the PDF.

------------------------------------------------------------------------

### `SourcePosteriorDesignPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SourcePosteriorDesignPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
