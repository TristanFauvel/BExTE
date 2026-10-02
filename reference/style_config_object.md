# Resolve a configuration object the plot code keeps in the global environment

conf/methods_plots_config.R and the run's methods configuration assign
with `<<-`, so the plot code reads them as free variables the way it
already reads `font`, `dpi` and `textwidth`. Returning NULL rather than
erroring lets the style helpers be called with an explicit table in
tests, where no configuration has been loaded.

## Usage

``` r
style_config_object(name)
```

## Arguments

- name:

  The object to look up.

## Value

The object, or NULL when no configuration has been loaded.
