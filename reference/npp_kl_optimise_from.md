# One run of the calibration optimiser

Factored out of
[`calibrate_npp_kl()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/calibrate_npp_kl.md)
so that a single starting value can be exercised, and made to fail, on
its own.

L-BFGS-B works on the log shapes inside the log of the configured
bounds, which is why the bounds are guaranteed to hold exactly rather
than approximately. It is deterministic, so two calibrations with the
same inputs return the same answer.

## Usage

``` r
npp_kl_optimise_from(start, objective, beta_parameter_bounds)
```

## Arguments

- start:

  Length-two numeric vector of starting shape parameters, on the natural
  scale.

- objective:

  A function of `eta`, as
  [`npp_kl_objective()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/npp_kl_objective.md).

- beta_parameter_bounds:

  Bounds on the shape parameters.

## Value

A list with `alpha_gamma`, `beta_gamma`, `objective_value`, `converged`
and `message`. A start the optimiser cannot use at all is reported as
not converged with an infinite objective rather than raised.
