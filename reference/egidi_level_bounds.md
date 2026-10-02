# Outer bounds of the region where a two-component normal mixture exceeds a level

The conflict p-value integrates the predictive mixture over the set
where its density is at or below the density at the observed statistic.
That set is the complement of a bounded region, and this returns an
interval containing it.

## Usage

``` r
egidi_level_bounds(level, weights, means, sds)
```

## Arguments

- level:

  The density level, one per replicate.

- weights:

  A list of the two component weights.

- means:

  A list of the two component means.

- sds:

  A list of the two component standard deviations.

## Value

A list with `lower` and `upper`, each one value per replicate.

## Details

A component whose weighted density never reaches `level / 2` cannot on
its own carry the mixture above `level`, so halving the level makes the
bound valid for the sum rather than for either term: outside the
returned interval both components sit below `level / 2` and the mixture
below `level`.
