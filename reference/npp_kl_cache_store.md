# Cache of KL calibrations

The calibration depends on the design - the source estimate and its
standard error, the expected target standard error, the null boundary,
and the four criterion settings - and on nothing that varies between
replicates. Scenarios that share those inputs therefore share an answer,
and a simulation sweeps many of them: on a continuous endpoint the whole
drift axis collapses onto a single calibration.

The store lives in the package rather than on a model because a model is
built afresh for each scenario, the same reason
[inference_cache_store](https://tristanfauvel.github.io/BExTE/reference/inference_cache_store.md)
does.

## Usage

``` r
npp_kl_cache_store
```
