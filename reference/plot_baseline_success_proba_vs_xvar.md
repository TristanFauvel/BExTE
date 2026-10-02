# Add a reference probability of success to a metric-vs-x-variable plot

Draws the baseline as points, optionally joined by a line. When
`selected_metric_uncertainty_lower`/`_upper` name columns that carry a
non-degenerate interval, the baseline also gets error bars.

The bounds are only informative where the power was approximated by
Monte Carlo:
[`compute_freq_power()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/compute_freq_power.md)
returns an exact binomial interval when it simulates, but a degenerate
`c(power, power)` when it has a closed form. Handing those degenerate
bounds to `geom_errorbar()` would draw a zero-height bar - a bare cap
tick - through every marker, so they are left off. Results that predate
the bound columns are treated the same way, which keeps their figures
rendering.

## Usage

``` r
plot_baseline_success_proba_vs_xvar(
  plt,
  data,
  xvar_name,
  selected_metric_name,
  cap_size,
  markersize,
  join_points,
  label = NULL,
  selected_metric_uncertainty_lower = NULL,
  selected_metric_uncertainty_upper = NULL
)
```

## Arguments

- plt:

  The plot to add the baseline to.

- data:

  The dataframe holding the baseline.

- xvar_name:

  Name of the x-axis variable.

- selected_metric_name:

  Name of the column holding the baseline.

- cap_size:

  Width of the error bar caps.

- markersize:

  Size of the points.

- join_points:

  Whether to join the points with a line.

- label:

  Legend label for the baseline.

- selected_metric_uncertainty_lower:

  Name of the column holding the lower confidence bound, or `NULL` for
  no error bars.

- selected_metric_uncertainty_upper:

  Name of the column holding the upper confidence bound, or `NULL` for
  no error bars.

## Value

The plot, with the baseline added.
