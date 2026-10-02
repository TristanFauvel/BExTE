# The two components of the binomial robust mixture prior

The two components of the binomial robust mixture prior

## Usage

``` r
binomial_rmp_components(source_counts, n_lattice = 1000L)
```

## Arguments

- source_counts:

  List of the four source counts.

- n_lattice:

  Number of lattice points N.

## Value

A list with `n_lattice`, `rates`, `differences`, and the N x (2N - 1)
kernels `informative` and `weak`, each summing to one.
