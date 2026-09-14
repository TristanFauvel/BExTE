# Columns every consumer of a results frame relies on

The identity columns that the analysis, plot and table layers read by
name from whichever results frame they are handed. `drift` is
deliberately absent: the Bayesian operating-characteristics frame does
not carry it, and these columns must hold for both.

## Usage

``` r
required_colnames_consumer
```
