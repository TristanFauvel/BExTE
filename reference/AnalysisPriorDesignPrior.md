# AnalysisPriorDesignPrior class

A class representing the analysis prior design prior for Bayesian
borrowing.

## Super class

[`DesignPrior`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/DesignPrior.md)
-\> `AnalysisPriorDesignPrior`

## Public fields

- `model`:

  Model used to define the analysis prior

## Methods

### Public methods

- [`AnalysisPriorDesignPrior$new()`](#method-AnalysisPriorDesignPrior-initialize)

- [`AnalysisPriorDesignPrior$sample()`](#method-AnalysisPriorDesignPrior-sample)

- [`AnalysisPriorDesignPrior$given_control_rate()`](#method-AnalysisPriorDesignPrior-given_control_rate)

- [`AnalysisPriorDesignPrior$cdf()`](#method-AnalysisPriorDesignPrior-cdf)

- [`AnalysisPriorDesignPrior$pdf()`](#method-AnalysisPriorDesignPrior-pdf)

- [`AnalysisPriorDesignPrior$clone()`](#method-AnalysisPriorDesignPrior-clone)

Inherited methods

- [`DesignPrior$create()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/DesignPrior.html#method-create)

------------------------------------------------------------------------

### `AnalysisPriorDesignPrior$new()`

Initializes a new instance of AnalysisPriorDesignPrior.

#### Usage

    AnalysisPriorDesignPrior$new(
      model,
      case_study_config,
      simulation_config,
      mcmc_config
    )

#### Arguments

- `model`:

  The model object.

- `case_study_config`:

  Case study configuration

- `simulation_config`:

  Simulation configuration

- `mcmc_config`:

  MCMC configuration

------------------------------------------------------------------------

### `AnalysisPriorDesignPrior$sample()`

Samples from the analysis prior design prior.

#### Usage

    AnalysisPriorDesignPrior$sample(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `AnalysisPriorDesignPrior$given_control_rate()`

The analysis prior given the target control rate

The model's own prior given the control rate when it defines one, as the
binomial models do; otherwise the analysis prior is truncated to the
range the control rate leaves the effect.

#### Usage

    AnalysisPriorDesignPrior$given_control_rate(control_rate)

#### Arguments

- `control_rate`:

  The target control rate.

#### Returns

A
[FunctionalDesignPrior](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/FunctionalDesignPrior.md).

------------------------------------------------------------------------

### `AnalysisPriorDesignPrior$cdf()`

Computes the cumulative distribution function (CDF) of the analysis
prior design prior.

#### Usage

    AnalysisPriorDesignPrior$cdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the CDF.

------------------------------------------------------------------------

### `AnalysisPriorDesignPrior$pdf()`

Computes the PDF of the analysis prior design prior.

#### Usage

    AnalysisPriorDesignPrior$pdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the PDF.

------------------------------------------------------------------------

### `AnalysisPriorDesignPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AnalysisPriorDesignPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
