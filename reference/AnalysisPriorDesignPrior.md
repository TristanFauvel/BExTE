# AnalysisPriorDesignPrior class

A class representing the analysis prior design prior for Bayesian
borrowing.

## Super class

[`DesignPrior`](https://tristanfauvel.github.io/BExTE/reference/DesignPrior.md)
-\> `AnalysisPriorDesignPrior`

## Public fields

- `model`:

  Model used to define the analysis prior

## Methods

### Public methods

- [`AnalysisPriorDesignPrior$new()`](#method-AnalysisPriorDesignPrior-initialize)

- [`AnalysisPriorDesignPrior$sample()`](#method-AnalysisPriorDesignPrior-sample)

- [`AnalysisPriorDesignPrior$cdf()`](#method-AnalysisPriorDesignPrior-cdf)

- [`AnalysisPriorDesignPrior$pdf()`](#method-AnalysisPriorDesignPrior-pdf)

- [`AnalysisPriorDesignPrior$clone()`](#method-AnalysisPriorDesignPrior-clone)

Inherited methods

- [`DesignPrior$create()`](https://tristanfauvel.github.io/BExTE/reference/DesignPrior.html#method-create)

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
