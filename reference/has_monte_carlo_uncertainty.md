# Whether a pair of bound columns carries Monte Carlo uncertainty

The power baselines are estimated one of two ways. A closed-form power
has no Monte Carlo error, and the compute_freq_power() family reports
that as a degenerate interval, `c(power, power)`. Drawing those bounds
would put a zero-height error bar - a bare cap tick - through every
marker, so a plot asks this first and adds the layer only when the
bounds say something.

## Usage

``` r
has_monte_carlo_uncertainty(data, lower, upper)
```

## Arguments

- data:

  The dataframe backing the layer.

- lower, upper:

  Names of the bound columns, or `NULL`.

## Value

`TRUE` when both columns are present and some row spans a non-zero
width, `FALSE` otherwise.

## Details

Bound columns missing from `data` count as no uncertainty: results
written before the bounds were recorded still have to plot.
