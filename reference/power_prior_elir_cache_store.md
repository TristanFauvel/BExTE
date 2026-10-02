# Cache of power prior ELIRs

The ELIR effective sample size of a prior is read off a normal mixture
fitted to draws from it. The binomial p-value based power prior changes
from one replicate to the next only through its power parameter, so
rather than drawing from the prior and fitting a mixture for every
replicate, the ELIR is tabulated on a grid of power parameters and
interpolated between its nodes.

A single fit's ELIR varies by about five per cent from one set of draws
to the next, which refitting every replicate averaged away over the
replicates. A node is therefore the mean over several fits instead, and
each node is drawn under a fixed seed. That makes a node a function of
its inputs alone, so the nodes can be shared between the scenarios a
worker runs whatever order it runs them in, and filling them leaves the
caller's random number stream untouched.

The store lives in the package rather than on a model because a model is
built afresh for each scenario, the same reason
[inference_cache_store](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/inference_cache_store.md)
does.

## Usage

``` r
power_prior_elir_cache_store
```
