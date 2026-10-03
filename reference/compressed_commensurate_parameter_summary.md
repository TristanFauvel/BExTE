# Borrowing-parameter summaries from a compressed commensurate mixture

The compressed counterpart of
[`commensurate_parameter_summary()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_parameter_summary.md):
each posterior moment is the integral of the marginal likelihood against
its own compressed rule, divided by the same integral against the main
one.

## Usage

``` r
compressed_commensurate_parameter_summary(compressed, estimate, standard_error)
```

## Arguments

- compressed:

  Output from
  [`compress_commensurate_mixture()`](https://tristanfauvel.github.io/BExTE/reference/compress_commensurate_mixture.md).

- estimate:

  Treatment effect estimates.

- standard_error:

  Their standard errors.

## Value

A data frame shaped like the output of
[`commensurate_parameter_summary()`](https://tristanfauvel.github.io/BExTE/reference/commensurate_parameter_summary.md).
