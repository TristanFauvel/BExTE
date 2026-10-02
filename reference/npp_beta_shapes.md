# Beta shape parameters from a mean and a standard deviation

The parametrisation of the prior of the power parameter used by the
normalized power prior. Shapes within numerical noise of one are set to
one, where the Beta density changes behaviour at the boundaries.

## Usage

``` r
npp_beta_shapes(mean, std)
```

## Arguments

- mean:

  Mean, in (0, 1).

- std:

  Standard deviation, in (0, sqrt(mean (1 - mean))).

## Value

A list with `p` and `q`.
