# The pdf plots are methods, so they must read the densities of the model they
# are called on. They used to read a variable named `model` from the calling
# environment instead, which either did not exist or was a different model.

known_densities_model <- function() {
  test_model_class <- R6::R6Class(
    "KnownDensitiesTestModel",
    inherit = Model,
    public = list(
      prior_pdf = function(x) stats::dnorm(x, 0, 1),
      posterior_pdf = function(x) stats::dnorm(x, 1, 0.5)
    )
  )
  test_model_class$new()
}

plotted_y <- function(plot) {
  ggplot2::layer_data(plot)$y
}

test_that("the pdf plots draw the densities of the model they are called on", {
  model <- known_densities_model()
  x <- seq(-2, 2, length.out = 10)

  expect_equal(
    plotted_y(model$plot_prior_pdf(resolution = 10)),
    stats::dnorm(x, 0, 1)
  )
  expect_equal(
    plotted_y(model$plot_posterior_pdf(resolution = 10)),
    stats::dnorm(x, 1, 0.5)
  )

  both <- ggplot2::layer_data(model$plot_pdfs(resolution = 10))
  expect_setequal(both$y, c(stats::dnorm(x, 0, 1), stats::dnorm(x, 1, 0.5)))
})

test_that("the pdf plots do not read a `model` from the calling environment", {
  plot_from_elsewhere <- function(target) {
    model <- NULL
    target$plot_prior_pdf(resolution = 10)
  }

  expect_s3_class(plot_from_elsewhere(known_densities_model()), "ggplot")
})
