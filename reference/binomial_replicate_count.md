# Recover the number of Monte Carlo replicates behind a binomial estimate

Operating characteristics are stored as summaries (estimate, Monte Carlo
standard error, exact confidence interval) rather than as the underlying
counts. Propagating their uncertainty correctly requires the replicate
count, which this function recovers from whichever summary is
informative.

The Monte Carlo standard error identifies the replicate count exactly
whenever it is available and non-zero. It is zero precisely when no
replicate succeeded or all of them did, and in that case one bound of
the exact interval is a closed-form function of the replicate count
alone. As a last resort, when no standard error was stored for an
interior estimate, the count is approximated from the width of the
interval.

## Usage

``` r
binomial_replicate_count(
  estimate,
  mcse,
  conf_int_lower,
  conf_int_upper,
  conf_level = 0.95
)
```

## Arguments

- estimate:

  The estimated proportion.

- mcse:

  The Monte Carlo standard error of the estimate, or `NA`.

- conf_int_lower:

  Lower bound of the exact (Clopper-Pearson) interval.

- conf_int_upper:

  Upper bound of the exact (Clopper-Pearson) interval.

- conf_level:

  The confidence level the interval was computed at.

## Value

The number of replicates, or `NA_real_` when no summary identifies it.
