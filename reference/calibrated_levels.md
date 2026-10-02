# Thresholds at which a test's actual type I error equals given levels

For each level `alpha`, the p-value threshold `c` such that the share of
the null p-values strictly below `c` is `floor(alpha * N) / N`, within
`1 / N` of `alpha`. A test rejecting when its p-value is below `c` then
has the actual rejection rate `alpha` in the null scenario, whatever its
nominal level there. Null p-values tied at the threshold all stay
unrejected, so the rate never exceeds `alpha`.

## Usage

``` r
calibrated_levels(alpha, null_p_values)
```

## Arguments

- alpha:

  Levels, in `[0, 1]`.

- null_p_values:

  The test's p-values on the null scenario's trials.

## Value

One threshold per level; `Inf` rejects every trial.
