# Fisher information of a centred normal scale mixture

All components of the power-prior mixtures have the same mean. In that
case the expected Fisher information can be integrated directly as
`integral p(x) score(x)^2 dx`. This avoids constructing three panels per
component and turns the ELIR calculation for a thousand-component
quadrature mixture from quadratic work into a single adaptive integral.

## Usage

``` r
centered_normal_mixture_information(weights, sds)
```

## Arguments

- weights:

  Component weights.

- sds:

  Component standard deviations.

## Value

Expected Fisher information for unit reference scale.
