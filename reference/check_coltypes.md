# Check the types of a dataframe's columns

Check the types of a dataframe's columns

## Usage

``` r
check_coltypes(df, types, expected_colnames = names(types))
```

## Arguments

- df:

  A dataframe whose columns have already been checked for presence.

- types:

  A named character vector mapping column names to expected types.

- expected_colnames:

  The column names `types` is allowed to mention.

## Value

No return value, called for side effects.
