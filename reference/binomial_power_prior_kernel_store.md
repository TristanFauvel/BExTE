# Store of binomial power prior kernels, by discounted source likelihoods

`entries` holds up to
[`binomial_power_prior_kernel_limit()`](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_kernel_limit.md)
full kernels, most recently used last, and `seen` how many times each
pair of discounted source likelihoods was met. A kernel is computed on
the
[binomial_power_prior_kernel_meetings](https://tristanfauvel.github.io/BExTE/reference/binomial_power_prior_kernel_meetings.md)-th
meeting: it costs about as much as one to three datasets computed
directly.

## Usage

``` r
binomial_power_prior_kernel_store
```
