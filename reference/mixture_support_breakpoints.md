# Integration breakpoints covering every component's own scale

A mixture whose components differ widely in scale cannot be integrated
on a single grid: a rule fine enough for the broad component steps
straight over the narrow one. Splitting the range at each component's
centre and tails gives every component at least one panel matched to its
own width.

## Usage

``` r
mixture_support_breakpoints(means, sds, spread = 9)
```

## Arguments

- means:

  `n_replicates x n_components` matrix of component means.

- sds:

  `n_replicates x n_components` matrix of component standard deviations.

- spread:

  How many standard deviations each component should reach.

## Value

A `n_replicates x (3 * n_components)` matrix of breakpoints, sorted
within each row. Repeated values give empty panels, which contribute
nothing.
