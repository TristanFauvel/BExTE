# Remove the compiled Stan models

The models are compiled on first use and cached in
`stan_model_directory()`. Clearing the cache forces the next run to
recompile them, which is what `inst/scripts/main.R` does when its
`delete_stan_files` switch is set.

## Usage

``` r
clear_stan_model_cache(directory = stan_model_directory())
```

## Arguments

- directory:

  Directory holding the cached models.

## Value

Paths of the files that were removed, invisibly.
