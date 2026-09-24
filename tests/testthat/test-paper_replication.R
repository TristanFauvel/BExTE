## Folding a selection down to the smallest simulation config that still
## reproduces it is the whole point of the page: the full `combined` env is
## HPC-scale and most of its grid is never plotted.

config_dir <- function() {
  paste0(system.file("conf/case_studies", package = "BExTE"), "/")
}

test_that("the four main figures need only botox at factors 2 and 4", {
  requirements <- paper_replication_requirements(c("1", "2", "3", "4"), config_dir())

  expect_equal(requirements$case_studies, "botox")
  expect_setequal(requirements$sample_size_factors, c(2, 4))
})

test_that("the whole manifest needs all six case studies and factors 2, 4 and 6", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  expect_setequal(
    requirements$case_studies,
    c("botox", "belimumab", "dapagliflozin", "mepolizumab", "teriflunomide", "aprepitant")
  )
  expect_setequal(requirements$sample_size_factors, c(2, 4, 6))
  ## Factor 1 is never plotted in the paper.
  expect_false(1 %in% requirements$sample_size_factors)
})

test_that("fidelity settings are fixed regardless of how little is selected", {
  requirements <- paper_replication_requirements("1", config_dir())

  ## forest_plot() picks the three principal scenarios by nearest grid point,
  ## so a coarser drift grid silently plots different drift values.
  expect_equal(requirements$ndrift, 30)
  expect_equal(requirements$n_replicates, 10000)
  expect_equal(requirements$denominator_change_factor, 1)
  expect_equal(requirements$target_to_source_std_ratio_range, 1)
})

test_that("every method is requested, because the forest plots compare all of them", {
  requirements <- paper_replication_requirements("1", config_dir())

  expect_length(requirements$methods, length(PAPER_METHODS))
  expect_true("separate" %in% requirements$methods)
})

test_that("coverage reports a case study missing from the results frame", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))

  coverage <- paper_replication_coverage(df, c("1", "S16"), config_dir())

  ## The fixture is botox at 234 per arm, so neither entry is covered: figure 1
  ## wants 58 per arm and S16 wants belimumab entirely.
  expect_false(coverage$covered[coverage$id == "S16"])
  expect_match(coverage$reason[coverage$id == "S16"], "belimumab")
  expect_false(coverage$covered[coverage$id == "1"])
  expect_match(coverage$reason[coverage$id == "1"], "58")
})

test_that("coverage accepts a slice that is present", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  ## Relabel the fixture as the factor-4 botox slice figure 1 asks for.
  df$target_sample_size_per_arm <- 58

  coverage <- paper_replication_coverage(df, "1", config_dir())

  expect_true(coverage$covered[coverage$id == "1"])
})

test_that("export_paper_outputs records a row per entry and writes a manifest", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    figures_dir <- file.path(getwd(), "figures", "")
    tables_dir <- file.path(getwd(), "tables")

    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = figures_dir,
      tables_dir = tables_dir,
      ids = c("1", "TS1"),
      case_studies_config_dir = config_dir()
    )

    expect_equal(nrow(status), 2)
    expect_true(all(c("id", "status", "outputs") %in% names(status)))
    expect_true(file.exists(file.path(tables_dir, "manifest.csv")))
    expect_true(file.exists(file.path(tables_dir, "README.md")))

    ## The manifest recording two rows is not proof anything was actually
    ## generated: without the plot globals sourced into .GlobalEnv, entry "1"'s
    ## generator (forest_plot()) would abort with "object 'font' not found" (or
    ## similar) and be recorded as "failed" while TS1 alone still produces a
    ## manifest with the expected shape. So assert directly that figure 1 wrote
    ## a real figure file under figures_dir.
    expect_equal(status$status[status$id == "1"], "ok")
    figure_files <- list.files(figures_dir, recursive = TRUE, full.names = TRUE)
    expect_true(any(grepl("\\.(pdf|png)$", figure_files)))
  })
})

test_that("export_paper_outputs marks an entry failed rather than aborting the batch", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ## S16 wants belimumab, which the botox fixture cannot supply.
      ids = c("TS1", "S16"),
      case_studies_config_dir = config_dir()
    )

    expect_equal(status$status[status$id == "TS1"], "ok")
    expect_equal(status$status[status$id == "S16"], "failed")
    expect_true(nzchar(status$message[status$id == "S16"]))
  })
})

test_that("export_paper_outputs restores the caller's .GlobalEnv and ggplot theme", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  ## Guard against a previous run's globals still being set (which would
  ## itself be evidence of the leak this test exists to catch), so the test
  ## reflects a clean caller session regardless of test order.
  if (exists("textwidth", envir = .GlobalEnv, inherits = FALSE)) {
    rm("textwidth", envir = .GlobalEnv)
  }
  had_font_before <- exists("font", envir = .GlobalEnv, inherits = FALSE)
  previous_font <- if (had_font_before) get("font", envir = .GlobalEnv) else NULL
  assign("font", "SENTINEL", envir = .GlobalEnv)
  previous_theme <- ggplot2::theme_get()

  on.exit({
    if (had_font_before) {
      assign("font", previous_font, envir = .GlobalEnv)
    } else if (exists("font", envir = .GlobalEnv, inherits = FALSE)) {
      rm("font", envir = .GlobalEnv)
    }
    ggplot2::theme_set(previous_theme)
  }, add = TRUE)

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = c("1", "TS1"),
      case_studies_config_dir = config_dir()
    )
  })

  ## "font" is a name the conf files also define - the caller's sentinel
  ## value must come back exactly as they left it, not conf/plots_config.R's
  ## "CMU Serif".
  expect_equal(get("font", envir = .GlobalEnv), "SENTINEL")
  ## "textwidth" did not exist before the call, but conf/plots_config.R
  ## defines it - it must not linger in .GlobalEnv afterwards.
  expect_false(exists("textwidth", envir = .GlobalEnv, inherits = FALSE))
  ## conf/plots_config.R calls ggplot2::theme_set(); that must not leak either.
  expect_identical(ggplot2::theme_get(), previous_theme)
})

test_that("export_paper_outputs still attributes outputs on a re-export into the same directories", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    figures_dir <- file.path(getwd(), "figures", "")
    tables_dir <- file.path(getwd(), "tables")

    first <- export_paper_outputs(
      results_dir = results_dir, figures_dir = figures_dir, tables_dir = tables_dir,
      ids = c("1", "TS1"), case_studies_config_dir = config_dir()
    )
    expect_true(nzchar(first$outputs[first$id == "1"]))

    ## Re-export into the same directories: remake_figures is TRUE, so this
    ## overwrites the exact same paths the first run wrote. A before/after
    ## path-list diff would find every path already present in "before" (it
    ## was written by the first run) and report an empty outputs column here -
    ## the failure mode this test exists to catch.
    second <- export_paper_outputs(
      results_dir = results_dir, figures_dir = figures_dir, tables_dir = tables_dir,
      ids = c("1", "TS1"), case_studies_config_dir = config_dir()
    )
    expect_true(nzchar(second$outputs[second$id == "1"]))
  })
})

test_that("a versus-type-I-error figure exports without a missing-import error", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  ## Figure 2 is the botox factor-4 slice, i.e. 58 participants per arm.
  df$target_sample_size_per_arm <- 58

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    figures_dir <- file.path(getwd(), "figures", "")

    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = figures_dir,
      tables_dir = file.path(getwd(), "tables"),
      ## Figure 2 routes through plot_operating_characteristics_vs_tie(),
      ## which calls new_scale_color(). ggnewscale was in neither Imports nor
      ## NAMESPACE, and the only library(ggnewscale) sat inside a different
      ## function in that same file, so every vs-TIE figure (2, 4, S8, S10,
      ## S15, S22, S23, S28, S29, S33) died with `could not find function
      ## "new_scale_color"` no matter how complete the results were.
      ids = "2",
      case_studies_config_dir = config_dir()
    )

    expect_equal(status$status[status$id == "2"], "ok")
    figure_files <- list.files(figures_dir, recursive = TRUE, full.names = TRUE)
    expect_true(any(grepl("\\.(pdf|png)$", figure_files)))
  })
})

test_that("a figure exports even with a plain graphics device left open", {
  ## grid measures text - including the measurement ggplotGrob() does while
  ## assembling guides - on whatever device is current. options(device=) only
  ## decides what gets opened when none is open, so a pdf() device the caller
  ## already has is used as it is, and a plain pdf() device cannot load the
  ## Computer Modern CID font the plot themes ask for. That is why this file
  ## passed on its own and failed inside the suite, where an earlier test file
  ## had left a device open: the figure died on a font error that had nothing
  ## to do with the figure.
  skip_if_not(isTRUE(capabilities("cairo")))

  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  grDevices::pdf(NULL)
  on.exit(while (grDevices::dev.cur() > 1) grDevices::dev.off(), add = TRUE)

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = "2",
      case_studies_config_dir = config_dir()
    )

    expect_equal(status$message[status$id == "2"], "")
    expect_equal(status$status[status$id == "2"], "ok")
  })
})

test_that("a figures directory given without a trailing slash still reports what it wrote", {
  ## The generators build their own paths with paste0(figures_dir, case_study),
  ## so a directory named without a trailing separator concatenates into a
  ## sibling of itself - "figures" and "botox" become "figuresbotox". The
  ## figure is written, but not where the before/after snapshot is watching,
  ## so the run reported "no output" for a file that is on disk. A wrong status
  ## is worse than a missing figure: it sends you looking for a results gap
  ## that is not there.
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    figures_dir <- file.path(getwd(), "figures")
    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = figures_dir,
      tables_dir = file.path(getwd(), "tables"),
      ids = "2",
      case_studies_config_dir = config_dir()
    )

    expect_equal(status$status[status$id == "2"], "ok")
    expect_true(any(grepl(
      "\\.(pdf|png)$",
      list.files(figures_dir, recursive = TRUE)
    )))
    expect_false(dir.exists(paste0(figures_dir, "botox")))
  })
})

test_that("export_paper_outputs does not report ok for an entry that wrote no file", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ## S4 plots the p-value-based power prior, which the pooling/separate
      ## fixture has no rows for. Its generator returns without raising, so
      ## judging success by "the generator did not error" alone recorded S4
      ## as ok with an empty outputs cell - a manifest claiming a figure that
      ## is not on disk, which is worse than an honest failure.
      ids = c("1", "S4"),
      case_studies_config_dir = config_dir()
    )

    expect_equal(status$status[status$id == "1"], "ok")
    expect_false(nzchar(status$outputs[status$id == "S4"]))
    expect_false(status$status[status$id == "S4"] == "ok")
    expect_true(nzchar(status$message[status$id == "S4"]))
  })
})

## ---- Fidelity of an existing results directory ---------------------------
##
## Which scenarios a directory holds is visible in its rows, and
## paper_replication_coverage() checks that. How they were simulated is not:
## a directory holding 2 of the 11 methods at 1000 replicates produces botox
## figures that look like the paper's and are not. That is what took
## results/minimal_test to "13 of 42 covered" while every figure it produced
## was unusable as replication output.

minimal_run_config <- function() {
  list(
    n_replicates = 1000, ndrift = 15,
    case_studies = "botox", methods = c("separate", "pooling"),
    sample_size_factors = c(1, 2, 4)
  )
}

test_that("a smoke-test config is reported as short of the paper's fidelity", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  shortfalls <- paper_config_shortfalls(minimal_run_config(), requirements)

  expect_gt(length(shortfalls), 0)
  expect_true(any(grepl("method", shortfalls)))
  expect_true(any(grepl("replicate", shortfalls)))
  expect_true(any(grepl("drift", shortfalls)))
})

test_that("the config a paper run is launched from has no shortfalls", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  expect_equal(paper_config_shortfalls(requirements, requirements), character(0))
})

test_that("a launched run survives the YAML round-trip its own config makes", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  withr::with_tempdir({
    ## The real path, and the one worth pinning: save_environment() writes
    ## the requirements to user_configs/<env>/scenarios_config.yml and
    ## paper_run_config() reads them back. If yaml round-tripped `methods`
    ## into a nested list or the counts into strings, the page would reject
    ## the very run it had just launched - and the only symptom would be
    ## Step 3 reporting 0 of 42 covered after a full-fidelity run.
    dir.create(file.path("user_configs", "env"), recursive = TRUE)
    yaml::write_yaml(
      requirements, file.path("user_configs", "env", "scenarios_config.yml")
    )

    back <- paper_run_config("results/env")

    expect_type(back$methods, "character")
    expect_length(back$methods, length(requirements$methods))
    expect_equal(paper_config_shortfalls(back, requirements), character(0))
  })
})

test_that("paper_run_config returns NULL when a directory has no saved config", {
  withr::with_tempdir({
    expect_null(paper_run_config("results/never_saved"))
  })
})

test_that("a directory with no saved config cannot be vouched for", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  shortfalls <- paper_config_shortfalls(NULL, requirements)

  expect_gt(length(shortfalls), 0)
})

test_that("coverage refuses figures from a directory short of paper fidelity", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  ## Without the config the rows alone say "covered": botox is present at 58
  ## per arm with a success_proba column.
  rows_only <- paper_replication_coverage(df, c("1", "TS1"), config_dir())
  expect_true(rows_only$covered[rows_only$id == "1"])

  with_config <- paper_replication_coverage(
    df, c("1", "TS1"), config_dir(), run_config = minimal_run_config()
  )

  expect_false(with_config$covered[with_config$id == "1"])
  expect_true(nzchar(with_config$reason[with_config$id == "1"]))
  ## TS1 is built from the case study YAMLs, not from simulation output, so
  ## no amount of missing fidelity makes it unavailable.
  expect_true(with_config$covered[with_config$id == "TS1"])
})

## ---- Simulating only what the selection plots -----------------------------

test_that("each case study is requested only at the factors its own figures use", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())
  per_case_study <- requirements$case_study_sample_size_factors

  ## The paper plots each case study at one or two of the three factors -
  ## mepolizumab only at 68 per arm since figure S26 moved there. Taking the
  ## union of case studies and the union of factors and letting the run cross
  ## them simulated 18 combinations where 11 are wanted - most of a third of
  ## the grid computed and never plotted.
  expect_equal(sum(lengths(per_case_study)), 11)
  expect_lt(
    sum(lengths(per_case_study)),
    length(requirements$case_studies) * length(requirements$sample_size_factors)
  )

  ## Every pair the manifest asks for is present, and nothing else is.
  entries <- Filter(
    function(e) !is.na(e$case_study),
    lapply(paper_manifest_ids(), paper_manifest_entry)
  )
  for (case_study in names(per_case_study)) {
    wanted <- sort(unique(vapply(
      Filter(function(e) identical(e$case_study, case_study), entries),
      function(e) e$sample_size_factor, numeric(1)
    )))
    expect_equal(per_case_study[[case_study]], wanted)
  }
})

test_that("a selection of single-method figures does not request every method", {
  ## S4 draws the p-value-based power prior alone, so simulating all eleven
  ## methods for it means computing the two most expensive ones to plot
  ## neither. separate and pooling stay: the drift plot draws its baselines
  ## from the separate analysis.
  requirements <- paper_replication_requirements("S4", config_dir())

  expect_setequal(requirements$methods, c("separate", "pooling", "p_value_based_PP"))
})

test_that("a forest plot still requires every method", {
  ## Figure 1 compares all of them, so nothing may narrow it.
  requirements <- paper_replication_requirements("1", config_dir())

  expect_length(requirements$methods, length(PAPER_METHODS))
  expect_setequal(requirements$methods, PAPER_METHODS)
})

test_that("mixing a narrow figure with a forest plot widens back to every method", {
  requirements <- paper_replication_requirements(c("S4", "1"), config_dir())

  expect_length(requirements$methods, length(PAPER_METHODS))
})

test_that("an entry declaring no methods is treated as needing all of them", {
  ## A new manifest entry that forgets to declare its methods must not
  ## silently under-simulate and produce a figure missing its comparators.
  expect_equal(paper_required_methods(list(list(methods = NULL))), PAPER_METHODS)
  expect_equal(paper_required_methods(list(list())), PAPER_METHODS)
})

test_that("case_study_factors narrows a block, and leaves unmapped case studies alone", {
  scenarios_config <- list(
    sample_size_factors = c(2, 4, 6),
    case_study_sample_size_factors = list(botox = c(2, 4))
  )

  expect_equal(case_study_factors(scenarios_config, "botox"), c(2, 4))
  ## A case study the map does not mention keeps the run-wide factors, which
  ## is what every config written before the field existed relies on.
  expect_equal(case_study_factors(scenarios_config, "belimumab"), c(2, 4, 6))
  expect_equal(
    case_study_factors(list(sample_size_factors = c(1, 2)), "botox"),
    c(1, 2)
  )
})

test_that("export_paper_outputs leaves the caller's graphics device option alone", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  ## ggplotGrob() measures text before ggsave() picks a device, so with none
  ## open R uses getOption("device") - plain pdf() when running headless,
  ## which cannot load the CID font the Greek glyphs in an 11-method forest
  ## plot's labels need ("failed to find or load PDF CID font"). The export
  ## switches the default to cairo_pdf for its own duration; like the plot
  ## globals and the ggplot theme, that must not leak back to the caller.
  previous_device <- getOption("device")
  on.exit(options(device = previous_device), add = TRUE)
  options(device = previous_device)

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = "TS1",
      case_studies_config_dir = config_dir()
    )
  })

  expect_identical(getOption("device"), previous_device)
})

test_that("export_paper_outputs publishes the free variables the drift plots read", {
  ## plot_metric_vs_drift() and the drift plots resolve case_studies_config_dir
  ## out of .GlobalEnv rather than taking it as an argument - see
  ## R/plot_frequentist_operating_characteristics.R - so S20 failed with
  ## "object 'case_studies_config_dir' not found" until the export assigned
  ## it. Like the rest, it must be gone again afterwards.
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  if (exists("case_studies_config_dir", envir = .GlobalEnv, inherits = FALSE)) {
    rm("case_studies_config_dir", envir = .GlobalEnv)
  }

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = "TS1",
      case_studies_config_dir = config_dir()
    )
  })

  expect_false(exists("case_studies_config_dir", envir = .GlobalEnv, inherits = FALSE))
})

test_that("a paper run computes only the analyses the figures read", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  ## The generators read results_frequentist.csv alone, with the two power
  ## baselines the drift figures compare against. The sweet spot and the
  ## Bayesian OCs are read by nothing in the manifest, and in the 17 September
  ## paper run they took longer than the simulations.
  expect_setequal(
    requirements$analysis_steps,
    c("frequentist_power_at_equivalent_tie", "frequentist_power_at_nominal_tie")
  )
  expect_true(all(requirements$analysis_steps %in% ANALYSIS_STEPS))
})

test_that("a run that skipped a power baseline is short of the paper", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  skipped <- requirements
  skipped$analysis_steps <- "frequentist_power_at_nominal_tie"
  shortfalls <- paper_config_shortfalls(skipped, requirements)
  expect_true(any(grepl("frequentist_power_at_equivalent_tie", shortfalls)))

  ## A config without the key ran every step, which includes both.
  every_step <- requirements
  every_step$analysis_steps <- NULL
  expect_equal(paper_config_shortfalls(every_step, requirements), character(0))
})

test_that("a binomial-likelihood case study is simulated at 1000 replicates", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  ## Aprepitant's binomial likelihood is fitted by MCMC for the conditional
  ## power prior, replicate by replicate; every other case study uses a normal
  ## likelihood and keeps the paper's 10000.
  expect_equal(case_study_n_replicates(requirements, "aprepitant"), 1000)
  for (case_study in setdiff(requirements$case_studies, "aprepitant")) {
    expect_equal(case_study_n_replicates(requirements, case_study), 10000,
                 info = case_study)
  }
})

test_that("a case study analysed under the normal approximation keeps 10000", {
  withr::with_tempdir({
    case_study <- yaml::read_yaml(file.path(config_dir(), "aprepitant.yml"))
    case_study$summary_measure_likelihood <- "normal"
    dir.create("case_studies")
    for (file in list.files(config_dir(), pattern = "\\.yml$")) {
      file.copy(file.path(config_dir(), file), file.path("case_studies", file))
    }
    yaml::write_yaml(case_study, file.path("case_studies", "aprepitant.yml"))

    requirements <- paper_replication_requirements(
      paper_manifest_ids(), "case_studies/"
    )
    expect_equal(case_study_n_replicates(requirements, "aprepitant"), 10000)
  })
})

test_that("a run with too few replicates for one case study is short", {
  requirements <- paper_replication_requirements(paper_manifest_ids(), config_dir())

  short <- requirements
  short$case_study_n_replicates <- list(aprepitant = 100)
  shortfalls <- paper_config_shortfalls(short, requirements)
  expect_true(any(grepl("aprepitant", shortfalls)))

  ## More replicates than required is only a tighter Monte Carlo error.
  generous <- requirements
  generous$case_study_n_replicates <- NULL
  expect_equal(paper_config_shortfalls(generous, requirements), character(0))
})
