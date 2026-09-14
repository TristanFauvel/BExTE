# Two-sample t-test from summary statistics, across replicates

Vectorised equivalent of
[`BSDA::tsum.test()`](https://alanarnholt.github.io/BSDA/reference/tsum.test.html)
with unequal variances, which the empirical Bayes power priors and the
test-then-pool methods call once per replicate. `x` is the source study,
whose summary statistics are fixed; `y` is the target study, which
varies by replicate.

## Usage

``` r
summary_t_test_p_value(
  mean_x,
  sd_x,
  n_x,
  mean_y,
  sd_y,
  n_y,
  mu = 0,
  alternative = "two.sided"
)
```

## Arguments

- mean_x, sd_x, n_x:

  Mean, standard deviation and per-arm sample size of the first sample.

- mean_y, sd_y, n_y:

  Mean, standard deviation and per-arm sample size of the second sample.
  `mean_y` and `sd_y` may be vectors.

- mu:

  Difference in means under the null hypothesis.

- alternative:

  One of `"two.sided"`, `"less"` or `"greater"`.

## Value

Vector of p-values.
