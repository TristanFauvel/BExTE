test_that("configuration names are restricted to safe path components", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))

  expect_invisible(bexte_validate_name("trial_01-a", "environment"))
  expect_error(bexte_validate_name("Trial 01", "environment"), "lowercase")
  expect_error(bexte_validate_name("../trial", "environment"), "lowercase")
  expect_error(bexte_validate_name("", "environment"), "Give the environment a name")
})

test_that("numeric grid fields reject malformed and non-positive values", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))

  expect_equal(bexte_parse_number_list("1, 2.5, 4", "Factors"), c(1, 2.5, 4))
  expect_error(bexte_parse_number_list("1, nope", "Factors"), "comma-separated")
  expect_error(bexte_parse_number_list("1, 0", "Factors"), "greater than zero")
  expect_error(bexte_parse_number_list("1,", "Factors"), "comma-separated")
})

test_that("case study validation rejects impossible response counts", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))

  expect_error(
    build_and_save_case_study(
      name = "invalid_case", control_arm_name = "Placebo",
      endpoint = "binary", null_space = "left",
      target_control_n = 10, target_treatment_n = 10,
      source_control_n = 20, source_treatment_n = 20,
      target_control_responses = 11, target_treatment_responses = 5,
      source_control_responses = 8, source_treatment_responses = 10
    ),
    "no more than 10"
  )
})

test_that("method choices retain internal values and show readable labels", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))

  choices <- bexte_method_choices(c("pooling", "commensurate_power_prior"))
  expect_equal(unname(choices), c("pooling", "commensurate_power_prior"))
  expect_named(choices, c("Pooled analysis", "Commensurate power prior"))
})

test_that("Analyze only offers Bayesian plots when Bayesian results exist", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))
  source(system.file("shiny_app/modules/mod_analyze.R", package = "BExTE"))

  frequentist_only <- available_plot_kinds(list(bayes_simpson = NULL))
  with_bayesian <- available_plot_kinds(list(bayes_simpson = data.frame(x = 1)))
  expect_false(any(grepl("^bayes", unname(frequentist_only))))
  expect_true(all(c("bayes_vs_sample_size", "bayes_vs_parameters", "bayes_forest_plot") %in%
                    unname(with_bayesian)))
})

test_that("Analyze table applies sample-size and metric controls", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))
  source(system.file("shiny_app/modules/mod_analyze.R", package = "BExTE"))

  results <- data.frame(
    case_study = c("a", "a", "b"),
    method = c("pooling", "pooling", "separate"),
    target_sample_size_per_arm = c(50, 100, 50),
    drift = c(0, 0.1, 0),
    success_proba = c(0.7, 0.8, 0.6),
    conf_int_success_proba_lower = c(0.6, 0.7, 0.5),
    bias = c(0.1, 0.2, 0.3)
  )
  filtered <- filter_results_table(
    results, case_study = "a", method = "pooling", sample_size = 100,
    metric = "success_proba"
  )

  expect_equal(nrow(filtered), 1)
  expect_equal(filtered$target_sample_size_per_arm, 100)
  expect_true("success_proba" %in% names(filtered))
  expect_false("bias" %in% names(filtered))
})

test_that("results picker only lists directories Analyze can load", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))
  test_dir <- tempfile("bexte-results-")
  dir.create(test_dir)
  withr::local_dir(test_dir)
  dir.create("results/ready", recursive = TRUE)
  dir.create("results/partial", recursive = TRUE)
  writeLines("case_study,method", "results/ready/results_frequentist.csv")
  writeLines("case_study,method", "results/partial/results_bayesian_mc.csv")

  expect_equal(list_results_dirs(), file.path("results", "ready"))
})

test_that("status messages expose their urgency to assistive technology", {
  source(system.file("shiny_app/theme.R", package = "BExTE"))

  ok <- as.character(bexte_status("Saved", ok = TRUE))
  error <- as.character(bexte_status("Invalid", ok = FALSE))
  expect_match(ok, 'role="status"', fixed = TRUE)
  expect_match(ok, 'aria-live="polite"', fixed = TRUE)
  expect_match(error, 'role="alert"', fixed = TRUE)
  expect_match(error, 'aria-live="assertive"', fixed = TRUE)
})

test_that("Replicate adopts the results directory a finished run produced", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))
  source(system.file("shiny_app/modules/mod_replicate.R", package = "BExTE"))

  ## Step 2 writes results/<env>/, but the Step 1 dropdown is populated once
  ## at module init, so Step 3 kept exporting from whatever was selected
  ## before the run - typically a small smoke-test directory - and every
  ## figure the run was launched for failed with "No rows for ...".
  dirs <- c("results/paper_replication_20260911_150923", "results/minimal_test")

  expect_equal(
    completed_run_results_dir("paper_replication_20260911_150923", dirs),
    "results/paper_replication_20260911_150923"
  )

  ## An interrupted run leaves per-case-study/method files but never the
  ## concatenated results_frequentist.csv, so list_results_dirs() omits it.
  ## Selecting it anyway would swap a stale export for a broken one.
  expect_null(completed_run_results_dir("paper_replication_20260911_161500", dirs))
  expect_null(completed_run_results_dir(NULL, dirs))
})

test_that("Replicate starts on the newest results directory that is paper-faithful", {
  source(system.file("shiny_app/helpers.R", package = "BExTE"))
  source(system.file("shiny_app/modules/mod_replicate.R", package = "BExTE"))

  cfg <- paste0(system.file("conf/case_studies", package = "BExTE"), "/")
  requirements <- paper_replication_requirements(paper_manifest_ids(), cfg)

  faithful <- requirements
  smoke <- list(
    n_replicates = 1000, ndrift = 15,
    case_studies = "botox", methods = c("separate", "pooling")
  )
  configs <- list(
    "results/smoke_2" = smoke,
    "results/paper_run" = faithful,
    "results/smoke_1" = smoke
  )
  reader <- function(dir) configs[[dir]]

  ## list_results_dirs() returns newest first, so the first qualifying entry
  ## is the newest one - and a smoke-test directory sorting ahead of it must
  ## not win just for being recent.
  expect_equal(
    default_results_dir(names(configs), requirements, reader),
    "results/paper_run"
  )

  ## Nothing faithful: start on no selection rather than silently landing on
  ## a directory whose figures would not be the paper's.
  expect_equal(
    default_results_dir(c("results/smoke_2", "results/smoke_1"), requirements, reader),
    ""
  )
  expect_equal(default_results_dir(character(0), requirements, reader), "")
})
