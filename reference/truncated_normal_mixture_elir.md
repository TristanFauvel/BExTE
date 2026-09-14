# Expected local information ratio ESS of a truncated normal mixture

The ELIR effective sample size of a prior \\\pi\\ against a normal
likelihood of known scale \\\sigma\\ is \$\$\sigma^2 \\ E\_\pi\[-(\log
\pi)''(\theta)\],\$\$ which is what
[`RBesT::ess()`](https://opensource.nibr.com/RBesT/reference/ess.html)
evaluates for an untruncated normal mixture.

A normal mixture truncated to an interval has no representation as an
untruncated mixture, so the alternative is to fit one to a sample drawn
from it. That costs a mixture fit per replicate and leaves both Monte
Carlo noise and an upward bias in the result. This function integrates
the definition directly instead.

Each component is truncated and renormalised on its own, matching how
the robust mixture prior is drawn from. Inside the interval the
truncation is a constant factor on the density, so it does not
contribute to the second derivative of the log density; it enters only
through the normalisers and the domain of integration.

## Usage

``` r
truncated_normal_mixture_elir(weights, means, sds, lower, upper, sigma)
```

## Arguments

- weights:

  Component weights of the mixture, summing to one.

- means:

  Component means.

- sds:

  Component standard deviations.

- lower:

  Lower truncation point.

- upper:

  Upper truncation point.

- sigma:

  Reference scale of the normal likelihood.

## Value

The ELIR effective sample size.
