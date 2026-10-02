# Append a parameter string to a figure or table filename

Joins the two with an underscore, so that a value ending the stem
("sample_size=123") stays separate from the first parameter
("gamma=0.5"). A method without a varied parameter has an empty string,
and gets no trailing underscore.

## Usage

``` r
append_parameters_str(stem, parameters_str)
```

## Arguments

- stem:

  The filename so far.

- parameters_str:

  The output of
  [`convert_params_to_str()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/convert_params_to_str.md).

## Value

The filename with the parameters appended.
