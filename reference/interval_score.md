# Interval score of a credible interval

The interval score (Winkler 1972; Gneiting and Raftery 2007) combines
the width of an interval estimate with the penalty it incurs when the
true value falls outside it, so that an interval narrowed by shifting it
away from the truth scores worse than the wider interval it replaced.
The width and the coverage read on their own leave that trade-off
ambiguous; the score resolves it into one number.

For a central interval `[lower, upper]` at level `confidence_level`, and
writing `a = 1 - confidence_level`, one replicate scores

\$\$(u - l) + \frac{2}{a}(l - y)\mathbf{1}\\y \< l\\ + \frac{2}{a}(y -
u)\mathbf{1}\\y \> u\\\$\$

A replicate whose interval covers the true value scores the full width
of that interval. That is the full width, not the half width the
`precision` operating characteristic reports, so the two are not on the
same scale. Smaller is better.

## Usage

``` r
interval_score(lower, upper, true_value, confidence_level = 0.95)
```

## Arguments

- lower:

  Lower bounds of the intervals, one per replicate.

- upper:

  Upper bounds of the intervals, one per replicate.

- true_value:

  The value the intervals are estimating. Either a single value shared
  by every replicate, or one value per replicate.

- confidence_level:

  The level of the intervals, which sets the rate
  `2 / (1 - confidence_level)` at which a miss is penalised.

## Value

A numeric vector of scores, one per replicate. `NA` bounds propagate to
`NA` scores, and empty input gives `numeric(0)`.

## References

Winkler, R. L. (1972). A decision-theoretic approach to interval
estimation. Journal of the American Statistical Association, 67(337),
187-191.

Gneiting, T. and Raftery, A. E. (2007). Strictly proper scoring rules,
prediction, and estimation. Journal of the American Statistical
Association, 102(477), 359-378, equation 43.
