# Read `simulation_config.yml` and validate it

Checks the configuration against
[simulation_config_schema](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/simulation_config_schema.md),
then with
[`check_decision_threshold()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/check_decision_threshold.md).

## Usage

``` r
read_simulation_config(path)
```

## Arguments

- path:

  Path to the YAML file.

## Value

The parsed configuration.
