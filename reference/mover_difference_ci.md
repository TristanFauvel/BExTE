# Confidence interval for a difference, by variance estimate recovery

Combines two separate intervals into an interval for the difference of
the two estimates, following Newcombe's MOVER (Method of Variance
Estimates Recovery) approach.

Subtracting only the comparator's point estimate leaves an interval
exactly as wide as the first estimate's, which understates the
uncertainty of the difference. MOVER recovers a variance from each
interval at the bound that matters for the corresponding bound of the
difference, so the result keeps the asymmetry of exact binomial
intervals instead of symmetrising them.

## Usage

``` r
mover_difference_ci(
  estimate_1,
  lower_1,
  upper_1,
  estimate_2,
  lower_2,
  upper_2,
  correlation = 0
)
```

## Arguments

- estimate_1, lower_1, upper_1:

  Estimate and interval bounds of the first quantity.

- estimate_2, lower_2, upper_2:

  Estimate and interval bounds of the second quantity, which is
  subtracted from the first.

- correlation:

  Correlation between the two estimates. Defaults to `0`, which assumes
  them independent; a positive value narrows the interval.

## Value

A named numeric vector with the `lower` and `upper` bounds of the
interval for `estimate_1 - estimate_2`, or `NA` bounds when any input is
missing.
