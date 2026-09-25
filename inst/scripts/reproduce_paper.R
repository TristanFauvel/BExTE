## Reproduce the paper's figures and tables without running the full
## simulation study: only the case studies, sample sizes and methods the
## selected outputs plot are simulated, at the paper's fidelity.
##
## This is the scripted form of the app's "Replicate paper" page. Run it from
## the directory results should be written to (results/, logs/, figures/,
## tables/ and user_configs/ are created there):
##
##   Rscript inst/scripts/reproduce_paper.R            # every paper output
##   Rscript inst/scripts/reproduce_paper.R 1 2 TS5    # just these
##   Rscript inst/scripts/reproduce_paper.R --main     # main-text figures only
##
## Environment variables, for a quick smoke test of the pipeline only (the
## outputs are not the paper's at these settings):
##   BEXTE_N_REPLICATES  replicates per scenario, for every case study (paper:
##                       10000, and 1000 for a binomial-likelihood case study)
##   BEXTE_NDRIFT        drift points per scenario (paper: 30)
##   BEXTE_PARALLEL      "false" to run in a single process
##   BEXTE_RESULTS_DIR   export from this existing results directory instead
##                       of simulating (e.g. results/paper_replication_...)

## The whole script is one expression, so R reads all of it before running
## any of it. Run as `Rscript reproduce_paper.R`, R otherwise reads each line
## only when it reaches it, and a worker process sharing the open script file
## (a forked parallel worker is the likely one) consumed two characters of it
## during a full run: `print(status)` was read as `int(status)` and failed.
local({
  library(BExTE)
  options(readr.show_col_types = FALSE)

  ## ---- What to reproduce -----------------------------------------------------

  args <- commandArgs(trailingOnly = TRUE)
  all_ids <- paper_manifest_ids()
  if (length(args) == 0) {
    ids <- all_ids
  } else if (identical(args, "--main")) {
    ids <- all_ids[!startsWith(all_ids, "S") & !startsWith(all_ids, "TS") &
                     !startsWith(all_ids, "X")]
  } else {
    ids <- args
    unknown <- setdiff(ids, all_ids)
    if (length(unknown) > 0) {
      stop("Unknown paper output id(s): ", paste(unknown, collapse = ", "),
           ". Known ids: ", paste(all_ids, collapse = " "), call. = FALSE)
    }
  }
  message("Reproducing: ", paste(ids, collapse = " "))

  case_studies_config_dir <- paste0(
    system.file("conf/case_studies", package = "BExTE"), "/"
  )

  ## ---- Simulate --------------------------------------------------------------

  results_dir <- Sys.getenv("BEXTE_RESULTS_DIR")

  if (!nzchar(results_dir)) {
    requirements <- paper_replication_requirements(ids, case_studies_config_dir)

    if (nzchar(Sys.getenv("BEXTE_N_REPLICATES"))) {
      requirements$n_replicates <- as.integer(Sys.getenv("BEXTE_N_REPLICATES"))
      requirements$case_study_n_replicates <- NULL
    }
    if (nzchar(Sys.getenv("BEXTE_NDRIFT"))) {
      requirements$ndrift <- as.integer(Sys.getenv("BEXTE_NDRIFT"))
    }
    if (tolower(Sys.getenv("BEXTE_PARALLEL")) == "false") {
      requirements$parallelization <- FALSE
    }

    env <- paste0("paper_replication_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    config_dir <- file.path("user_configs", env, "")
    dir.create(config_dir, recursive = TRUE, showWarnings = FALSE)

    ## The same three files the app writes: the scenarios the selection needs,
    ## the paper's MCMC settings, and the paper's method grid restricted to the
    ## methods the selection plots.
    yaml::write_yaml(requirements, file.path(config_dir, "scenarios_config.yml"))
    file.copy(
      system.file("conf/combined/mcmc_config.yml", package = "BExTE"),
      file.path(config_dir, "mcmc_config.yml")
    )
    methods_template <- new.env()
    source(system.file("conf/full/methods_config.R", package = "BExTE"),
           local = methods_template)
    methods_dict <- methods_template$methods_dict[requirements$methods]
    writeLines(
      paste0("methods_dict <- ", paste(deparse(methods_dict), collapse = "\n")),
      file.path(config_dir, "methods_config.R")
    )

    replicates <- vapply(requirements$case_studies, function(case_study) {
      sprintf("%s %d", case_study, as.integer(
        BExTE:::case_study_n_replicates(requirements, case_study)
      ))
    }, character(1))
    message(sprintf(
      "Simulating %s: %d methods, %d drift points; replicates per case study: %s.",
      env, length(requirements$methods), requirements$ndrift,
      paste(replicates, collapse = ", ")
    ))

    metrics <- new.env()
    source(system.file("conf/metrics_config.R", package = "BExTE"), local = metrics)

    run_simulation_env(
      env = env,
      config_dir = config_dir,
      case_studies_config_dir = case_studies_config_dir,
      simulation_config = yaml::read_yaml(
        system.file("conf/simulation_config.yml", package = "BExTE")
      ),
      analysis_config = yaml::read_yaml(
        system.file("conf/analysis_config.yml", package = "BExTE")
      ),
      frequentist_metrics = metrics$frequentist_metrics,
      inference_metrics = metrics$inference_metrics
    )

    results_dir <- file.path("results", env)
  }

  ## ---- Export ----------------------------------------------------------------

  if (!file.exists(file.path(results_dir, "results_frequentist.csv"))) {
    stop(results_dir, " has no results_frequentist.csv, so the run did not ",
         "finish. See logs/", basename(results_dir), "/ for the reason.",
         call. = FALSE)
  }

  run_name <- basename(results_dir)
  status <- export_paper_outputs(
    results_dir = results_dir,
    figures_dir = file.path("figures", "publication_figures", run_name, ""),
    tables_dir = file.path("tables", "publication_tables", run_name),
    ids = ids,
    case_studies_config_dir = case_studies_config_dir,
    numbered_dir = file.path("figures", "publication_figures", run_name,
                             "paper_outputs")
  )

  print(status)
  failed <- status[status$status != "ok", , drop = FALSE]
  message(sprintf(
    "%d of %d outputs produced. Paper-numbered copies are in %s.",
    nrow(status) - nrow(failed), nrow(status),
    file.path("figures", "publication_figures", run_name, "paper_outputs")
  ))
  if (nrow(failed) > 0) {
    quit(status = 1)
  }
})
