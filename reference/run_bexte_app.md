# Launch the BExTE Shiny app

Opens a browser-based app to configure a simulation study (case studies,
methods, parameter grids), run it locally, and then analyze and
visualize the results.

The app reads and writes `results/<env>/`, `logs/<env>/` and
`user_configs/<env>/` inside `workspace`. Launched from a source
checkout it uses the checkout, so results land next to the ones
`Rscript inst/scripts/main.R` produces; installed from a release tarball
it uses a per-user directory under
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html). Either
way the directory it settled on is reported when the app starts.

## Usage

``` r
run_bexte_app(workspace = NULL, ...)
```

## Arguments

- workspace:

  Directory holding the simulation output. Defaults to the repository
  root in a source checkout and to `tools::R_user_dir("BExTE", "data")`
  otherwise.

- ...:

  Passed on to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html) (e.g.
  `port`, `launch.browser`).

## Value

Does not return; runs the app until interrupted.
