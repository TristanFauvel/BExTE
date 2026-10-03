# FunctionalDesignPrior class

A design prior given by its distribution functions, as the design priors
conditioned on the target control rate are.

## Super class

[`DesignPrior`](https://tristanfauvel.github.io/BExTE/reference/DesignPrior.md)
-\> `FunctionalDesignPrior`

## Public fields

- `cdf_function`:

  Distribution function of the treatment effect.

- `pdf_function`:

  Density of the treatment effect.

- `sample_function`:

  Function of the number of draws returning draws.

## Methods

### Public methods

- [`FunctionalDesignPrior$new()`](#method-FunctionalDesignPrior-initialize)

- [`FunctionalDesignPrior$sample()`](#method-FunctionalDesignPrior-sample)

- [`FunctionalDesignPrior$cdf()`](#method-FunctionalDesignPrior-cdf)

- [`FunctionalDesignPrior$pdf()`](#method-FunctionalDesignPrior-pdf)

- [`FunctionalDesignPrior$clone()`](#method-FunctionalDesignPrior-clone)

Inherited methods

- [`DesignPrior$create()`](https://tristanfauvel.github.io/BExTE/reference/DesignPrior.html#method-create)
- [`DesignPrior$given_control_rate()`](https://tristanfauvel.github.io/BExTE/reference/DesignPrior.html#method-given_control_rate)

------------------------------------------------------------------------

### `FunctionalDesignPrior$new()`

Creates a design prior from its distribution functions.

#### Usage

    FunctionalDesignPrior$new(cdf, pdf, sample, design_prior_type)

#### Arguments

- `cdf, pdf, sample`:

  The distribution function, density and sampler.

- `design_prior_type`:

  The type of design prior it stands for.

------------------------------------------------------------------------

### `FunctionalDesignPrior$sample()`

Samples from the design prior.

#### Usage

    FunctionalDesignPrior$sample(n_samples)

#### Arguments

- `n_samples`:

  The number of samples to generate.

------------------------------------------------------------------------

### `FunctionalDesignPrior$cdf()`

The distribution function of the design prior.

#### Usage

    FunctionalDesignPrior$cdf(x)

#### Arguments

- `x`:

  The value at which to evaluate it.

------------------------------------------------------------------------

### `FunctionalDesignPrior$pdf()`

The density of the design prior.

#### Usage

    FunctionalDesignPrior$pdf(x)

#### Arguments

- `x`:

  The value at which to evaluate it.

------------------------------------------------------------------------

### `FunctionalDesignPrior$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FunctionalDesignPrior$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
