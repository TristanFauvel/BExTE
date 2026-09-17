## The versus-type-I-error figures draw one point per method-parameter
## combination. Every combination the run simulated is about 45 points behind
## a legend taller than the panel, so the paper shows a curated subset.

## testthat runs from tests/testthat, so a results directory at the project
## root has to be reached explicitly rather than by a bare relative path -
## otherwise these skip silently and the subset is never checked against real
## data, which is the only place its combination count means anything.
local_botox_slice <- function() {
  env_file <- "/tmp/bexte_current_env"
  skip_if_not(file.exists(env_file), "no completed run to read")
  env <- readLines(env_file)
  path <- testthat::test_path("..", "..", "results", env, "results_frequentist.csv")
  skip_if_not(file.exists(path), "no results_frequentist.csv")
  df <- readr::read_csv(path, show_col_types = FALSE)
  ## A run that predates a method the subset names cannot satisfy the counts
  ## below, and would fail for its vintage rather than for the subset logic.
  skip_if_not(
    all(names(PAPER_VS_TIE_COMBINATIONS) %in% df$method),
    "the completed run predates a method the vs-TIE panels show"
  )
  df[df$case_study == "botox" & df$target_sample_size_per_arm == 117, ]
}

test_that("the subset names exactly the methods the paper's vs-TIE panels show", {
  expect_setequal(
    names(PAPER_VS_TIE_COMBINATIONS),
    c("pooling", "separate", "EB_PP", "RMP", "conditional_power_prior",
      "commensurate_power_prior", "commensurate_prior", "p_value_based_PP",
      "NPP", "egidi_empirical_mixture")
  )
  ## Test-then-pool and PDCCPP are deliberately absent from these panels.
  expect_false("test_then_pool_equivalence" %in% names(PAPER_VS_TIE_COMBINATIONS))
  expect_false("test_then_pool_difference" %in% names(PAPER_VS_TIE_COMBINATIONS))
  expect_false("PDCCPP" %in% names(PAPER_VS_TIE_COMBINATIONS))
})

test_that("the parameter grids are thinned to their informative range", {
  ## RMP keeps the interior weights: w = 0 is the separate analysis and w = 1
  ## is pooling, both of which the panel already shows under their own names.
  expect_equal(PAPER_VS_TIE_COMBINATIONS$RMP$prior_weight, seq(0.1, 0.9, by = 0.1))
  expect_false(0 %in% PAPER_VS_TIE_COMBINATIONS$RMP$prior_weight)
  expect_false(1 %in% PAPER_VS_TIE_COMBINATIONS$RMP$prior_weight)

  expect_equal(
    PAPER_VS_TIE_COMBINATIONS$conditional_power_prior$power_parameter,
    c(0.25, 0.5, 0.75)
  )
})

test_that("the subset selects 24 combinations from a real results slice", {
  df <- local_botox_slice()

  kept <- paper_vs_tie_subset(df)
  combinations <- unique(kept[, c("method", "parameters")])

  ## 1 pooling + 1 separate + 1 EBPP + 9 RMP + 3 conditional PP
  ## + 3 commensurate PP and 3 commensurate prior (the inverse-gamma priors
  ## of each) + 1 p-PP + 1 NPP + 1 empirical mixture prior, whose weight is
  ## selected rather than swept and so has a single combination.
  expect_equal(nrow(combinations), 24)
  expect_lt(nrow(kept), nrow(df))
})

test_that("the subset drops the methods the panel does not show", {
  df <- local_botox_slice()

  kept <- paper_vs_tie_subset(df)

  expect_false(any(kept$method %in% c("test_then_pool_equivalence",
                                      "test_then_pool_difference", "PDCCPP")))
  expect_setequal(unique(kept$method), names(PAPER_VS_TIE_COMBINATIONS))
})

test_that("only the inverse-gamma commensurate priors survive", {
  df <- local_botox_slice()

  kept <- paper_vs_tie_subset(df)

  ## Both commensurate methods run the same heterogeneity prior grid and both
  ## are thinned to its inverse-gamma half.
  for (method in c("commensurate_power_prior", "commensurate_prior")) {
    commensurate <- kept[kept$method == method, ]
    families <- get_parameters(commensurate[, "parameters"])$heterogeneity_prior.family

    expect_equal(nrow(commensurate) / length(unique(commensurate$drift)), 3,
                 info = method)
    expect_setequal(unique(families), "inverse_gamma")
  }
})

test_that("the subset works on a plain data frame, not only a tibble", {
  ## readr hands back a tibble, where `df[, "parameters"]` keeps its
  ## dimensions; a plain data frame drops it to a bare vector and
  ## get_parameters() then fails on an atomic argument. The fixture is a plain
  ## data frame, which is how this surfaced.
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  expect_false(tibble::is_tibble(df))

  kept <- paper_vs_tie_subset(df)

  expect_equal(nrow(kept), nrow(df))
  expect_setequal(unique(kept$method), c("pooling", "separate"))
})

test_that("a method whose parameter column is absent matches nothing", {
  ## Selecting RMP by prior_weight against a frame that never recorded it must
  ## drop RMP, not shorten the running match vector to zero length - which
  ## silently broke the whole filter.
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$method <- "RMP"

  expect_silent(kept <- paper_vs_tie_subset(df))
  expect_equal(nrow(kept), 0)
})
