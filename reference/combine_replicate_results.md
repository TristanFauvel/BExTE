# Concatenate the results of consecutive chunks of replicates

Concatenate the results of consecutive chunks of replicates

## Usage

``` r
combine_replicate_results(pieces)
```

## Arguments

- pieces:

  List of results, as
  [`vectorised_normal_mixture_simulation()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/vectorised_normal_mixture_simulation.md)
  returns them, for consecutive chunks of replicates.

## Value

One such list over every replicate: vectors are concatenated, and
matrices and data frames bound by rows. Outputs that were not requested
stay `NULL`.
