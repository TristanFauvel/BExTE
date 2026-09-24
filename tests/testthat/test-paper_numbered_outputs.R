## The generators name their files after the scenario they plot, which is what
## makes them recognisable inside a results directory but useless for reading
## the paper alongside them: manifest.csv is the only thing that says which
## file is figure S33. A second copy of each output, named by its paper
## number, is what you actually hand someone.

config_dir <- function() {
  paste0(system.file("conf/case_studies", package = "BExTE"), "/")
}

test_that("figures and tables are labelled the way the paper refers to them", {
  expect_equal(paper_numbered_label(paper_manifest_entry("1")), "Figure 1")
  expect_equal(paper_numbered_label(paper_manifest_entry("S33")), "Figure S33")
  ## The manifest's table ids carry a "T" prefix that the paper does not:
  ## TS1 is the paper's table S1.
  expect_equal(paper_numbered_label(paper_manifest_entry("TS1")), "Table S1")
  expect_equal(paper_numbered_label(paper_manifest_entry("TS3")), "Table S3")
})

test_that("a numbered copy of each produced output is written", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))
  df$target_sample_size_per_arm <- 58

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))
    numbered_dir <- file.path(getwd(), "by_paper_number")

    status <- export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = c("1", "TS1"),
      case_studies_config_dir = config_dir(),
      numbered_dir = numbered_dir
    )

    expect_true(dir.exists(numbered_dir))
    produced <- list.files(numbered_dir)

    ## Figures are wanted as PNG - the format that drops straight into a
    ## document or a slide - not as the PDF the generators also write.
    expect_true("Figure 1.png" %in% produced)
    expect_false(any(grepl("^Figure 1\\.pdf$", produced)))

    ## Tables keep both: the .tex is what the manuscript includes, the .pdf is
    ## what you look at.
    expect_true("Table S1.tex" %in% produced)
    expect_true("Table S1.pdf" %in% produced)

    ## The copies are real files, not empty placeholders.
    expect_gt(file.info(file.path(numbered_dir, "Figure 1.png"))$size, 0)
  })
})

test_that("an item that produced nothing gets no numbered copy", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))
    numbered_dir <- file.path(getwd(), "by_paper_number")

    ## S16 wants belimumab, which the botox fixture cannot supply, so it
    ## fails - a numbered file for it would claim a figure that was never
    ## drawn, which is exactly what the manifest's honest statuses exist to
    ## prevent.
    export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = c("TS1", "S16"),
      case_studies_config_dir = config_dir(),
      numbered_dir = numbered_dir
    )

    produced <- list.files(numbered_dir)
    expect_false(any(grepl("^Figure S16", produced)))
    expect_true("Table S1.tex" %in% produced)
  })
})

test_that("the numbered folder is optional", {
  df <- readRDS(testthat::test_path("fixtures", "forest_plot_freq.rds"))

  withr::with_tempdir({
    results_dir <- file.path(getwd(), "results")
    dir.create(results_dir)
    readr::write_csv(df, file.path(results_dir, "results_frequentist.csv"))

    ## Callers that predate the argument must behave exactly as before.
    expect_no_error(export_paper_outputs(
      results_dir = results_dir,
      figures_dir = file.path(getwd(), "figures", ""),
      tables_dir = file.path(getwd(), "tables"),
      ids = "TS1",
      case_studies_config_dir = config_dir()
    ))

    expect_false(dir.exists(file.path(getwd(), "by_paper_number")))
  })
})

## export_plots() resolves dpi as a free variable out of .GlobalEnv, the way
## the plot code resolves font and textwidth - conf/plots_config.R supplies it
## in a real run. Set it for the duration and put .GlobalEnv back afterwards.
local_plot_dpi <- function(value = 300, env = parent.frame()) {
  existed <- exists("dpi", envir = .GlobalEnv, inherits = FALSE)
  previous <- if (existed) get("dpi", envir = .GlobalEnv) else NULL
  assign("dpi", value, envir = .GlobalEnv)
  withr::defer({
    if (existed) {
      assign("dpi", previous, envir = .GlobalEnv)
    } else {
      rm("dpi", envir = .GlobalEnv)
    }
  }, envir = env)
}

test_that("PNG figures are written on an opaque white background", {
  ## A transparent PNG renders as whatever sits behind it - black, in a dark
  ## viewer - which is how 21 of the 34 exported figures came out: ggsave()
  ## falls back to the theme's background when bg is NULL, and the forest
  ## plots skip the theme_bw() adjustment that would have supplied white.
  skip_if_not_installed("png")
  local_plot_dpi()

  withr::with_tempdir({
    plt <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
      ggplot2::geom_point() +
      ## The transparent-background theme the forest plots effectively use.
      ggplot2::theme(
        plot.background = ggplot2::element_rect(fill = "transparent", colour = NA),
        panel.background = ggplot2::element_rect(fill = "transparent", colour = NA)
      )

    export_plots(plt, file.path(getwd(), "fig"), 4, 3, type = "png", forest_plot = TRUE)

    raster <- png::readPNG(file.path(getwd(), "fig.png"))
    ## Either no alpha channel at all, or one that is fully opaque.
    if (dim(raster)[3] == 4) {
      expect_equal(min(raster[, , 4]), 1)
    } else {
      expect_equal(dim(raster)[3], 3)
    }
    ## The corner pixel is white, not the viewer's background showing through.
    expect_equal(as.numeric(raster[1, 1, 1:3]), c(1, 1, 1))
  })
})

test_that("an explicit background still wins", {
  skip_if_not_installed("png")
  local_plot_dpi()

  withr::with_tempdir({
    ## The device background only shows through where the plot's own
    ## background is transparent - the default theme paints opaque white over
    ## it - so this is the case where `bg` is observable at all.
    plt <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
      ggplot2::geom_point() +
      ggplot2::theme(
        plot.background = ggplot2::element_rect(fill = "transparent", colour = NA)
      )

    export_plots(plt, file.path(getwd(), "fig"), 4, 3, type = "png",
                 forest_plot = TRUE, bg = "red")

    raster <- png::readPNG(file.path(getwd(), "fig.png"))
    expect_gt(raster[1, 1, 1], 0.5)
    expect_lt(raster[1, 1, 2], 0.5)
  })
})
