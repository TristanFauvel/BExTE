# Kullback-Leibler divergence from a discretised posterior to a Beta reference

Computes \\\int_0^1 p(\gamma)\[\log p(\gamma) - \log q(\gamma)\]
d\gamma\\ with `p` the hypothetical posterior and `q` one of the two
reference Beta distributions. The integral is taken in the direction
written here, not the reverse one: it penalises posterior mass placed
where the reference has little, which is what "the posterior should look
like full borrowing" means.

Quadrature enters through the posterior masses rather than through a
separate set of weights, because those masses already carry the rule.

## Usage

``` r
npp_kl_divergence(posterior, reference_shape1, reference_shape2)
```

## Arguments

- posterior:

  A list from
  [`npp_kl_posterior_masses()`](https://tristanfauvel.github.io/BExTE/reference/npp_kl_posterior_masses.md).

- reference_shape1:

  First shape parameter of the reference Beta.

- reference_shape2:

  Second shape parameter of the reference Beta.

## Value

A single number, or `Inf` when the integrand is not finite anywhere the
posterior puts mass.
