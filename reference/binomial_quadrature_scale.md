# Quadrature resolution demanded by a binomial arm

The narrowest feature of a binomial likelihood in the rate is its
standard error, except when every subject or no subject responded, where
the likelihood is monotone and its scale is set by the sample size
instead. An empty arm constrains nothing.

## Usage

``` r
binomial_quadrature_scale(n, successes)
```

## Arguments

- n:

  Arm size.

- successes:

  Number of responders in the arm.

## Value

The scale to resolve, or `Inf` for an empty arm.
