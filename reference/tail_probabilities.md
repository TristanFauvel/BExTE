# Convert test statistics to p-values for a given alternative

Convert test statistics to p-values for a given alternative

## Usage

``` r
tail_probabilities(statistic, alternative, distribution)
```

## Arguments

- statistic:

  Vector of test statistics.

- alternative:

  One of `"two.sided"`, `"less"` or `"greater"`.

- distribution:

  Function of `(q, lower)` giving the null distribution.

## Value

Vector of p-values.
