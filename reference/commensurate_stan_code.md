# Stan program for the commensurate prior, with or without a power parameter

The two commensurate methods fit the same model up to one term. The
commensurate power prior of Hobbs et al. (2011) samples a power
parameter `gamma ~ Beta(g(tau), 1)` alongside the commensurability
precision; the plain commensurate prior is its `gamma == 1` case, in
which every product `gamma * NS` collapses to `NS` and the Beta
statement and `g_function` fall away. Holding both programs here keeps
that relationship visible.

The `data` block is deliberately identical in the two, so a single
`prepare_data()` serves both classes; Stan accepts data a program does
not read. `test-commensurate-stan-model.R` checks that the two blocks
have not drifted apart.

## Usage

``` r
commensurate_stan_code(with_power_parameter)
```

## Arguments

- with_power_parameter:

  Whether the program samples the power parameter.

## Value

The Stan program, as a single string.
