# A grid posterior as distribution functions

A grid posterior as distribution functions

## Usage

``` r
grid_distribution(posterior)
```

## Arguments

- posterior:

  Output of
  [`grid_posterior()`](https://tristanfauvel.github.io/BExTE/reference/grid_posterior.md).

## Value

A list of three functions of the treatment effect: `cdf`, `pdf`, and
`sample`, which takes the number of draws.
