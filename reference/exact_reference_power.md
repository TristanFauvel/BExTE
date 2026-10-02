# Exact power of the reference test at an exact type I error

The most powerful use of a test statistic at a given size rejects every
outcome below a threshold and, on a discrete sample space, a fraction of
the outcomes at it. The threshold `c` and the fraction `gamma` are
chosen on the null scenario's enumerated outcomes so that the rejected
probability there is exactly `alpha`, and the power is the probability
the same randomised test rejects in the scenario of interest. Without
randomisation a binary endpoint's test could only reach a few levels,
and could not be matched to an arbitrary type I error.

## Usage

``` r
exact_reference_power(
  alpha,
  alternative_support,
  null_support,
  theta_0,
  alternative
)
```

## Arguments

- alpha:

  The type I error to match, in `[0, 1]`.

- alternative_support, null_support:

  Enumerated outcomes of the scenario of interest and of its null
  scenario, from `enumerate_support()`.

- theta_0:

  Boundary of the null hypothesis space.

- alternative:

  "greater" or "less".

## Value

The power, one value per element of `alpha`.
