# DesignPrior Class

A class representing the design prior for Bayesian borrowing.

## Public fields

- `design_prior_type`:

  Type of design prior.

- `RBesT_model`:

  RBesT version of the model.

## Methods

### Public methods

- [`DesignPrior$create()`](#method-DesignPrior-create)

- [`DesignPrior$given_control_rate()`](#method-DesignPrior-given_control_rate)

- [`DesignPrior$sample()`](#method-DesignPrior-sample)

- [`DesignPrior$cdf()`](#method-DesignPrior-cdf)

- [`DesignPrior$pdf()`](#method-DesignPrior-pdf)

- [`DesignPrior$clone()`](#method-DesignPrior-clone)

------------------------------------------------------------------------

### `DesignPrior$create()`

Creates a new instance of DesignPrior.

#### Usage

    DesignPrior$create(
      design_prior_type,
      model,
      source_data,
      case_study_config,
      simulation_config,
      mcmc_config,
      case_study,
      target_control_rate = NULL
    )

#### Arguments

- `design_prior_type`:

  The type of design prior.

- `model`:

  The model object.

- `source_data`:

  The source data object.

- `case_study_config`:

  Case study configuration

- `simulation_config`:

  Simulation configuration

- `mcmc_config`:

  MCMC configuration

- `case_study`:

  Case study name

- `target_control_rate`:

  The control response rate of the simulated trials, or `NULL`. Under a
  binomial likelihood the treatment effect is a difference in response
  rates, and the simulated trials, whose control rate is fixed, can only
  have an effect in `(-target_control_rate, 1 - target_control_rate)`;
  the design prior is then taken given that control rate - see
  `given_control_rate()`.

#### Returns

A new instance of DesignPrior.

------------------------------------------------------------------------

### `DesignPrior$given_control_rate()`

The design prior given the target control rate

A difference in response rates is confined to
`(-control_rate, 1 - control_rate)` once the control rate is known. A
design prior defined on the treatment effect alone has no joint
distribution with the control rate to condition, so it is truncated to
that range and renormalised. Subclasses that can condition exactly
override this.

#### Usage

    DesignPrior$given_control_rate(control_rate)

#### Arguments

- `control_rate`:

  The target control rate.

#### Returns

A
[FunctionalDesignPrior](https://tristanfauvel.github.io/BExTE/reference/FunctionalDesignPrior.md).

------------------------------------------------------------------------

### `DesignPrior$sample()`

Samples from the design prior.

#### Usage

    DesignPrior$sample(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `DesignPrior$cdf()`

Computes the cumulative distribution function (CDF) of the design prior.

#### Usage

    DesignPrior$cdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the CDF.

------------------------------------------------------------------------

### `DesignPrior$pdf()`

Computes the PDF of the design prior.

#### Usage

    DesignPrior$pdf(x)

#### Arguments

- `x`:

  The value at which to evaluate the PDF.

------------------------------------------------------------------------

### `DesignPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DesignPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
