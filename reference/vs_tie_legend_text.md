# Function to generate an operating characteristic vs tie plot

Function to generate an operating characteristic vs tie plot

## Usage

``` r
vs_tie_legend_text(grob)
```

## Arguments

- results_metrics_df:

  The dataframe containing the results and metrics

- case_study:

  The case study name

- target_sample_size_per_arm:

  The target sample size per arm

- treatment_effect:

  The treatment effect type ("consistent", "no_effect",
  "partially_consistent")

- operating_characteristic:

  The operating characteristic to plot (e.g., "power", "type_1_error")

- power_difference:

  Logical indicating whether to calculate difference for the operating
  characteristic

## Value

None
