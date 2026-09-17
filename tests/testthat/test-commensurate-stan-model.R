test_that("commensurate Stan model updates borrowing parameters with target data", {
  stan_code <- commensurate_stan_model()$stan_model_code

  expect_match(
    stan_code,
    "target_treatment_effect_estimate ~ normal\\s*\\(\\s*source_treatment_effect_estimate",
    perl = TRUE
  )
  expect_match(
    stan_code,
    "target_sampling_variance / NT\\s*\\+ 1 / tau\\s*\\+ prior_variance / \\(power_parameter \\* NS\\)",
    perl = TRUE
  )
})


test_that("commensurate sample sizes must be positive", {
  stan_code <- commensurate_stan_model()$stan_model_code

  expect_match(stan_code, "int<lower=1> NS", fixed = TRUE)
  expect_match(stan_code, "int<lower=1> NT", fixed = TRUE)
})


test_that("the commensurate prior's Stan model has no power parameter", {
  stan_code <- commensurate_prior_stan_model()$stan_model_code

  expect_false(grepl("power_parameter", stan_code, fixed = TRUE))
  expect_false(grepl("g_function", stan_code, fixed = TRUE))

  # The gamma == 1 forms of the two terms the power parameter appears in.
  expect_match(
    stan_code,
    "target_sampling_variance / NT\\s*\\+ 1 / tau\\s*\\+ prior_variance / NS",
    perl = TRUE
  )
  expect_match(stan_code, "real u = NS \\+ tau \\* prior_variance;", perl = TRUE)
})


test_that("both commensurate programs declare the same data", {
  # One prepare_data() serves both classes, so a field added to one program's
  # data block and not the other would be passed to a model that does not
  # declare it - which CmdStan rejects at run time, not at compile time.
  data_block <- function(code) {
    sub("(?s).*?(data \\{.*?\\n\\s*\\}).*", "\\1", code, perl = TRUE)
  }

  expect_identical(
    data_block(commensurate_stan_code(TRUE)),
    data_block(commensurate_stan_code(FALSE))
  )
})
