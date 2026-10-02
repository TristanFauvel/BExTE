# Event counts from observed response rates

Recovers the whole number of responders behind a rate that was computed
as `count / n`. `(count / n) * n` often lands just below `count` in
floating point (7 / 71 \* 71 is 6.9999...), so truncating it with
[`as.integer()`](https://rdrr.io/r/base/integer.html) silently loses an
event; the product is rounded instead. A rate that is not a count
divided by `n` is an error rather than a silently rounded surrogate.

## Usage

``` r
counts_from_rate(rate, n)
```

## Arguments

- rate:

  Numeric vector of response rates.

- n:

  Numeric vector of sample sizes, recycled against `rate`.

## Value

An integer vector of event counts.
