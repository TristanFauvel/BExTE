# Evaluate an expression under a fixed seed

Restores the caller's random number generator state afterwards, or its
absence, so that nothing drawn here shifts the draws that follow.

## Usage

``` r
with_fixed_seed(seed, code)
```

## Arguments

- seed:

  Seed to draw under.

- code:

  Expression to evaluate.

## Value

The value of `code`.
