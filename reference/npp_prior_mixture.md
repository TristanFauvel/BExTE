# Discretise the normalised power prior as a normal mixture

The normalised power prior places a `Beta(p, q)` prior on the power
parameter, which makes the prior on the treatment effect a continuous
mixture of normals, \$\$p(\theta) = \int_0^1 N(\theta; \hat\theta_S,
\sigma_S^2/\gamma) \\ \mathrm{Beta}(\gamma; p, q) \\ d\gamma.\$\$
Replacing that integral by a quadrature rule turns the method into an
ordinary finite normal mixture, after which the conjugate update, the
posterior summaries and the effective sample sizes all follow from the
shared normal-mixture code. The nested numerical integration in
`posterior_pdf()` and `posterior_cdf()` is then unnecessary.

The rule substitutes \\\gamma = u^2\\ before applying Gauss-Jacobi
quadrature. Gauss-Jacobi handles the `Beta` density's endpoint
singularities exactly, which matter because the configured settings
include shape parameters below one; the substitution removes a
square-root term in the remaining factor that would otherwise slow
convergence. Together they reach machine precision at a few dozen nodes
for every configured setting.

The prior does not depend on the replicate, so this is computed once per
simulation rather than once per replicate.

## Usage

``` r
npp_prior_mixture(model, n_nodes = 60L)
```

## Arguments

- model:

  A `Gaussian_NPP` object.

- n_nodes:

  Number of quadrature nodes.

## Value

A list with `weights`, `means` and `sds` describing the prior mixture,
and `power_parameter`, the quadrature nodes themselves, which are the
power parameter values each component corresponds to.
