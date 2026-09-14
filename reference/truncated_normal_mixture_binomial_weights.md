# Posterior component weights of a truncated normal mixture under a two-arm binomial likelihood

The robust mixture prior for a binary endpoint puts a normal mixture on
the treatment effect, each component truncated to the range the control
rate leaves it, and observes two binomial arms: \$\$p_c \sim U(0, 1),
\quad \theta \mid p_c, k \sim N(\mu_k, \sigma_k^2) \text{ on } (-p_c,
1-p_c),\$\$ \$\$y_c \sim Bin(n_c, p_c), \quad y_t \sim Bin(n_t, p_c +
\theta).\$\$ This returns \\P(k \mid y_c, y_t)\\, the probability that
the treatment effect came from each component, which is the posterior
counterpart of the prior weight `w`.

## Usage

``` r
truncated_normal_mixture_binomial_weights(
  weights,
  means,
  sds,
  n_control,
  n_successes_control,
  n_treatment,
  n_successes_treatment
)
```

## Arguments

- weights:

  Prior component weights of the mixture, summing to one.

- means:

  Component means.

- sds:

  Component standard deviations.

- n_control:

  Size of the control arm.

- n_successes_control:

  Number of responders in the control arm.

- n_treatment:

  Size of the treatment arm.

- n_successes_treatment:

  Number of responders in the treatment arm.

## Value

The posterior component probabilities, in the order the components were
given. `NA` for every component when the data underflow the marginal
likelihood of all of them, which leaves the weights undefined rather
than zero.

## Details

The truncation ties the two integrals together, so unlike the normal
case there is no closed form and no separable marginal likelihood: the
component marginal likelihood is the double integral \$\$\int_0^1
Bin(y_c \mid n_c, p_c) \frac{\int_0^1 Bin(y_t \mid n_t, p_t) N(p_t - p_c
\mid \mu_k, \sigma_k^2) dp_t} {\Phi(1 - p_c \mid \mu_k, \sigma_k^2) -
\Phi(-p_c \mid \mu_k, \sigma_k^2)} dp_c,\$\$ where substituting the
treatment rate \\p_t = p_c + \theta\\ for the treatment effect has put
the inner integral on \\(0, 1)\\ whatever the control rate is. Both
integrals are taken by Simpson's rule on the same grid, which makes the
inner one a discrete convolution: the normal density is evaluated once
per grid offset rather than once per pair of nodes.

Evaluating the prior density at the observed treatment effect estimate
would be neither of the two integrals, and is not a component
probability.
