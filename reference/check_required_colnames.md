# Check that a dataframe carries the columns a consumer relies on

Unlike
[`check_colnames()`](https://tristanfauvel.github.io/BExTE/reference/check_colnames.md),
this tolerates additional columns. Use it at the entry point of the
analysis, plot and table layers, which receive frames enriched with
derived columns but read a known subset of them by name.

## Usage

``` r
check_required_colnames(
  df,
  required_colnames,
  types = default_coltypes(required_colnames),
  context = NULL
)
```

## Arguments

- df:

  A dataframe to check.

- required_colnames:

  A character vector of column names that must be present.

- types:

  An optional named character vector of expected types; defaults to the
  entries of
  [expected_coltypes](https://tristanfauvel.github.io/BExTE/reference/expected_coltypes.md)
  describing the required columns.

- context:

  An optional string naming the caller, included in the error so that a
  schema drift points at the consumer that noticed it.

## Value

No return value, called for side effects.
