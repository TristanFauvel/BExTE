# Validate a configuration read from YAML

YAML enters the package as an untyped nested list, so a typo in a key or
a value of the wrong shape otherwise surfaces as a `NULL` propagating
into arithmetic far from the file that caused it. This checks a config
against a schema at the point it is read, so the error names the file,
the key and what was expected.

## Usage

``` r
validate_config(config, schema, context)
```

## Arguments

- config:

  The list returned by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- schema:

  A named list mapping keys to a type in
  [config_type_predicates](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/config_type_predicates.md).
  Keys absent from the schema are not checked.

- context:

  The name of the configuration file, used in the error.

## Value

No return value, called for side effects.
