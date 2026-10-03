# Number of power prior kernels kept per process

Each is an N x (2N - 1) matrix, 16 MB at N = 1000. Set by the option
`BExTE.power_prior_kernels`, 4 by default; 0 turns the cache off.

## Usage

``` r
binomial_power_prior_kernel_limit()
```

## Value

The number of kernels.
