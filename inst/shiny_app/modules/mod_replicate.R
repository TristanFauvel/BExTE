## The Replicate paper page: pick which published figures and tables to
## reproduce, run only the simulations they need, then export them.
##
## The figure/table -> generator mapping lives in R/paper_figures_manifest.R;
## this module is a thin UI over it.

replicate_choice_labels <- function() {
  entries <- paper_manifest()
  labels <- vapply(entries, function(entry) {
    prefix <- if (entry$kind == "table") {
      paste0("Table S", sub("^TS", "", entry$id))
    } else {
      paste0("Figure ", entry$id)
    }
    paste0(prefix, " - ", entry$caption)
  }, character(1))
  stats::setNames(vapply(entries, function(entry) entry$id, character(1)), labels)
}

replicate_main_ids <- function() {
  ids <- paper_manifest_ids()
  ids[!startsWith(ids, "S") & !startsWith(ids, "TS")]
}

## The results directory a finished run produced, or NULL if it produced none.
##
## Step 2 writes results/<env>/, but the Step 1 dropdown is filled once at
## module init, so without adopting the new directory Step 3 keeps exporting
## from whatever was selected before the run - typically a small smoke-test
## directory - and every figure the run was launched for fails with "No rows
## for ...".
##
## NULL means the run produced nothing usable: an interrupted run leaves the
## per-case-study/method files behind but never the concatenated
## results_frequentist.csv, so list_results_dirs() does not list it, and
## selecting it would trade a stale export for a broken one.
completed_run_results_dir <- function(env, dirs = list_results_dirs()) {
  if (is.null(env) || !nzchar(env)) {
    return(NULL)
  }
  candidate <- file.path("results", env)
  if (candidate %in% dirs) candidate else NULL
}

## The directory Step 1 should open on: the newest one whose own
## scenarios_config.yml is faithful to the paper, or "" when there is none.
##
## `dirs` arrives newest-first from list_results_dirs(). Landing on whichever
## directory happens to sort first is how a 1000-replicate, two-method
## smoke-test directory ends up selected by default and reported as covering
## 13 of 42 items - so an unfaithful directory is never chosen for you, only
## picked deliberately.
default_results_dir <- function(dirs, requirements, config_reader = paper_run_config) {
  for (dir in dirs) {
    if (length(paper_config_shortfalls(config_reader(dir), requirements)) == 0) {
      return(dir)
    }
  }
  ""
}

mod_replicate_ui <- function(id) {
  ns <- shiny::NS(id)
  bexte_page(
    bexte_step(
      1, "Choose what to reproduce",
      note = "Each item names the generator call that produces it. Coverage is checked against the results directory you pick below.",
      ## Sized for what it holds: a run directory is named
      ## "results/paper_replication_<date>_<time>", and at the field grid's
      ## ~215px column selectize paints that straight through the right edge.
      shiny::selectInput(
        ns("results_dir"), "Results directory",
        choices = NULL, width = "460px"
      ),
      ## Its own row, not a cell of the field grid: a grid column is about
      ## 215px wide, which is narrower than two of these buttons put together.
      shiny::div(
        class = "bexte-actions",
        bexte_action_button(ns("select_all"), "Select all"),
        bexte_action_button(ns("select_main"), "Main figures only"),
        bexte_action_button(ns("select_none"), "Clear")
      ),
      ## Wrapped so the list can be widened past the 300px Shiny pins every
      ## input container to - these choices are full-sentence captions.
      shiny::div(
        class = "bexte-replicate-items",
        shiny::checkboxGroupInput(ns("items"), NULL, choices = NULL)
      ),
      shiny::uiOutput(ns("coverage"))
    ),
    bexte_step(
      2, "Run the simulations the selection needs",
      note = "Only the case studies and sample sizes your selection plots are simulated, but always at the paper's fidelity and always in full - so the directory a run produces can make every figure you selected on its own. A run is skipped only when the chosen directory already covers everything.",
      shiny::uiOutput(ns("workload")),
      bexte_action_button(ns("run"), "Run required simulations"),
      shiny::uiOutput(ns("run_state")),
      shiny::verbatimTextOutput(ns("run_log"))
    ),
    bexte_step(
      3, "Produce the figures and tables",
      note = "Figures keep their generated filenames, with manifest.csv mapping each one to its paper number. A copy of every output, named \"Figure 1.png\", \"Table S1.tex\" and so on, is also written to a paper_outputs/ folder alongside them.",
      bexte_action_button(ns("export"), "Produce figures and tables"),
      shiny::uiOutput(ns("export_status")),
      shiny::tableOutput(ns("export_table"))
    )
  )
}

mod_replicate_server <- function(id, color_mode = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    state <- shiny::reactiveValues(proc = NULL, env = NULL, export = NULL)

    ## Plain closure variable, not a reactiveValues field: the observer below
    ## both reads and writes it, and a reactive one would invalidate that
    ## observer with every write just to be read again and bail out.
    adopted_run <- FALSE

    shiny::updateCheckboxGroupInput(
      session, "items",
      choices = replicate_choice_labels(),
      selected = replicate_main_ids()
    )

    case_studies_dir <- function() {
      paste0(system.file("conf/case_studies", package = "BExTE"), "/")
    }

    ## The full manifest's requirements, which is what a directory has to be
    ## faithful to before it can stand in for the paper's results. It does
    ## not depend on the current selection: the fidelity settings (methods,
    ## replicates, drift points) are the same whichever figures you pick.
    full_requirements <- function() {
      paper_replication_requirements(paper_manifest_ids(), case_studies_dir())
    }

    ## Placeholder so "nothing selected" is representable: without it Shiny
    ## selects the first directory in the list, which is how an unrelated
    ## smoke-test run becomes the export source by default.
    refresh_results_dirs <- function(selected = NULL) {
      dirs <- list_results_dirs()
      if (is.null(selected)) {
        selected <- default_results_dir(dirs, full_requirements())
      }
      shiny::updateSelectInput(
        session, "results_dir",
        choices = c("- pick a results directory -" = "", dirs),
        selected = selected
      )
      dirs
    }
    refresh_results_dirs()

    shiny::observeEvent(input$select_all, {
      shiny::updateCheckboxGroupInput(session, "items", selected = paper_manifest_ids())
    })
    shiny::observeEvent(input$select_main, {
      shiny::updateCheckboxGroupInput(session, "items", selected = replicate_main_ids())
    })
    shiny::observeEvent(input$select_none, {
      shiny::updateCheckboxGroupInput(session, "items", selected = character(0))
    })

    coverage <- shiny::reactive({
      ids <- input$items
      shiny::req(length(ids) > 0)
      dir <- input$results_dir
      if (is.null(dir) || !nzchar(dir)) {
        return(NULL)
      }
      df <- readr::read_csv(
        file.path(dir, "results_frequentist.csv"), show_col_types = FALSE
      )
      ## paper_run_config() may return NULL, and passing that explicitly is
      ## the point: a directory whose config cannot be found cannot be
      ## vouched for either.
      paper_replication_coverage(
        df, ids, case_studies_dir(),
        run_config = paper_run_config(dir)
      )
    })

    output$coverage <- shiny::renderUI({
      cov <- coverage()
      if (is.null(cov)) {
        return(bexte_empty("Pick a results directory to check coverage."))
      }
      covered <- sum(cov$covered)
      ## A badge per checkbox row is not reachable through
      ## checkboxGroupInput(), so the uncovered items are named here instead.
      uncovered <- cov[!cov$covered, , drop = FALSE]
      shiny::tagList(
        bexte_status(
          sprintf("%d of %d selected items are covered by this results directory.",
                  covered, nrow(cov)),
          ok = covered == nrow(cov)
        ),
        if (nrow(uncovered) > 0) {
          shiny::p(
            class = "bexte-note",
            paste0(
              "Not covered: ",
              paste(uncovered$id, " (", uncovered$reason, ")",
                    sep = "", collapse = "; "),
              "."
            )
          )
        }
      )
    })

    ## Everything the selection needs, not just the part the selected
    ## directory lacks. A run covering only the gap leaves a directory that
    ## cannot produce the rest on its own: with a botox-only directory
    ## selected, Step 2 used to simulate the five other case studies and omit
    ## botox, so no single directory could make all 42 and Step 3 had to
    ## export from one of them. character(0) means the selected directory
    ## already covers everything, at the paper's fidelity.
    run_ids <- shiny::reactive({
      cov <- coverage()
      if (!is.null(cov) && all(cov$covered)) character(0) else input$items
    })

    output$workload <- shiny::renderUI({
      ids <- run_ids()
      if (length(ids) == 0) {
        return(bexte_status("Nothing to run - the results directory covers everything selected."))
      }
      requirements <- paper_replication_requirements(ids, case_studies_dir())
      shiny::div(
        class = "bexte-workload",
        shiny::strong(sprintf(
          "%d case studies, sample size factors %s, %d replicates, %d drift points",
          length(requirements$case_studies),
          paste(requirements$sample_size_factors, collapse = ", "),
          requirements$n_replicates,
          requirements$ndrift
        ))
      )
    })

    shiny::observeEvent(input$run, {
      ids <- run_ids()
      if (length(ids) == 0) {
        shiny::showNotification("Nothing to run.", type = "message")
        return()
      }
      if (!is.null(state$proc) && state$proc$is_alive()) {
        shiny::showNotification("A run is already in progress.", type = "warning")
        return()
      }

      requirements <- paper_replication_requirements(ids, case_studies_dir())
      env <- paste0("paper_replication_", format(Sys.time(), "%Y%m%d_%H%M%S"))
      methods_dict <- read_methods_template()[requirements$methods]

      save_environment(
        env = env,
        scenarios_config = requirements,
        mcmc_config = yaml::read_yaml(
          file.path(system.file("conf/combined", package = "BExTE"), "mcmc_config.yml")
        ),
        methods_dict_selected = methods_dict
      )

      state$env <- env
      adopted_run <<- FALSE
      state$proc <- launch_simulation_run(env)
      shiny::showNotification(paste0("Running ", env, "."), type = "message")
    })

    ## Point Step 3 at the directory Step 2 just produced. Polling mirrors
    ## output$run_state below - the launched process offers no completion
    ## callback - and the guard makes this fire once per run.
    shiny::observe({
      if (is.null(state$proc) || adopted_run) {
        return()
      }
      if (state$proc$is_alive()) {
        shiny::invalidateLater(2000, session)
        return()
      }
      adopted_run <<- TRUE

      produced <- completed_run_results_dir(state$env)
      if (is.null(produced)) {
        ## Keep the current selection rather than silently falling back to
        ## whichever directory sorts first, and point at the run log: a run
        ## that stops early looks "finished" here whether it was killed or
        ## raised an error, and the error is recorded in run.err rather than
        ## in error_logs/ when it came from inside a parallel worker.
        current <- shiny::isolate(input$results_dir)
        shiny::showNotification(
          paste0(
            state$env, " stopped before writing results_frequentist.csv, so ",
            "it did not finish. See logs/", state$env, "/run.err for the ",
            "reason. Step 3 still exports from ",
            if (nzchar(current)) current else "nothing - pick a directory below",
            "."
          ),
          type = "warning", duration = NULL
        )
        refresh_results_dirs(shiny::isolate(input$results_dir))
      } else {
        shiny::showNotification(
          paste0("Step 3 will now export from ", produced, "."),
          type = "message"
        )
        refresh_results_dirs(produced)
      }
    })

    output$run_state <- shiny::renderUI({
      if (is.null(state$proc)) {
        return(bexte_state("idle"))
      }
      shiny::invalidateLater(2000, session)
      if (state$proc$is_alive()) bexte_state("running", "live") else bexte_state("finished", "done")
    })

    output$run_log <- shiny::renderText({
      shiny::req(state$env)
      shiny::invalidateLater(2000, session)
      log_file <- file.path("logs", state$env, "error_logs", "error_log.log")
      if (!file.exists(log_file)) {
        return("")
      }
      paste(utils::tail(readLines(log_file, warn = FALSE), 40), collapse = "\n")
    })

    shiny::observeEvent(input$export, {
      ids <- input$items
      shiny::req(length(ids) > 0)
      results_dir <- input$results_dir
      shiny::req(nzchar(results_dir))

      run_name <- basename(results_dir)
      figures_dir <- file.path("figures", "publication_figures", run_name, "")
      tables_dir <- file.path("tables", "publication_tables", run_name)
      ## A second copy of everything, named the way the paper refers to it,
      ## so the outputs can be read alongside the manuscript without going
      ## through manifest.csv to find which file is which.
      numbered_dir <- file.path("figures", "publication_figures", run_name,
                                "paper_outputs")

      shiny::withProgress(message = "Producing figures and tables", value = 0, {
        state$export <- export_paper_outputs(
          results_dir = results_dir,
          figures_dir = figures_dir,
          tables_dir = tables_dir,
          ids = ids,
          case_studies_config_dir = case_studies_dir(),
          numbered_dir = numbered_dir,
          progress = function(index, total, id) {
            shiny::setProgress(value = index / total, detail = id)
          }
        )
      })
    })

    output$export_status <- shiny::renderUI({
      status <- state$export
      if (is.null(status)) {
        return(bexte_empty("Nothing produced yet."))
      }
      ok <- sum(status$status == "ok")
      bexte_status(
        sprintf("%d of %d produced. Manifest written alongside the tables.",
                ok, nrow(status)),
        ok = ok == nrow(status)
      )
    })

    output$export_table <- shiny::renderTable({
      status <- state$export
      shiny::req(status)
      status[, c("id", "kind", "case_study", "target_sample_size_per_arm",
                 "metric", "status", "message")]
    })
  })
}
