# Generate a comparison table

This function generates a comparison table for different methods and
treatment effects.

## Usage

``` r
generate_comparison_table(
  results_df,
  x_metric,
  source_denominator_change_factor,
  target_to_source_std_ratio
)
```

## Arguments

- results_df:

  A dataframe containing the results to be compared.

- x_metric:

  The metric to be used for comparison.

- source_denominator_change_factor:

  The source denominator change factor of the scenario to keep.

- target_to_source_std_ratio:

  Ratio between the target and source studies sampling standard
  deviation.

## Value

A kable object representing the comparison table.
