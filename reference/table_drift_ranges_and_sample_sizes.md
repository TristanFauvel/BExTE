# Drift ranges and target sample sizes for each case study (table S1)

The paper's table S1, which merges what used to be two tables: the drift
and treatment-effect ranges, and the target-study sample sizes. The
ranges come from
[`compute_drift_range()`](https://tristanfauvel.github.io/BExTE/reference/compute_drift_range.md),
the function the simulation builds its drift grid with, so the table
describes the grid the current configs produce rather than whatever an
older results directory happens to hold.

The sample-size columns are the nominal totals `floor(N_S / k)`, as the
paper prints them. The simulation puts `floor(N_S / (2k))` patients in
each arm, so the total it actually simulates can be one or two lower -
see
[`paper_sample_size_per_arm()`](https://tristanfauvel.github.io/BExTE/reference/paper_sample_size_per_arm.md).

Every case study is listed whatever the selection, because the paper's
table always has all six rows.

## Usage

``` r
table_drift_ranges_and_sample_sizes(case_studies_config_dir, tables_dir)
```

## Arguments

- case_studies_config_dir:

  Directory holding the case study YAMLs.

- tables_dir:

  Directory to write into.

## Value

The path of the written `.tex` file.
