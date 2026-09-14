# Two-sample z-test from summary statistics, across replicates

Vectorised equivalent of
[`BSDA::zsum.test()`](https://alanarnholt.github.io/BSDA/reference/zsum.test.html).

## Usage

``` r
summary_z_test_p_value(
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

  Mean, known standard deviation and per-arm sample size of the first
  sample.

- mean_y, sd_y, n_y:

  Mean, known standard deviation and per-arm sample size of the second
  sample. `mean_y` and `sd_y` may be vectors.

- mu:

  Difference in means under the null hypothesis.

- alternative:

  One of `"two.sided"`, `"less"` or `"greater"`.

## Value

Vector of p-values.
