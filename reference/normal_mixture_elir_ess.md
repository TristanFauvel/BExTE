# ELIR effective sample size of a normal mixture, per replicate

Vectorised equivalent of `RBesT::ess(mix, method = "elir")`. The ELIR
effective sample size is \\\sigma^2 \int p(\theta) \\ i(\theta) \\
d\theta\\, where \\i(\theta) = -\partial^2\_\theta \log p(\theta)\\ is
the Fisher information of the prior.

RBesT evaluates that integral with Gauss-Hermite quadrature centred on
each mixture component, doubling the node count until successive
estimates agree and falling back to adaptive quadrature if they never
do. That fallback is the usual outcome for a robust mixture prior, whose
informative and vague components differ in scale by a factor of around
twenty: nodes spaced for the vague component step over the sharp peak
the informative one puts in \\i(\theta)\\, so the estimate never
settles.

This function instead integrates \\p\\i\\ directly, over panels split at
every component's centre and tails, with Gauss-Legendre quadrature on
each panel. Every component then gets panels matched to its own width,
whatever the spread of scales, and the result agrees with RBesT to
around 1e-10 while running on all replicates at once.

Two cases short-circuit the quadrature entirely. A single-component
mixture has constant Fisher information, so its ELIR is exactly
\\\sigma^2/\mathrm{variance}\\. A prior shared by every replicate is
integrated once and rescaled, since ELIR is proportional to
\\\sigma^2\\.

## Usage

``` r
normal_mixture_elir_ess(weights, means, sds, sigma, n_nodes = 40L, spread = 9)
```

## Arguments

- weights:

  Mixture weights: a vector when the prior is shared by every replicate,
  or a `n_replicates x n_components` matrix.

- means:

  Component means, shaped like `weights`.

- sds:

  Component standard deviations, shaped like `weights`.

- sigma:

  Reference scale, either a single value or one value per replicate.

- n_nodes:

  Number of Gauss-Legendre nodes per panel.

- spread:

  How many standard deviations each component's panels reach.

## Value

Vector of ELIR effective sample sizes, one per replicate.
