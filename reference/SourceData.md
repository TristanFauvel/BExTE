# SourceData class

This class represents the source data used for Bayesian borrowing. It
processes the source data to compute necessary statistics for various
endpoints.

## Super class

[`ObservedSourceData`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/ObservedSourceData.md)
-\> `SourceData`

## Methods

### Public methods

- [`SourceData$new()`](#method-SourceData-initialize)

- [`SourceData$clone()`](#method-SourceData-clone)

Inherited methods

- [`ObservedSourceData$to_dict()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/ObservedSourceData.html#method-to_dict)

------------------------------------------------------------------------

### `SourceData$new()`

Initialize the SourceData object

#### Usage

    SourceData$new(case_study_config, source_denominator = NA)

#### Arguments

- `case_study_config`:

  list: A configuration list containing details of the case study.

- `source_denominator`:

  numeric: An optional denominator for computing control rates.

#### Returns

A new SourceData object.

------------------------------------------------------------------------

### `SourceData$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SourceData$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
