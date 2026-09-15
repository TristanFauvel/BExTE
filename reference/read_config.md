# Read a YAML configuration and validate it against a schema

Read a YAML configuration and validate it against a schema

## Usage

``` r
read_config(path, schema)
```

## Arguments

- path:

  Path to the YAML file.

- schema:

  The schema to validate against, as taken by
  [`validate_config()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/validate_config.md).

## Value

The parsed configuration.
