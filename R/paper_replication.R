## Deriving the smallest simulation config that still reproduces a chosen set
## of paper figures, and checking an existing results directory against them.

## The methods the paper compares. A selection narrows this only when every
## entry in it names the method it plots - forest plots and the versus-TIE
## plots draw all of them. See paper_required_methods().
PAPER_METHODS <- c(
  "RMP", "separate", "pooling", "conditional_power_prior",
  "test_then_pool_equivalence", "test_then_pool_difference",
  "p_value_based_PP", "EB_PP", "PDCCPP", "NPP", "NPP_KL",
  "commensurate_power_prior", "commensurate_prior", "egidi_empirical_mixture"
)

#' Minimal simulation config for a set of paper figures
#'
#' @description Folds the selected manifest entries into a `scenarios_config`
#'   covering exactly the case studies, sample size factors and methods they
#'   need. Each case study is restricted to its own factors through
#'   `case_study_sample_size_factors`, rather than every case study being
#'   crossed with every factor. The
#'   fidelity settings do not scale with the selection: `ndrift` stays at 30
#'   because `forest_plot()` selects the three principal treatment-effect
#'   scenarios by nearest grid point, so a coarser grid would quietly plot
#'   different drift values rather than failing.
#'
#'   No paper figure varies the source denominator change factor or the
#'   target-to-source standard deviation ratio, so both are pinned to 1.
#'
#' @param ids Manifest ids to cover.
#' @param case_studies_config_dir Directory holding the case study YAMLs.
#'
#' @return A `scenarios_config` list, ready for `save_environment()`.
#'
#' @export
paper_replication_requirements <- function(ids, case_studies_config_dir) {
  entries <- lapply(ids, paper_manifest_entry)
  entries <- Filter(function(entry) !is.na(entry$case_study), entries)

  case_studies <- unique(vapply(entries, function(e) e$case_study, character(1)))
  factors <- unique(vapply(entries, function(e) e$sample_size_factor, numeric(1)))

  ## Each case study is wanted at only the factors its own figures plot, which
  ## for the paper is two of the three. Taking the union of case studies and
  ## the union of factors and letting the run form their cross product
  ## simulates combinations nothing asked for - a third of the grid, for the
  ## whole manifest. simulation_frequentist_ocs() reads this to narrow each
  ## case study's block back to what was actually requested.
  per_case_study <- lapply(case_studies, function(case_study) {
    sort(unique(vapply(
      Filter(function(e) identical(e$case_study, case_study), entries),
      function(e) e$sample_size_factor, numeric(1)
    )))
  })
  names(per_case_study) <- case_studies

  requirements <- list(
    n_replicates = PAPER_N_REPLICATES,
    ndrift = 30,
    parallelization = TRUE,
    analysis_steps = PAPER_ANALYSIS_STEPS,
    denominator_change_factor = 1,
    sample_size_factors = sort(factors),
    case_study_sample_size_factors = per_case_study,
    target_to_source_std_ratio_range = 1,
    case_studies = case_studies,
    methods = paper_required_methods(entries)
  )

  ## The time-to-event sensitivity figures read designs the primary grid does
  ## not simulate. They are asked for only when such a figure is selected,
  ## and only at the sensitivity reference, one axis at a time.
  if (any(vapply(entries, function(e) !is.null(e$design_axis), logical(1)))) {
    requirements <- c(requirements, PAPER_TTE_SENSITIVITY)
  }

  ## Every case study, including those analysed with the exact binomial
  ## likelihood, runs at the paper's replicate count: the binomial models
  ## compute their posterior by quadrature and share the analyses of repeated
  ## counts, so they no longer need the reduced count MCMC imposed.
  ##
  ## The binary case studies are not simulated at all: their operating
  ## characteristics are summed exactly over every trial outcome, so the
  ## replicate count does not apply to them.
  enumerated <- intersect(PAPER_EXACT_ENUMERATION, case_studies)
  if (length(enumerated) > 0) {
    requirements$exact_enumeration <- enumerated
  }
  requirements
}

## The case studies whose operating characteristics the paper computes exactly,
## by enumerating the responder counts of each arm - see
## case_study_exact_enumeration().
PAPER_EXACT_ENUMERATION <- c("aprepitant", "belimumab")

## Replicates per scenario: the paper's Monte Carlo precision.
PAPER_N_REPLICATES <- 10000

## The analysis steps the paper's outputs read.
##
## Every generator in the manifest reads results_frequentist.csv alone, and
## the drift figures compare against the two power baselines these steps add
## to it. Nothing reads the sweet spot or the Bayesian OCs; in the 17
## September paper run those took longer than the simulations themselves.
PAPER_ANALYSIS_STEPS <- c(
  "frequentist_power_at_equivalent_tie",
  "frequentist_power_at_nominal_tie"
)

## The time-to-event sensitivity designs the teriflunomide figures S45-S52
## read, as scenarios_config keys. The levels mirror
## inst/conf/combined/scenarios_config.yml. They are simulated only at
## N_T/2 = 123 (sample size factor 6), the size the other teriflunomide
## figures use, and one axis at a time: seven designs besides the primary
## one, where crossing the axes would take fifty-three. The treatment delays
## are 12 and 24 weeks, in years as every other time.
PAPER_TTE_SENSITIVITY <- list(
  control_drift_range = c(-0.405, 0, 0.405),
  dropout_probability = c(0, 0.05, 0.10),
  event_time_distribution = c("exponential", "weibull"),
  treatment_delay = c(0, 0.230769, 0.461538),
  sensitivity_reference = list(sample_size_factor = 6, denominator_change_factor = 1),
  sensitivity_one_at_a_time = TRUE
)

## Which rows of a results frame are simulated under the primary
## time-to-event design. A column the results do not carry, or NA in it, is
## the primary value: results written before the axes existed, and every
## other endpoint, only ever had that design.
paper_primary_design_rows <- function(df) {
  at_primary <- function(column, primary) {
    if (!column %in% names(df)) {
      return(rep(TRUE, nrow(df)))
    }
    is.na(df[[column]]) | df[[column]] == primary
  }
  at_primary("control_drift", 0) &
    at_primary("dropout_probability", 0) &
    at_primary("event_time_distribution", "exponential") &
    at_primary("treatment_delay", 0)
}

## The methods a set of manifest entries actually plots.
##
## Forest plots and the versus-type-I-error plots draw every method, so any
## selection containing one needs all of them - which is why this used to be
## hard-coded. The entries that plot a single method (S3, S4 and S20) do not,
## and a selection made only of those was simulating eleven methods to draw
## one of them, the two most expensive included.
##
## `separate` and `pooling` are always kept: the drift plots draw their
## baselines from the separate analysis, frequentist_power_at_equivalent_tie()
## needs it, and simulation_frequentist_ocs() warns when it is absent.
paper_required_methods <- function(entries) {
  declared <- lapply(entries, function(entry) entry$methods)
  ## An entry that declares nothing is treated as needing everything, so a new
  ## manifest entry cannot silently under-simulate.
  if (any(vapply(declared, is.null, logical(1))) ||
        any(vapply(declared, function(m) identical(m, "all"), logical(1)))) {
    return(PAPER_METHODS)
  }

  required <- unique(c("separate", "pooling", unlist(declared)))
  ## Keep PAPER_METHODS' order, so the config reads the same way either way.
  PAPER_METHODS[PAPER_METHODS %in% required]
}

#' The simulation config a results directory was produced from
#'
#' @description `save_environment()` writes each run's `scenarios_config.yml`
#'   under `user_configs/<env>/`, and the results directory carries the same
#'   name. Returns `NULL` when there is no such file - some older results
#'   directories predate the convention.
#'
#' @param results_dir A results directory, e.g. `"results/minimal_test"`.
#' @param user_configs_dir Directory holding the per-environment configs.
#'
#' @return The parsed `scenarios_config`, or `NULL`.
#'
#' @export
paper_run_config <- function(results_dir, user_configs_dir = "user_configs") {
  path <- file.path(user_configs_dir, basename(results_dir), "scenarios_config.yml")
  if (!file.exists(path)) {
    return(NULL)
  }
  yaml::read_yaml(path)
}

#' How a results directory falls short of the paper's fidelity
#'
#' @description Which scenarios a directory holds is visible in its rows, and
#'   [paper_replication_coverage()] checks that. How they were simulated is
#'   not: a directory holding 2 of the 11 methods at 1000 replicates yields
#'   figures that look like the paper's but compare two methods at a tenth of
#'   the Monte Carlo precision. Only the config the run was launched from can
#'   show that, so the two checks are kept separate - this one is a property
#'   of the whole directory rather than of any single figure.
#'
#' @param run_config A parsed `scenarios_config`, or `NULL` if none was found.
#' @param requirements A [paper_replication_requirements()] list.
#'
#' @return A character vector of shortfalls; empty when the config is faithful.
#'
#' @export
paper_config_shortfalls <- function(run_config, requirements) {
  if (is.null(run_config)) {
    return("its simulation config was not found, so its fidelity cannot be checked")
  }

  shortfalls <- character(0)

  missing_methods <- setdiff(requirements$methods, as.character(run_config$methods))
  if (length(missing_methods) > 0) {
    shortfalls <- c(shortfalls, sprintf(
      "%d of the %d methods were not simulated (%s)",
      length(missing_methods), length(requirements$methods),
      paste(missing_methods, collapse = ", ")
    ))
  }

  ## More replicates than the paper is only a tighter Monte Carlo error, so
  ## the comparison is one-sided; a coarser drift grid is not, because
  ## forest_plot() picks the three principal scenarios by nearest grid point
  ## and a different grid quietly plots different drift values.
  short_of <- Filter(Negate(is.null), lapply(
    as.character(requirements$case_studies),
    function(case_study) {
      if (case_study_exact_enumeration(run_config, case_study)) {
        return(NULL)
      }
      simulated <- case_study_n_replicates(run_config, case_study)
      required <- case_study_n_replicates(requirements, case_study)
      if (isTRUE(simulated < required)) {
        sprintf(
          "%s replicates instead of %s for %s",
          format(simulated, scientific = FALSE),
          format(required, scientific = FALSE),
          case_study
        )
      }
    }
  ))
  shortfalls <- c(shortfalls, unlist(short_of))

  ## Simulated instead of enumerated, the figures carry Monte Carlo error the
  ## paper's do not.
  not_enumerated <- Filter(function(case_study) {
    !case_study_exact_enumeration(run_config, case_study)
  }, as.character(unlist(requirements$exact_enumeration)))
  if (length(not_enumerated) > 0) {
    shortfalls <- c(shortfalls, sprintf(
      "%s was simulated rather than enumerated exactly",
      paste(not_enumerated, collapse = ", ")
    ))
  }
  if (!isTRUE(run_config$ndrift == requirements$ndrift)) {
    shortfalls <- c(shortfalls, sprintf(
      "%s drift points instead of %s", run_config$ndrift, requirements$ndrift
    ))
  }

  ## A config without analysis_steps ran every step. One that names a subset
  ## has to include the power baselines, or the drift figures have nothing to
  ## compare against.
  if (!is.null(run_config$analysis_steps)) {
    skipped <- setdiff(
      requirements$analysis_steps,
      as.character(unlist(run_config$analysis_steps))
    )
    if (length(skipped) > 0) {
      shortfalls <- c(shortfalls, sprintf(
        "the analysis skipped %s", paste(skipped, collapse = ", ")
      ))
    }
  }

  ## A config that set none of the sensitivity axes simulated the primary
  ## design alone, so a figure that varies them would have nothing to plot.
  if (!is.null(requirements$dropout_probability)) {
    axes <- c("control_drift_range", "dropout_probability", "event_time_distribution",
              "treatment_delay")
    missing_axes <- Filter(function(axis) {
      !all(as.character(requirements[[axis]]) %in%
             as.character(unlist(run_config[[axis]])))
    }, axes)
    if (length(missing_axes) > 0) {
      shortfalls <- c(shortfalls, sprintf(
        "the time-to-event sensitivity designs were not simulated (%s)",
        paste(missing_axes, collapse = ", ")
      ))
    }
  }

  shortfalls
}

#' Check a results frame against a set of paper figures
#'
#' @param results_df A frequentist results frame.
#' @param ids Manifest ids to check.
#' @param case_studies_config_dir Directory holding the case study YAMLs.
#' @param run_config Optionally the `scenarios_config` the results were
#'   produced from (see [paper_run_config()]). When given, a directory that
#'   falls short of the paper's fidelity covers no figure at all, however
#'   many rows it holds - see [paper_config_shortfalls()]. Tables are
#'   unaffected: they are built from the case study YAMLs, not from
#'   simulation output.
#'
#' @return A data frame with columns `id`, `covered` and `reason`.
#'
#' @export
paper_replication_coverage <- function(results_df, ids, case_studies_config_dir,
                                       run_config = NULL) {
  fidelity_reason <- ""
  ## missing(), not is.null(): omitting the argument means "do not check
  ## fidelity" (how every caller predating this behaved), while passing an
  ## explicit NULL means "I looked for the config and there is none", which
  ## is itself disqualifying - paper_run_config() returns NULL for the older
  ## results directories that carry no scenarios_config.yml.
  if (!missing(run_config)) {
    shortfalls <- paper_config_shortfalls(
      run_config, paper_replication_requirements(ids, case_studies_config_dir)
    )
    if (length(shortfalls) > 0) {
      fidelity_reason <- paste(shortfalls, collapse = "; ")
    }
  }

  rows <- lapply(ids, function(id) {
    entry <- paper_manifest_entry(id)

    if (is.na(entry$case_study)) {
      return(data.frame(id = id, covered = TRUE, reason = "", stringsAsFactors = FALSE))
    }

    ## Reported ahead of any per-figure gap: no amount of the right rows
    ## makes a directory simulated at the wrong fidelity usable, so saying
    ## "no belimumab rows" first would send you off to run the wrong thing.
    if (nzchar(fidelity_reason)) {
      return(data.frame(
        id = id, covered = FALSE, reason = fidelity_reason,
        stringsAsFactors = FALSE
      ))
    }

    if (!entry$case_study %in% results_df$case_study) {
      return(data.frame(
        id = id, covered = FALSE,
        reason = paste0("no ", entry$case_study, " rows"),
        stringsAsFactors = FALSE
      ))
    }

    per_arm <- paper_sample_size_per_arm(
      entry$case_study, entry$sample_size_factor, case_studies_config_dir
    )
    slice <- results_df[results_df$case_study == entry$case_study &
                          results_df$target_sample_size_per_arm == per_arm, , drop = FALSE]
    if (nrow(slice) == 0) {
      return(data.frame(
        id = id, covered = FALSE,
        reason = paste0("no rows at ", per_arm, " per arm"),
        stringsAsFactors = FALSE
      ))
    }

    if (!is.null(entry$design_axis) &&
          !any(slice[[entry$design_axis]] != TIME_TO_EVENT_AXES[[entry$design_axis]]$primary,
               na.rm = TRUE)) {
      return(data.frame(
        id = id, covered = FALSE,
        reason = paste0("no ", entry$design_axis, " sensitivity designs"),
        stringsAsFactors = FALSE
      ))
    }

    if (!is.na(entry$metric) && !entry$metric %in% names(results_df)) {
      return(data.frame(
        id = id, covered = FALSE,
        reason = paste0("no ", entry$metric, " column"),
        stringsAsFactors = FALSE
      ))
    }

    data.frame(id = id, covered = TRUE, reason = "", stringsAsFactors = FALSE)
  })

  do.call(rbind, rows)
}

## ---- Export ------------------------------------------------------------

## Source the plot style/config globals the generators expect.
##
## The plot_*() functions (and forest_plot()) resolve several inputs as free
## variables out of .GlobalEnv rather than taking them as arguments - style
## constants such as font and textwidth, the metric lookup tables
## frequentist_metrics/inference_metrics, the drift-axis helper xvars, and the
## method labelling tables methods_dict/methods_labels. This is exactly how
## inst/scripts/plots.R has always driven them, and how
## BExTE-app's ensure_plot_globals()/prepare_plot_globals_for_env() (in its
## inst/app/modules/mod_analyze.R) sets them up for the Analyze page. This
## mirrors that: source the three config files that define the style
## constants and metric tables, then set methods_dict from the package's
## canonical template (mirroring read_methods_template() in BExTE-app's
## inst/app/helpers.R), since the exporter has no results-environment
## methods_config.R of its own to prefer.
ensure_paper_plot_globals <- function() {
  source(system.file("conf/plots_config.R", package = "BExTE"))
  source(system.file("conf/methods_plots_config.R", package = "BExTE"))
  source(system.file("conf/metrics_config.R", package = "BExTE"))

  methods_template_env <- new.env()
  source(system.file("conf/full/methods_config.R", package = "BExTE"), local = methods_template_env)
  assign("methods_dict", methods_template_env$methods_dict, envir = .GlobalEnv)

  invisible(NULL)
}

## Snapshot every name currently bound in .GlobalEnv (and the current ggplot
## theme), so a later call to paper_restore_globals() can put the caller's
## session back exactly as it was. Unlike BExTE-app's
## ensure_plot_globals() - which is allowed to leave these set because it
## lives inside a single long-running Shiny session - export_paper_outputs()
## is an exported library function that a script or interactive session can
## call directly, so it must not leak font/textwidth/methods_dict/... (or a
## replaced ggplot2::theme_set()) into the caller's .GlobalEnv.
paper_snapshot_globals <- function() {
  names_before <- ls(envir = .GlobalEnv, all.names = TRUE)
  list(
    names_before = names_before,
    values_before = mget(names_before, envir = .GlobalEnv),
    theme_before = ggplot2::theme_get()
  )
}

## Restore .GlobalEnv (and the ggplot theme) to what paper_snapshot_globals()
## recorded: reassign every name that already existed back to its old value,
## and remove every name that ensure_paper_plot_globals()/figures_dir/
## remake_figures newly introduced. Determining "newly introduced" via
## setdiff(ls(.GlobalEnv), snapshot$names_before) - rather than a hard-coded
## list of names - means this keeps working if the conf/*.R files start
## defining (or stop defining) globals.
paper_restore_globals <- function(snapshot) {
  names_now <- ls(envir = .GlobalEnv, all.names = TRUE)
  new_names <- setdiff(names_now, snapshot$names_before)
  if (length(new_names) > 0) {
    suppressWarnings(rm(list = new_names, envir = .GlobalEnv))
  }
  for (name in snapshot$names_before) {
    assign(name, snapshot$values_before[[name]], envir = .GlobalEnv)
  }
  ggplot2::theme_set(snapshot$theme_before)
  invisible(NULL)
}

## A snapshot of every figure/table file already on disk, with enough to tell
## whether a later write is a genuinely new file or an overwrite of an
## existing one - see paper_outputs_written() below.
paper_output_snapshot <- function(figures_dir, tables_dir) {
  paths <- c(
    list.files(figures_dir, recursive = TRUE, full.names = TRUE),
    list.files(tables_dir, recursive = TRUE, full.names = TRUE)
  )
  info <- file.info(paths, extra_cols = FALSE)
  data.frame(
    path = paths,
    mtime = info$mtime,
    size = info$size,
    stringsAsFactors = FALSE
  )
}

## Which paths in `after` (a paper_output_snapshot()) were written since
## `before` was taken: either the path did not exist before, or its mtime or
## size changed. A plain before/after path-list diff (the brief's approach)
## mis-attributes provenance on a second export into the same directories -
## with remake_figures TRUE, every path from the first run is already present
## in "before" on a second run, so nothing would ever look new. Comparing
## mtime (checked at microsecond resolution on this filesystem - verified
## with back-to-back writes carrying no sleep in between, see the task-5 fix
## report) plus size catches an overwrite that reproduces the same bytes but
## still counts as "produced by this run".
paper_outputs_written <- function(before, after) {
  match_index <- match(after$path, before$path)
  is_new <- is.na(match_index)
  changed <- !is_new & (
    after$mtime != before$mtime[match_index] |
      after$size != before$size[match_index]
  )
  after$path[is_new | changed]
}

#' Build the context one manifest entry's generator receives
#'
#' @description The generators take the slice already narrowed to their own
#'   case study, sample size, denominator factor and standard deviation ratio,
#'   mirroring what the loop functions in inst/scripts/plots.R pass them.
#'
#' @keywords internal
paper_entry_context <- function(entry, results_df, results_dir, tables_dir,
                                case_studies_config_dir, case_studies,
                                sample_size_factors, analysis_config) {
  ctx <- list(
    results_dir = results_dir,
    tables_dir = tables_dir,
    case_studies_config_dir = case_studies_config_dir,
    case_studies = case_studies,
    sample_size_factors = sample_size_factors,
    analysis_config = analysis_config
  )

  if (is.na(entry$case_study)) {
    return(ctx)
  }

  per_arm <- paper_sample_size_per_arm(
    entry$case_study, entry$sample_size_factor, case_studies_config_dir
  )
  case_config <- yaml::read_yaml(
    file.path(case_studies_config_dir, paste0(entry$case_study, ".yml"))
  )

  slice <- results_df[
    results_df$case_study == entry$case_study &
      results_df$target_sample_size_per_arm == per_arm &
      (results_df$source_denominator_change_factor == 1 |
         is.na(results_df$source_denominator_change_factor)) &
      (results_df$target_to_source_std_ratio == 1 |
         is.na(results_df$target_to_source_std_ratio)),
    ,
    drop = FALSE
  ]
  ## Every figure but the sensitivity ones is drawn under the primary
  ## time-to-event design. None of the plot functions tells the designs
  ## apart, so rows from the others would be pooled into its points.
  if (is.null(entry$design_axis)) {
    slice <- slice[paper_primary_design_rows(slice), , drop = FALSE]
  }
  if (nrow(slice) == 0) {
    stop(
      "No rows for ", entry$case_study, " at ", per_arm,
      " per arm with denominator factor 1 and standard deviation ratio 1."
    )
  }

  ctx$df <- slice
  ctx$target_sample_size_per_arm <- per_arm
  ctx$theta_0 <- case_config$theta_0
  ctx
}

## How the paper refers to a manifest entry: "Figure 1", "Figure S33",
## "Table S1". The manifest's table ids carry a "T" prefix the paper does
## not - TS1 is the paper's table S1 - which is also why the Replicate page's
## checkbox labels strip it.
paper_numbered_label <- function(entry) {
  if (identical(entry$kind, "table")) {
    paste0("Table S", sub("^TS", "", entry$id))
  } else {
    paste0("Figure ", entry$id)
  }
}

## Copy the paper's outputs into `numbered_dir`, one folder holding every
## figure and table the paper uses.
##
## The files keep the names their generators gave them, which say what each
## plots; manifest.csv maps each one to its paper number. Figures are copied
## as PDF, the vector format the manuscript includes; tables keep both the
## .tex the manuscript includes and the .pdf you look at. An item that
## produced nothing is skipped, so the folder never holds a figure that was
## not drawn. Two different files with the same name - from different case
## study folders - are told apart by prefixing the second with its folder
## name, rather than one silently overwriting the other.
paper_write_numbered_copies <- function(status, entries, numbered_dir) {
  dir.create(numbered_dir, showWarnings = FALSE, recursive = TRUE)
  ## Earlier exports copied figures as PNG; drop those so a re-export does not
  ## leave both formats side by side.
  unlink(list.files(numbered_dir, pattern = "\\.png$", full.names = TRUE))
  copied_from <- character(0)

  for (index in seq_len(nrow(status))) {
    row <- status[index, ]
    if (!identical(row$status, "ok") || !nzchar(row$outputs)) {
      next
    }
    produced <- trimws(strsplit(row$outputs, ";", fixed = TRUE)[[1]])
    produced <- produced[nzchar(produced) & file.exists(produced)]
    wanted <- if (identical(row$kind, "table")) {
      produced[grepl("\\.(tex|pdf)$", produced)]
    } else {
      produced[grepl("\\.pdf$", produced)]
    }

    for (path in wanted) {
      name <- basename(path)
      source <- normalizePath(path)
      if (name %in% names(copied_from) && !identical(copied_from[[name]], source)) {
        name <- paste0(basename(dirname(path)), "_", name)
      }
      file.copy(path, file.path(numbered_dir, name), overwrite = TRUE)
      copied_from[[name]] <- source
    }
  }
  invisible(NULL)
}

## Produce manifest entries in forked processes, `workers` at a time.
##
## A figure costs about a second to draw, twice over for its PDF and PNG, and
## the paper's 60 items draw several hundred, one after the other. The items
## are independent, so they run in parallel here - but the sequential path
## works out which files an item wrote by comparing the output directories
## before and after it, which cannot tell concurrent items apart. Each item
## therefore writes into its own staging directories, and the files are
## copied into place afterwards in manifest order, so the final directories
## hold what a sequential run would have left there, and each item is
## credited with exactly the paths a sequential run would report for it.
##
## The progress callback runs here, in the parent, as each item finishes: a
## callback reaching into a Shiny session could not work from a child.
##
## Returns one list per entry: status, message and the paths written.
paper_export_in_parallel <- function(entries, run_generator, figures_dir,
                                     tables_dir, workers, progress) {
  staging_root <- tempfile("bexte-paper-export-")
  dir.create(staging_root)
  on.exit(unlink(staging_root, recursive = TRUE), add = TRUE)
  staging_dir <- function(index, kind) {
    file.path(staging_root, index, kind)
  }

  run_in_child <- function(index) {
    entry_figures_dir <- paste0(staging_dir(index, "figures"), "/")
    entry_tables_dir <- staging_dir(index, "tables")
    dir.create(entry_figures_dir, recursive = TRUE)
    dir.create(entry_tables_dir, recursive = TRUE)
    ## Only the child's own copy of .GlobalEnv changes.
    assign("figures_dir", entry_figures_dir, envir = .GlobalEnv)
    run_generator(entries[[index]], entry_tables_dir)
  }

  outcomes <- vector("list", length(entries))
  jobs <- list()
  job_index <- integer()
  next_index <- 1L
  finished <- 0L

  while (finished < length(entries)) {
    while (length(jobs) < workers && next_index <= length(entries)) {
      job <- parallel::mcparallel(run_in_child(next_index))
      jobs[[as.character(job$pid)]] <- job
      job_index[[as.character(job$pid)]] <- next_index
      next_index <- next_index + 1L
    }

    done <- parallel::mccollect(jobs, wait = FALSE, timeout = 0.5)
    for (pid in names(done)) {
      index <- job_index[[pid]]
      value <- done[[pid]]
      outcomes[[index]] <- if (is.list(value) && !is.null(value$status)) {
        value
      } else {
        ## An error outside the generator's own tryCatch() comes back as a
        ## try-error, and a process that died comes back as NULL.
        list(status = "failed", message = if (inherits(value, "try-error")) {
          conditionMessage(attr(value, "condition"))
        } else {
          "The process producing this item exited without a result."
        })
      }
      jobs[[pid]] <- NULL
      job_index <- job_index[names(job_index) != pid]
      finished <- finished + 1L
      if (!is.null(progress)) {
        progress(finished, length(entries), entries[[index]]$id)
      }
    }
  }

  ## In manifest order, so that where two items write the same file the later
  ## one's copy is kept, as it would be sequentially.
  for (index in seq_along(entries)) {
    written <- character()
    for (kind in c("figures", "tables")) {
      source_dir <- staging_dir(index, kind)
      target_dir <- if (kind == "figures") figures_dir else tables_dir
      relative <- list.files(source_dir, recursive = TRUE)
      for (path in relative) {
        target <- file.path(target_dir, path)
        dir.create(dirname(target), showWarnings = FALSE, recursive = TRUE)
        file.copy(file.path(source_dir, path), target, overwrite = TRUE)
      }
      ## The form list.files(full.names = TRUE) gives, which is how the
      ## sequential path reports them. paste() of no paths would still give
      ## one, the bare directory.
      if (length(relative) > 0) {
        written <- c(written, paste(target_dir, relative, sep = "/"))
      }
    }
    outcomes[[index]]$written <- written
  }

  outcomes
}

#' Produce the paper's figures and tables
#'
#' @description Runs each selected manifest entry's generator against
#'   `results_dir` and writes the results under `figures_dir` and `tables_dir`,
#'   keeping the generators' own filenames. `manifest.csv` records which paper
#'   item each file belongs to.
#'
#'   One entry failing does not abort the batch: it is recorded as `failed`
#'   with its error message and the run continues.
#'
#' @param results_dir A `results/<env>/` directory.
#' @param figures_dir Output directory for figures, trailing slash included -
#'   the plot generators append their own `<case_study>/` below it.
#' @param tables_dir Output directory for tables and the manifest.
#' @param ids Manifest ids to produce.
#' @param case_studies_config_dir Directory holding the case study YAMLs.
#' @param progress Optional `function(index, total, id)` progress callback.
#' @param numbered_dir Optional directory collecting a copy of every output
#'   produced, under the generators' own filenames: figures as PDF, tables as
#'   both `.tex` and `.pdf`. `manifest.csv` maps each file to its paper number.
#'   `NULL` skips it.
#' @param workers Number of items to produce at once, each in a forked
#'   process. The default, 1, produces them one after the other in this
#'   process. Forking is unavailable on Windows, which always uses one. The
#'   files written and the status returned are the same either way; with more
#'   than one worker, `progress` is called as each item finishes rather than
#'   as it starts.
#'
#' @return A status data frame, invisibly.
#'
#' @export
export_paper_outputs <- function(results_dir, figures_dir, tables_dir, ids,
                                 case_studies_config_dir, progress = NULL,
                                 numbered_dir = NULL, workers = 1L) {
  ## Some generators build their paths with paste0(figures_dir, case_study)
  ## rather than file.path(), so a directory named without a trailing
  ## separator concatenates into a sibling of itself - "figures" and
  ## "botox" become "figuresbotox". The figure is still written, just not
  ## where the snapshot below is watching, and the run then reports "no
  ## output" for a file that is on disk. The trailing slash is documented,
  ## but a wrong status is a worse answer to forgetting it than simply
  ## adding it here.
  if (nzchar(figures_dir)) {
    figures_dir <- paste0(sub("/+$", "", figures_dir), "/")
  }

  dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

  results_df <- readr::read_csv(
    file.path(results_dir, "results_frequentist.csv"),
    show_col_types = FALSE
  )
  analysis_config <- yaml::read_yaml(
    system.file("conf/analysis_config.yml", package = "BExTE")
  )

  entries <- lapply(ids, paper_manifest_entry)
  ## as.character()/as.numeric() strip the attributes na.omit() leaves behind.
  all_case_studies <- vapply(entries, function(e) e$case_study, character(1))
  case_studies <- unique(as.character(all_case_studies[!is.na(all_case_studies)]))
  all_factors <- vapply(entries, function(e) e$sample_size_factor, numeric(1))
  sample_size_factors <- sort(unique(as.numeric(all_factors[!is.na(all_factors)])))

  ## The plot generators resolve figures_dir, remake_figures and a set of
  ## style/config constants (font, textwidth, methods_dict, ...) as free
  ## variables out of .GlobalEnv - see inst/scripts/plots.R and
  ## ensure_paper_plot_globals() above, modelled on
  ## BExTE-app's ensure_plot_globals()/prepare_plot_globals_for_env(). Unlike
  ## that Shiny module, this is an
  ## exported function a caller can invoke from their own script or
  ## interactive session, so every name it is about to set is snapshotted
  ## first and restored via on.exit(), including the ggplot theme
  ## conf/plots_config.R replaces with theme_set().
  globals_snapshot <- paper_snapshot_globals()
  on.exit(paper_restore_globals(globals_snapshot), add = TRUE)

  ensure_paper_plot_globals()
  assign("figures_dir", figures_dir, envir = .GlobalEnv)
  assign("remake_figures", TRUE, envir = .GlobalEnv)
  ## operating_characteristic_vs_tie() reads analysis_config as a free
  ## variable (for the nominal-TIE reference line) instead of taking it as an
  ## argument, the way plot_metric_vs_drift() and the other entry points
  ## mod_analyze.R calls do. Nothing else assigns it into .GlobalEnv, so
  ## without this every vs-TIE figure aborts with "object 'analysis_config'
  ## not found". It is inside the snapshot/restore window above, so it does
  ## not leak into the caller's session.
  assign("analysis_config", analysis_config, envir = .GlobalEnv)
  ## Same story for case_studies_config_dir, which plot_metric_vs_drift()
  ## and the drift plots read as a free variable to load the case study's
  ## YAML - see R/plot_frequentist_operating_characteristics.R.
  assign("case_studies_config_dir", case_studies_config_dir, envir = .GlobalEnv)

  ## ggplotGrob() measures text before ggsave() ever chooses a device, and
  ## with none open R falls back to getOption("device") - plain pdf() in a
  ## non-interactive session, which cannot load the CID font the Greek
  ## glyphs in the method labels need and fails with "failed to find or
  ## load PDF CID font". Only forest plots hit it, and only once more than
  ## a couple of methods are compared, because a two-method plot's labels
  ## are pure ASCII. cairo_pdf handles them, and is what export_plots()
  ## already writes the figures with.
  if (isTRUE(capabilities("cairo"))) {
    previous_device <- getOption("device")
    options(device = grDevices::cairo_pdf)
    on.exit(options(device = previous_device), add = TRUE)
  }

  ## Runs one entry's generator, writing its tables to `entry_tables_dir` and
  ## its figures to whatever figures_dir .GlobalEnv holds.
  run_generator <- function(entry, entry_tables_dir) {
    tryCatch({
      ctx <- paper_entry_context(
        entry, results_df, results_dir, entry_tables_dir,
        case_studies_config_dir, case_studies, sample_size_factors,
        analysis_config
      )
      entry$generator(ctx)
      list(status = "ok", message = "")
    }, error = function(e) {
      list(status = "failed", message = conditionMessage(e))
    })
  }

  outcomes <- if (workers > 1 && length(entries) > 1 &&
                  .Platform$OS.type == "unix") {
    paper_export_in_parallel(entries, run_generator, figures_dir, tables_dir,
                             workers, progress)
  } else {
    lapply(seq_along(entries), function(index) {
      entry <- entries[[index]]
      if (!is.null(progress)) {
        progress(index, length(entries), entry$id)
      }

      before <- paper_output_snapshot(figures_dir, tables_dir)
      result <- run_generator(entry, tables_dir)
      after <- paper_output_snapshot(figures_dir, tables_dir)

      c(result, list(written = paper_outputs_written(before, after)))
    })
  }

  rows <- lapply(seq_along(entries), function(index) {
    entry <- entries[[index]]
    result <- outcomes[[index]][c("status", "message")]
    written <- outcomes[[index]]$written

    ## A generator handed a slice it has no rows for can return without
    ## raising - plot_success_proba_vs_drift() warns "Dataframe is empty" and
    ## stops there - so "the generator did not error" is not evidence that
    ## anything reached disk. Recording that as "ok" puts a row in the
    ## manifest claiming a figure nobody can open, and inflates the page's
    ## "N of M produced" count; say so instead, so an "ok" row always means a
    ## file exists.
    if (result$status == "ok" && length(written) == 0) {
      result <- list(
        status = "no output",
        message = paste(
          "The generator ran without error but wrote no file. The results",
          "directory most likely has no rows for this item's method,",
          "scenario or sample size."
        )
      )
    }

    data.frame(
      id = entry$id,
      kind = entry$kind,
      caption = entry$caption,
      case_study = entry$case_study,
      target_sample_size_per_arm = if (is.na(entry$case_study)) {
        NA_real_
      } else {
        paper_sample_size_per_arm(entry$case_study, entry$sample_size_factor,
                                  case_studies_config_dir)
      },
      metric = entry$metric,
      status = result$status,
      message = result$message,
      outputs = paste(written, collapse = "; "),
      results_dir = results_dir,
      stringsAsFactors = FALSE
    )
  })

  status <- do.call(rbind, rows)
  readr::write_csv(status, file.path(tables_dir, "manifest.csv"))

  if (!is.null(numbered_dir)) {
    paper_write_numbered_copies(status, entries, numbered_dir)
  }

  writeLines(
    c(
      "# Paper figures and tables",
      "",
      paste0("Generated ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
             " from ", results_dir, "."),
      "",
      "Filenames are the generators' own; `manifest.csv` maps each one to its",
      "paper figure or table number, caption and scenario.",
      "",
      if (is.null(numbered_dir)) {
        "No numbered copies were requested for this export."
      } else {
        paste0("Copies of every paper output, under the same filenames ",
               "(figures as PDF, tables as .tex and .pdf), are in ",
               numbered_dir, ".")
      },
      "",
      "Not produced here: tables S2 (methods and parameters) and S4",
      "(simulation configuration) are hand-authored in the manuscript.",
      "",
      paste0(sum(status$status == "ok"), " of ", nrow(status),
             " items produced successfully.")
    ),
    file.path(tables_dir, "README.md")
  )

  invisible(status)
}
