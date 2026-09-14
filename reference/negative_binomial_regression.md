# Estimate rate and standard error

This function estimates the rate parameter of an intercept-only negative
binomial model and its standard error.

## Usage

``` r
negative_binomial_regression(input_data)
```

## Arguments

- input_data:

  The data for which the rate parameter and standard error need to be
  estimated.

## Value

A list containing the rate estimate, standard error of the rate
estimate, and standard error of the log(rate) estimate.
