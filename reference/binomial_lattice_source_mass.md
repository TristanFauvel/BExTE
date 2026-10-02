# Initial prior mass of each pair of source rates on the lattice

The uniform initial prior of the binomial power prior, summed over the
target control rates that leave the risk difference admissible: entry
(i, s) is the mass of the source control rate r_i and the source
treatment rate r_s. It depends on the lattice alone, so it is computed
once per worker.

## Usage

``` r
binomial_lattice_source_mass(n_lattice)
```

## Arguments

- n_lattice:

  Number of lattice points N.

## Value

An N x N matrix.
