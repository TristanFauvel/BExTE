# Benefit direction implied by the null space

A case study records which direction of the treatment effect is
beneficial only through `null_space`: `"left"` means the null hypothesis
is the half line below `theta_0`, so the trial succeeds when the effect
is large, and `"right"` is its mirror. The maximum tolerable discrepancy
has to be taken on the side that moves the target towards the null, so
it needs that direction as a sign. The same mapping is written as an
alternative hypothesis by `alternative_from_null_space()`.

## Usage

``` r
benefit_sign_from_null_space(null_space)
```

## Arguments

- null_space:

  Either `"left"` or `"right"`.

## Value

`1` when larger treatment effects are beneficial, `-1` otherwise.
