## The three panels are the source effect times 0, 1/2 and 1, labelled "No
## treatment effect", "Partially consistent" and "Consistent" in the order the
## rows are sorted into. Sorting on the signed effect puts the largest benefit
## first whenever the source effect is negative - teriflunomide (-0.411) and
## mepolizumab (-0.693), where benefit is a negative log rate ratio - which
## labelled the full effect as the null and the null as the full effect,
## swapping two of the three panels.
##
## Figure S31 is where this showed: every method, separate included, appeared
## to have a type I error rate around 0.84, because the panel was really
## showing power under the full effect.

panel_order <- function(source_effect) {
  effects <- source_effect * c(0, 0.5, 1)
  list(signed = effects[order(effects)], distance = effects[order(abs(effects))])
}

test_that("a negative source effect no longer puts the full effect first", {
  ordering <- panel_order(-0.393)

  ## What the old sort did: the full effect labelled "No treatment effect".
  expect_equal(ordering$signed[1], -0.393)
  ## What sorting by distance from no effect does.
  expect_equal(ordering$distance[1], 0)
  expect_equal(abs(ordering$distance[3]), 0.393)
})

test_that("a positive source effect is unaffected", {
  ## Botox, belimumab, dapagliflozin and aprepitant all have positive source
  ## effects, so both orderings agree and their figures never changed.
  for (source_effect in c(0.2, 0.4810147, 0.36, 0.1315456)) {
    ordering <- panel_order(source_effect)
    expect_equal(ordering$signed, ordering$distance, info = source_effect)
    expect_equal(ordering$distance[1], 0)
  }
})

test_that("the null scenario is always first, whatever the sign", {
  for (source_effect in c(-0.6931472, -0.393, 0.2, 0.481)) {
    expect_equal(panel_order(source_effect)$distance[1], 0, info = source_effect)
  }
})

test_that("the case studies with negative source effects are the ones affected", {
  config_dir <- paste0(system.file("conf/case_studies", package = "BExTE"), "/")
  negative <- character(0)
  for (path in list.files(config_dir, pattern = "\\.yml$", full.names = TRUE)) {
    config <- yaml::read_yaml(path)
    if (config$source$treatment_effect < 0) {
      negative <- c(negative, sub("\\.yml$", "", basename(path)))
    }
  }
  expect_setequal(negative, c("mepolizumab", "teriflunomide"))
})
