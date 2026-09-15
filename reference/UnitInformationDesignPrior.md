# UnitInformationDesignPrior class

A class representing the unit information design prior for Bayesian
borrowing.

## Super class

[`DesignPrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/DesignPrior.md)
-\> `UnitInformationDesignPrior`

## Public fields

- `parameters`:

  Parameters for the prior

- `summary_measure_likelihood`:

  Treatment effect distribution

## Methods

### Public methods

- [`UnitInformationDesignPrior$new()`](#method-UnitInformationDesignPrior-initialize)

- [`UnitInformationDesignPrior$sample()`](#method-UnitInformationDesignPrior-sample)

- [`UnitInformationDesignPrior$cdf()`](#method-UnitInformationDesignPrior-cdf)

- [`UnitInformationDesignPrior$pdf()`](#method-UnitInformationDesignPrior-pdf)

- [`UnitInformationDesignPrior$clone()`](#method-UnitInformationDesignPrior-clone)

Inherited methods

- [`DesignPrior$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/DesignPrior.html#method-create)

------------------------------------------------------------------------

### `UnitInformationDesignPrior$new()`

Initializes a new instance of UnitInformationDesignPrior.

#### Usage

    UnitInformationDesignPrior$new(
      source_data,
      case_study_config,
      case_study,
      simulation_config,
      mcmc_config = NULL
    )

#### Arguments

- `source_data`:

  The source data object.

- `case_study_config`:

  Case study configuration.

- `case_study`:

  Case study name

- `simulation_config`:

  Simulation config

- `mcmc_config`:

  MCMC configuration

------------------------------------------------------------------------

### `UnitInformationDesignPrior$sample()`

Samples from the unit information design prior.

#### Usage

    UnitInformationDesignPrior$sample(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `UnitInformationDesignPrior$cdf()`

Computes the cumulative distribution function (CDF) of the unit
information design prior.

#### Usage

    UnitInformationDesignPrior$cdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the CDF.

------------------------------------------------------------------------

### `UnitInformationDesignPrior$pdf()`

Computes the cumulative distribution function (CDF) of the unit
information design prior.

#### Usage

    UnitInformationDesignPrior$pdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the CDF.

------------------------------------------------------------------------

### `UnitInformationDesignPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    UnitInformationDesignPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
