# The kernel of a pair of discounted source likelihoods, if worth keeping

Returns the stored kernel when there is one; computes and stores it when
the pair has been met often enough (see
[binomial_power_prior_kernel_meetings](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_kernel_meetings.md));
and otherwise records the meeting and returns `NULL`, so that the caller
computes the dataset's density directly. The least recently used kernel
is dropped when the store is full.

## Usage

``` r
binomial_power_prior_cached_kernel(
  source_control,
  source_treatment,
  source_rows
)
```

## Arguments

- source_control, source_treatment:

  Discounted source likelihoods, as passed to
  [`lattice_power_prior_full_kernel()`](https://tristanfauvel.github.io/BExTE/reference/lattice_power_prior_full_kernel.md).

- source_rows:

  Range of the source control rates kept.

## Value

The kernel, or `NULL`.
