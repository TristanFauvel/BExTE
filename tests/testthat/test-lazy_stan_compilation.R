# The commensurate models run every simulation replicate through a quadrature
# mixture and only sample with Stan when inference() is asked for a single fit.
# Their Stan program is therefore compiled on first use rather than when the
# model is built, which these tests pin.

lazy_prior <- function() {
  commensurate_fast_path_prior(list(family = "half_normal", std_dev = 1))
}

counting_compiler <- function(calls) {
  function(model_name, stan_model_code, ...) {
    calls$names <- c(calls$names, model_name)
    list(sample = function(...) stop("sampled", call. = FALSE))
  }
}

test_that("building a commensurate model compiles nothing", {
  for (generator in list(GaussianCommensuratePowerPrior, GaussianCommensuratePrior)) {
    calls <- new.env()
    model <- testthat::with_mocked_bindings(
      generator$new(prior = lazy_prior(), mcmc_config = commensurate_mcmc_config()),
      compile_stan_model = counting_compiler(calls),
      .package = "BExTE"
    )
    expect_null(calls$names)
    expect_null(model$stan_model)
    expect_match(model$stan_model_name, "_half_normal$")
  }
})

test_that("the Stan program is compiled once, when the model first samples", {
  calls <- new.env()
  testthat::with_mocked_bindings({
    model <- GaussianCommensuratePowerPrior$new(
      prior = lazy_prior(), mcmc_config = commensurate_mcmc_config()
    )
    first <- model$stan_sampler()
    second <- model$stan_sampler()
  },
  compile_stan_model = counting_compiler(calls),
  .package = "BExTE"
  )

  expect_identical(calls$names, "gaussian_commensurate_pp_half_normal")
  expect_identical(first, second)
})

test_that("a model with no Stan program says so rather than failing obscurely", {
  model <- commensurate_model(lazy_prior())
  model$stan_model_name <- NULL
  expect_error(model$stan_sampler(), "no Stan program")
})
