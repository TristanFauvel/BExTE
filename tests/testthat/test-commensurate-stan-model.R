test_that("commensurate Stan model updates borrowing parameters with target data", {
  stan_code <- commensurate_stan_model()$stan_model_code

  expect_match(
    stan_code,
    "target_treatment_effect_estimate ~ normal\\s*\\(\\s*source_treatment_effect_estimate",
    perl = TRUE
  )
  expect_match(
    stan_code,
    "target_sampling_variance / NT\\s*\\+ inverse_tau\\s*\\+ prior_variance / a;",
    perl = TRUE
  )
  expect_match(stan_code, "real a = power_parameter * NS;", fixed = TRUE)
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
    "target_sampling_variance / NT\\s*\\+ inverse_tau\\s*\\+ prior_variance / NS",
    perl = TRUE
  )
  expect_match(
    stan_code,
    "real u_over_tau = NS * inverse_tau + prior_variance;",
    fixed = TRUE
  )
})


test_that("both commensurate programs sample log(tau) and never form tau^2", {
  # tau^2 overflows at log(tau) of about 354, which the inverse_gamma(1/1000, 1)
  # prior reaches, and tau itself at about 709, beyond which a Cauchy(0, 30)
  # prior on log(tau) puts about 3% of its mass. The model block therefore
  # works in 1 / tau, and tau is only formed for the output.
  model_block <- function(code) {
    block <- sub("(?s).*?(model \\{.*?)generated quantities.*", "\\1", code, perl = TRUE)
    gsub("//[^\n]*", "", block, perl = TRUE)
  }

  for (with_power_parameter in c(TRUE, FALSE)) {
    stan_code <- commensurate_stan_code(with_power_parameter)

    expect_match(stan_code, "real log_tau;", fixed = TRUE)
    expect_match(stan_code, "real tau = exp(log_tau);", fixed = TRUE)
    expect_false(grepl("real<lower=0> tau", stan_code, fixed = TRUE))
    expect_false(grepl("\\btau(\\^|2|\\s*\\*)", model_block(stan_code), perl = TRUE))
  }
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
