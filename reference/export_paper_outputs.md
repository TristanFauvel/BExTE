# Produce the paper's figures and tables

Runs each selected manifest entry's generator against `results_dir` and
writes the results under `figures_dir` and `tables_dir`, keeping the
generators' own filenames. `manifest.csv` records which paper item each
file belongs to.

One entry failing does not abort the batch: it is recorded as `failed`
with its error message and the run continues.

## Usage

``` r
export_paper_outputs(
  results_dir,
  figures_dir,
  tables_dir,
  ids,
  case_studies_config_dir,
  progress = NULL
)
```

## Arguments

- results_dir:

  A `results/<env>/` directory.

- figures_dir:

  Output directory for figures, trailing slash included - the plot
  generators append their own `<case_study>/` below it.

- tables_dir:

  Output directory for tables and the manifest.

- ids:

  Manifest ids to produce.

- case_studies_config_dir:

  Directory holding the case study YAMLs.

- progress:

  Optional `function(index, total, id)` progress callback.

## Value

A status data frame, invisibly.
