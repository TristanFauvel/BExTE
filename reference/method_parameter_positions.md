# Where each parameter label sits on its method's ramp

Anchored on the range the configuration declares rather than on the
values one figure happens to show. A figure plotting w in 0.1, 0.5, 0.9
and one plotting all nine weights put w = 0.5 at the same place, and so
give it the same shade; ranking the values present would not.

Labels carrying no recoverable number - categorical parameters - fall
back to sorted order, which is at least reproducible between runs.

## Usage

``` r
method_parameter_positions(key, parameter_labels, dict)
```

## Arguments

- key:

  The method key.

- parameter_labels:

  The labels to place, as plain text.

- dict:

  The run's methods configuration.

## Value

A numeric vector of positions in \\\[0, 1\]\\.
