# Probability of study success over the replicates actually analysed

`simulation_for_given_treatment_effect()` drops replicates whose summary
measure is not estimable before analysing them, and marks those whose
fit failed. Its vectorised path then returns one decision per analysed
replicate, and its replicate loop returns one per simulated replicate
with the unanalysed slots left at zero. Averaging the decisions as
returned therefore either fails to fit a row sized for every replicate
or counts the unanalysed ones as failures. Only the successful fits are
averaged here, as the frequentist operating characteristics do.

## Usage

``` r
analysed_success_probability(results)
```

## Arguments

- results:

  The list returned by `simulation_for_given_treatment_effect()` with
  `test_decision` and `fit_success` requested.

## Value

The proportion of successful fits that led to study success, or `NA`
when none succeeded.
