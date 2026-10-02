# The numeric parameter ranges a method's configuration declares

Mirrors the selection
[`make_labels_from_parameters()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/make_labels_from_parameters.md)
makes, so the ranges line up with the numbers that end up in the labels:
a parameter is shown when it says so through `display`, or when its
range holds more than one value. Non-numeric ranges are skipped - a
categorical parameter has no ramp to sit on.

## Usage

``` r
style_numeric_ranges(key, dict)
```

## Arguments

- key:

  The method key.

- dict:

  The run's methods configuration.

## Value

A list of numeric vectors, in configuration order.
