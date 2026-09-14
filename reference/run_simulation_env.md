# Run a full simulation for one environment

Runs the frequentist and/or Bayesian Monte Carlo operating
characteristics simulation for a single environment. This mirrors the
per-environment body of the driver loop in `inst/scripts/main.R`,
extracted into a callable function so it can be invoked directly (e.g.
from a background process launched by the Shiny app).

## Usage

``` r
run_simulation_env(
  env,
  config_dir,
  case_studies_config_dir,
  simulation_config,
  analysis_config,
  frequentist_metrics,
  inference_metrics,
  results_dir = paste0("./results/", env, "/"),
  check_results_completeness = TRUE
)
```

## Arguments

- env:

  The environment name (used to name the `./logs/<env>/` and
  `./results/<env>/` directories).

- config_dir:

  Directory containing `scenarios_config.yml`, `mcmc_config.yml` and
  `methods_config.R` for this environment (must end with a trailing
  slash).

- case_studies_config_dir:

  Directory containing the case study YAML files referenced by this
  environment (must end with a trailing slash).

- simulation_config:

  Simulation configuration list (as read from `simulation_config.yml`).

- analysis_config:

  Analysis configuration list (as read from `analysis_config.yml`).

- frequentist_metrics:

  List of frequentist metrics, as defined by sourcing
  `metrics_config.R`.

- inference_metrics:

  List of inference metrics, as defined by sourcing `metrics_config.R`.

- results_dir:

  Directory the results are written to. Defaults to `./results/<env>/`.

- check_results_completeness:

  Reserved for a future completeness check; currently unused, mirroring
  `inst/scripts/main.R` where the corresponding call is commented out.

## Value

`TRUE`, invisibly, once frequentist and/or Bayesian OCs have been
computed and concatenated according to `simulation_config`.
