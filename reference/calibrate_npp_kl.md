# Calibrate the normalised power prior by a KL criterion

Chooses the `Beta(a, b)` prior on the discounting parameter of the
normalised power prior so that the prior is informative about *when* to
borrow rather than about *how much*. Two hypothetical target estimates
stand for the two situations the prior has to tell apart:

- compatibility:

  the target estimate falls exactly on the source estimate, and the
  discounting parameter should concentrate near one;

- maximum tolerable discrepancy:

  the target estimate falls `d_mtd` away from it, towards the null, and
  the discounting parameter should concentrate near zero.

Writing \\p_0\\ and \\p\_{MTD}\\ for the marginal posteriors of the
discounting parameter these two imply, the calibration minimises
\$\$K(a, b) = \lambda \\ \mathrm{KL}\[p_0 \\ \mathrm{Beta}(c, 1)\] +
(1 - \lambda) \\ \mathrm{KL}\[p\_{MTD} \\ \mathrm{Beta}(1, c)\].\$\$

Both hypothetical posteriors are formed from the *expected* target
standard error, the one the design implies, not from any realised
estimate. The calibration therefore belongs to the scenario and is
computed once for it, before any replicate is generated; every replicate
of that scenario is then analysed under the same prior, and only the
target estimate and its standard error vary between them.

## Usage

``` r
calibrate_npp_kl(
  theta_source,
  se_source,
  se_target_expected,
  theta_null = 0,
  benefit_sign = 1,
  d_mtd = NULL,
  d_mtd_multiplier = 1,
  lambda_kl = 0.5,
  c_target = 10,
  beta_parameter_bounds = NPP_KL_DEFAULT_BOUNDS,
  optimizer_starts = NPP_KL_DEFAULT_STARTS,
  n_nodes = 80L
)
```

## Arguments

- theta_source:

  Source treatment effect estimate.

- se_source:

  Standard error of the source estimate. Must be positive.

- se_target_expected:

  Standard error the target design implies for its treatment effect
  estimate. Must be positive.

- theta_null:

  Boundary of the null hypothesis space, the `theta_0` of the case
  study.

- benefit_sign:

  `1` when larger treatment effects are beneficial, `-1` when smaller
  ones are.
  [`benefit_sign_from_null_space()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/benefit_sign_from_null_space.md)
  derives it from a case study's `null_space`.

- d_mtd:

  Maximum tolerable discrepancy. `NULL`, the default, applies the rule
  `d_mtd_multiplier * abs(theta_source - theta_null)`; a number
  overrides that rule, and `d_mtd_multiplier` is then not applied.

- d_mtd_multiplier:

  Multiplier used by the default rule.

- lambda_kl:

  Weight on the compatible term, in `[0, 1]`.

- c_target:

  Shape of the two reference Beta distributions. Must exceed one.

- beta_parameter_bounds:

  Bounds on the calibrated shape parameters.

- optimizer_starts:

  List of length-two starting values, on the natural scale. The search
  keeps the converged answer with the smallest objective.

- n_nodes:

  Number of Gauss-Jacobi nodes used for every integral.

## Value

A list with the calibrated `alpha_gamma` and `beta_gamma`, the
`objective_value` they attain, `optimizer_converged` and
`optimizer_message`, the two hypothetical estimates
`theta_target_compatible` and `theta_target_mtd`, the `d_mtd`,
`d_mtd_multiplier`, `lambda_kl`, `c_target` and `se_target_expected`
used, and a `calibration_id` identifying the calibration unit.
