# Draw from the posterior of a binomial proportion

Draws from the Jeffreys posterior `Beta(x + 1/2, n - x + 1/2)` implied
by observing `estimate * n_replicates` successes in `n_replicates`
replicates.

This replaces approximating an exact binomial interval by a symmetric
normal and discarding the draws that fall outside `(0, 1)`. The
posterior is supported on `(0, 1)` by construction, so no draw is ever
discarded, and it retains the skewness that the normal approximation
removes – which matters most for the small type I errors these
comparisons are made at.

## Usage

``` r
sample_binomial_proportion(n_samples, estimate, n_replicates)
```

## Arguments

- n_samples:

  Number of draws to return.

- estimate:

  The estimated proportion.

- n_replicates:

  The number of replicates the estimate is based on.

## Value

A numeric vector of `n_samples` draws in `(0, 1)`.
