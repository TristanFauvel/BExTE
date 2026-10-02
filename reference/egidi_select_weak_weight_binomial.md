# Select the weak-component weight from a pair of response counts

The binomial counterpart of
[`egidi_select_weak_weight()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/egidi_select_weak_weight.md).
The component tables are fixed, so the scan is over candidate weights
alone.

## Usage

``` r
egidi_select_weak_weight_binomial(
  table_informative,
  table_weak,
  y_control,
  y_treatment,
  alpha_pc = 0.05,
  weight_grid_step = 0.001,
  tolerance = 1e-09
)
```

## Arguments

- table_informative, table_weak:

  Component tables.

- y_control, y_treatment:

  Observed responder counts.

- alpha_pc:

  Conflict threshold.

- weight_grid_step:

  Resolution of the weight scan.

- tolerance:

  Relative tolerance for comparing probabilities.

## Value

A one-row data frame shaped like
[`egidi_select_weak_weight()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/egidi_select_weak_weight.md)'s.

## Details

As in the normal case both ends are evaluated first and decide the
common cases, and the scan runs upwards for the first crossing because
the conflict p-value need not be monotone in the weight. The p-value is
a step function of the weight here, since the conflict set can only
change when a cell crosses the observed cell's probability, so the
crossing is reported at the grid resolution rather than refined further.
