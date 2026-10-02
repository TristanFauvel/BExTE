# The interval columns of an exactly computed result

An enumerated operating characteristic has no Monte Carlo error, so each
of its `conf_int_<metric>_lower`/`_upper` pairs (and each
`conf_int_lower_<parameter>`/`conf_int_upper_<parameter>` pair of the
posterior parameters) collapses onto the point estimate, and its Monte
Carlo standard error is zero. Plots already hide error bars of zero
width.

## Usage

``` r
collapse_monte_carlo_intervals(result)
```

## Arguments

- result:

  The list `estimate_frequentist_operating_characteristics()` returns.

## Value

The same list with its intervals collapsed.
