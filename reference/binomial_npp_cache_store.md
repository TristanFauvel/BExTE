# Store of binomial normalized power prior kernels, one per source and prior

A kernel takes a few seconds to compute and depends only on the source
counts, the prior of the power parameter and the lattice, so it is
shared by every scenario a worker runs, for the same reason as
[inference_cache_store](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/inference_cache_store.md).

## Usage

``` r
binomial_npp_cache_store
```
