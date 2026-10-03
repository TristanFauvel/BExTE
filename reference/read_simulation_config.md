# Read `simulation_config.yml` and validate it

Checks the configuration against
[simulation_config_schema](https://tristanfauvel.github.io/BExTE/reference/simulation_config_schema.md),
then with
[`check_decision_threshold()`](https://tristanfauvel.github.io/BExTE/reference/check_decision_threshold.md).

## Usage

``` r
read_simulation_config(path)
```

## Arguments

- path:

  Path to the YAML file.

## Value

The parsed configuration.
