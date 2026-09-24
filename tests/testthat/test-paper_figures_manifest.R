## The manifest is the only place that records which generator call produces a
## given paper figure. These tests pin the two things a reader cannot verify by
## eye: that the ids are complete and unique, and that every sample-size factor
## resolves to the per-arm size the published caption states.

test_that("the manifest covers every paper item exactly once", {
  ids <- paper_manifest_ids()

  expect_length(ids, 52)
  expect_length(unique(ids), 52)
  expect_true(all(c("1", "2", "3", "4") %in% ids))
  expect_true(all(paste0("S", 3:37) %in% ids))
  ## S38-S44 are the interval-score figures added in revision.
  expect_true(all(paste0("S", 38:44) %in% ids))
  ## Tables S2 and S4 are hand-authored in the manuscript.
  expect_true(all(c("TS1", "TS3", "TS5") %in% ids))
  expect_false(any(c("TS2", "TS4", "TS7", "TS8") %in% ids))
  expect_true(all(c("X1", "X2", "X3") %in% ids))
  expect_true("S8" %in% ids)
})

test_that("every entry is well formed and its generator is callable", {
  for (entry in paper_manifest()) {
    expect_true(is.character(entry$id) && nzchar(entry$id))
    expect_true(entry$kind %in% c("figure", "table"))
    expect_true(is.character(entry$caption) && nzchar(entry$caption))
    expect_true(entry$needs %in% c("frequentist", "configs", "run_artifact"))
    expect_true(is.function(entry$generator))
  }
})

test_that("every case study named in the manifest has a config", {
  for (entry in paper_manifest()) {
    if (is.na(entry$case_study)) next
    path <- system.file(
      file.path("conf/case_studies", paste0(entry$case_study, ".yml")),
      package = "BExTE"
    )
    expect_true(nzchar(path), info = entry$id)
  }
})

test_that("sample size factors resolve to the per-arm sizes the captions state", {
  config_dir <- paste0(system.file("conf/case_studies", package = "BExTE"), "/")

  expected <- list(
    list("botox", 2, 117), list("botox", 4, 58),
    list("belimumab", 4, 140), list("belimumab", 6, 93),
    list("dapagliflozin", 2, 66), list("dapagliflozin", 4, 33),
    list("mepolizumab", 4, 68), list("mepolizumab", 6, 45),
    list("teriflunomide", 4, 185), list("teriflunomide", 6, 123),
    list("aprepitant", 2, 143), list("aprepitant", 4, 71)
  )

  for (case in expected) {
    expect_equal(
      paper_sample_size_per_arm(case[[1]], case[[2]], config_dir),
      case[[3]],
      info = paste(case[[1]], "factor", case[[2]])
    )
  }
})

test_that("the headline figures name the slice their captions describe", {
  fig1 <- paper_manifest_entry("1")
  expect_equal(fig1$case_study, "botox")
  expect_equal(fig1$sample_size_factor, 4)
  expect_equal(fig1$metric, "success_proba")

  fig3 <- paper_manifest_entry("3")
  expect_equal(fig3$case_study, "botox")
  expect_equal(fig3$sample_size_factor, 2)
  expect_equal(fig3$metric, "mse")

  table_s5 <- paper_manifest_entry("TS5")
  expect_equal(table_s5$case_study, "belimumab")
  expect_equal(table_s5$sample_size_factor, 4)
  expect_equal(table_s5$metric, "precision_ecp")
})

test_that("the interval-score figures accompany the precision and coverage ones", {
  ## Each new figure has to plot the same slice as the figure it is read
  ## against, or the pair says nothing: a score on belimumab at 140 per arm
  ## cannot be compared with a half-width on a different sample size.
  pairs <- list(
    list(new = "S38", existing = "S11"),
    list(new = "S39", existing = "S19"),
    list(new = "S39", existing = "S21"),
    list(new = "S40", existing = "S25"),
    list(new = "S41", existing = "S35"),
    list(new = "S42", existing = "S8"),
    list(new = "S43", existing = "S23"),
    list(new = "S44", existing = "S29")
  )

  for (pair in pairs) {
    new_entry <- paper_manifest_entry(pair$new)
    existing <- paper_manifest_entry(pair$existing)

    expect_equal(new_entry$metric, "interval_score", info = pair$new)
    expect_equal(new_entry$case_study, existing$case_study, info = pair$new)
    expect_equal(new_entry$sample_size_factor, existing$sample_size_factor,
                 info = pair$new)
  }
})

test_that("the added ids sort after the manuscript's own supplement", {
  ## paper_manifest() orders by the numeric part of the id, so an id that is
  ## not S<number> would sort as NA and land at the end silently.
  ids <- paper_manifest_ids()
  figures <- ids[startsWith(ids, "S")]

  expect_equal(tail(figures, 7), paste0("S", 38:44))
})

test_that("unnumbered manuscript figures use their requested scenarios", {
  expected <- list(
    X1 = list(case_study = "botox", sample_size_factor = 2, metric = "coverage"),
    X2 = list(case_study = "mepolizumab", sample_size_factor = 4, metric = "coverage"),
    X3 = list(case_study = "teriflunomide", sample_size_factor = 6, metric = "coverage")
  )
  for (id in names(expected)) {
    entry <- paper_manifest_entry(id)
    expect_equal(entry$case_study, expected[[id]]$case_study)
    expect_equal(entry$sample_size_factor, expected[[id]]$sample_size_factor)
    expect_equal(entry$metric, expected[[id]]$metric)
  }
})

test_that("paper_manifest_entry rejects an unknown id", {
  expect_error(paper_manifest_entry("S99"), "S99")
})
