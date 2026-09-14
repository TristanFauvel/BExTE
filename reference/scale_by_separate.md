# Express a metric as a ratio to the separate analysis

Divides each row's metric by the value the `separate` (no borrowing)
method takes in the same scenario. The scenario key is the full set of
coordinates that identify a simulated configuration, so the ratio never
collapses across drift or sample size.

A zero or missing denominator makes the ratio undefined. Those rows are
dropped with a warning rather than reported as `Inf` or as some finite
stand-in.

## Usage

``` r
scale_by_separate(df, metric_columns)
```

## Arguments

- df:

  A frequentist results frame containing `separate` method rows.

- metric_columns:

  Character vector of columns to divide - typically the metric and its
  two confidence bounds.

## Value

`df` with `metric_columns` divided by the separate analysis's value, in
the original column order.
