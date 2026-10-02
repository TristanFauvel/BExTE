# Target standard error a design implies, for the KL calibration

The standard error of the target estimate expected under the design, on
the scale of the analysis. For a continuous, recurrent-event or
time-to-event endpoint it is the design's sampling standard deviation
over the root sample size per arm, which does not depend on the
treatment effect. For a binary endpoint the standard error depends on
the response rates, so taking it at the scenario's true rates would make
the prior a function of the true treatment effect. It is taken instead
at the design's control rate and the source treatment rate, i.e. at zero
treatment drift, which is also the design the analysis step calibrates
on (see `compute_bayesian_ocs()`).

## Usage

``` r
npp_kl_expected_target_se(target_data, source)
```

## Arguments

- target_data:

  Target study data for the scenario.

- source:

  The source data, with `treatment_rate` for a binary endpoint.

## Value

The expected standard error.
