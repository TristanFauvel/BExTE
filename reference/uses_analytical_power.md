# Whether power can be computed analytically for this target data

The analytical power formulas apply to a normal summary measure on a
continuous endpoint; the remaining endpoints have to be simulated.
Sharing the predicate keeps the power computation and the propagation of
its uncertainty on the same branch.

Recurrent events are simulated too. Mepolizumab used to be priced in
closed form, but its trials are generated patient by patient from a
negative binomial and the standard error is re-estimated in each one, so
the closed form assumed a test the Bayesian methods were never compared
against.

## Usage

``` r
uses_analytical_power(target_data)
```

## Arguments

- target_data:

  Target data object.

## Value

`TRUE` when power has a closed form for this target data.
