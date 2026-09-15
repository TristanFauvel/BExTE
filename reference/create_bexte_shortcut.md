# Add a desktop shortcut that launches the app

Writes an application-menu entry that starts the Shiny app, so the app
can be launched without an R session. It shortens *launching*, not
*installing*: R, BExTE and CmdStan all still have to be present, which
is what `inst/scripts/install.R` is for.

Two files are written. A shell script holds the R call, because the
`Exec` key of a desktop entry is split on whitespace rather than parsed
by a shell, so quotes around an `-e` argument would reach R intact. The
entry then points at that script.

The entry runs in a terminal on purpose. The app is a server that runs
until it is stopped, and the terminal is what carries the workspace
path, the progress of a run, and Ctrl+C as the way to stop it.

## Usage

``` r
create_bexte_shortcut(
  workspace = NULL,
  applications_dir = path.expand("~/.local/share/applications"),
  script_dir = tools::R_user_dir("BExTE", "data")
)
```

## Arguments

- workspace:

  Workspace to launch with, or `NULL` to let
  [`run_bexte_app()`](https://quinten-health-os.github.io/BayesianExtrapolationSimulation/reference/run_bexte_app.md)
  choose one.

- applications_dir:

  Directory holding desktop entries. The default puts the entry in the
  application menu, which, unlike one placed on the desktop, needs no
  separate step to mark it trusted.

- script_dir:

  Directory to write the launcher script into.

## Value

Paths of the launcher and the desktop entry, invisibly.
