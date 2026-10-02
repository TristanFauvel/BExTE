# The methods whose parameters nest under a heterogeneity prior

The commensurate power prior and the plain commensurate prior both take
their `heterogeneity_prior` as a nested list of a family and its
hyperparameters, rather than as a scalar. That shape is what the figure
and table code has to special-case, so it is what this names - the two
methods differ in whether they also carry a power parameter, which is
irrelevant everywhere this predicate is used.

## Usage

``` r
COMMENSURATE_METHODS
```
