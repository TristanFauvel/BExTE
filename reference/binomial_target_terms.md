# Target terms of the binomial power prior, kept between analyses if asked

The N x K matrix `T(i, k) = sum_j w(i - j) c_j t_{j+k}` of
[`binomial_power_prior_target_terms()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_target_terms.md).
It depends on the target data alone, so every power prior analysis of
the same dataset - at another power parameter, under another
configuration of the p-value-based power prior, under the empirical
Bayes power prior - can read its density off it with
[`lattice_power_prior_density_from_terms()`](https://tristanfauvel.github.io/BExTE/reference/lattice_power_prior_density_from_terms.md),
at a fraction of the cost of computing it.

With the option `BExTE.target_terms_cache` set to a positive number,
that many are kept per process, 8 to 16 MB each at N = 1000. This pays
when several analyses of each dataset follow one another, as when a
driver runs every configuration on a chunk of datasets before moving to
the next chunk. The option is 0, keeping none, by default.

## Usage

``` r
binomial_target_terms(
  target_control,
  target_treatment,
  control_rows,
  differences
)
```

## Arguments

- target_control:

  Target control likelihood, zero off the target control rates kept.

- target_treatment:

  Target treatment likelihood.

- control_rows:

  Range of the target control rates kept.

- differences:

  Risk differences, consecutive, in lattice units.

## Value

The N x `length(differences)` matrix T.
