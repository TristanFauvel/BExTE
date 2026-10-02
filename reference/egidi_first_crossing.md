# First candidate weight at which the conflict criterion is met

Scans a grid upwards and returns, for each replicate, the interval in
which the criterion is first satisfied.

## Usage

``` r
egidi_first_crossing(
  lower,
  upper,
  steps,
  evaluate,
  alpha_pc,
  lower_value = rep(NA_real_, length(lower)),
  upper_value = rep(NA_real_, length(lower))
)
```

## Arguments

- lower, upper:

  Per-replicate ends of the interval to scan.

- steps:

  Number of equal steps the interval is cut into.

- evaluate:

  Function of a candidate weight and the row indices it belongs to,
  returning the conflict p-value.

- alpha_pc:

  Conflict threshold.

- lower_value, upper_value:

  The conflict p-value at `lower` and `upper`, which are carried to the
  ends of the bracket so that refining it needs no further evaluation
  there. `NA` when unknown.

## Value

A list with the bracketing `lower` and `upper` weights, and the conflict
p-values there as `lower_value` and `upper_value`.

## Details

The scan runs upwards and stops at the first crossing rather than
searching the whole interval, because the quantity wanted is an infimum.
A bisection over \\\[0, 1\]\\ would be wrong here: the conflict p-value
is not monotone in the weight when the components have different
centres, and it can fall before it rises when the observed statistic
sits near the informative component's centre.

Replicates leave the scan as they resolve, so later steps are evaluated
only for those still looking.
