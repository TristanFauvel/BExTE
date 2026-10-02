# Drop the replicates whose summary measure is not estimable

A trial whose summary measure is not estimable - a recurrent-event arm
with no event, or a Cox fit that does not exist - has no p-value. The
Bayesian operating characteristics leave such replicates out of their
denominator (see `Model`), and the simulated frequentist baselines do
the same, so that both are computed on the same trials.

## Usage

``` r
estimable_replicates(samples)
```

## Arguments

- samples:

  Replicates returned by the target data's `generate()`.

## Value

The estimable rows of `samples`.
