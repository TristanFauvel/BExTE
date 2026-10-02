# Quadrature rule for an expectation over a Beta-distributed power parameter

Integrates on the logit scale, gamma = plogis(t), where the integrand is
the Beta density times gamma (1 - gamma). That is smooth and decays
exponentially in both tails whatever the shapes, including the U-shaped
priors whose density is unbounded at 0 and 1, so the trapezoidal rule
converges geometrically. The mass beyond the end points is put on gamma
= 0 and gamma = 1, where the integrands used here are flat to well below
the rule's accuracy.

## Usage

``` r
npp_gamma_rule(p, q, t_limit = 30, t_step = 0.05)
```

## Arguments

- p, q:

  Shape parameters of the Beta prior.

- t_limit:

  Half-width of the logit range.

- t_step:

  Spacing on the logit scale.

## Value

A list with `nodes` in 0, 1 and `weights` summing to one.
