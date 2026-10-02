# The KL calibration objective

Weighted sum of the divergence from the compatible posterior to
`Beta(c, 1)`, which concentrates near full borrowing, and from the
maximum tolerable discrepancy posterior to `Beta(1, c)`, which
concentrates near no borrowing. The shape parameters are passed on the
log scale so the optimiser works unconstrained in a space where they are
automatically positive.

Any non-finite value is reported as `Inf` rather than propagated, so
that a shape the quadrature cannot handle ends the line search instead
of stopping the run.

## Usage

``` r
npp_kl_objective(
  eta,
  theta_target_compatible,
  theta_target_mtd,
  theta_source,
  se_source,
  se_target_expected,
  lambda_kl,
  c_target,
  n_nodes = 80L
)
```

## Arguments

- eta:

  Length-two numeric vector, `log(a)` and `log(b)`.

- theta_target_compatible:

  Hypothetical estimate under compatibility.

- theta_target_mtd:

  Hypothetical estimate at the maximum tolerable discrepancy.

- theta_source:

  Source treatment effect estimate.

- se_source:

  Standard error of the source estimate.

- se_target_expected:

  Expected standard error of the target estimate.

- lambda_kl:

  Weight on the compatible term.

- c_target:

  Shape of the two reference Beta distributions.

- n_nodes:

  Number of quadrature nodes.

## Value

A single number, possibly `Inf`.
