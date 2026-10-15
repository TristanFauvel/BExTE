# The Gaussian empirical Bayes power priors compute the power parameter with
# one implementation, shared by the replicate loop and the vectorised path. The
# kernel equivalence tests therefore compare that implementation with itself.
# These values, recorded from the earlier separate implementations, are the
# independent check on the numbers.

eb_regression_config <- function() {
  list(
    name = "unit_test", endpoint = "continuous",
    summary_measure_likelihood = "normal", sampling_approximation = TRUE,
    theta_0 = 0, null_space = "left",
    source = list(control = 562, treatment = 563,
                  treatment_effect = 0.481, standard_error = 0.1208)
  )
}

eb_regression_parameters <- function(method) {
  base <- list(initial_prior = list("noninformative"))
  switch(
    method,
    EB_PP = base,
    PDCCPP = c(base, list(desired_tie = list(0.065), significance_level = list(0.05),
                          tolerance = list(1e-4), n_iter = list(1e6))),
    p_value_based_PP = c(base, list(shape_parameter = list(1),
                                    equivalence_margin = list(0.1)))
  )
}

# Deviations of the target estimate from the source estimate. They span no
# borrowing, partial borrowing and full borrowing, on both sides.
eb_regression_deviations <- c(0, 0.05, 0.12, 0.2, 0.3, 0.5, -0.3, -0.6)

eb_regression_expected <- list(
  EB_PP = c(1, 1, 1, 1, 0.317922440087146, 0.0708724623603691,
            0.317922440087146, 0.046193858816081),
  PDCCPP = c(1, 1, 0.0581291958053999, 0.0188115441680824, 0.00810471320531432,
             0.00287266617737492, 0.00810471320531432, 0.00198962927612542),
  p_value_based_PP = c(0.532160951654992, 0.393675852379176, 0.196147977461053,
                       0.0421668867647315, 0.000456549058206793, 5.4213313791492e-26,
                       0.000456549058206787, 8.6232081091583e-81)
)

eb_regression_model <- function(method) {
  config <- eb_regression_config()
  source_data <- SourceData$new(config)
  model <- Model$new()$create(
    case_study_config = config, method = method,
    method_parameters = eb_regression_parameters(method),
    source_data = source_data
  )
  list(model = model, source_data = source_data)
}

eb_regression_target <- function(source_data, deviation) {
  ObservedTargetData$new(source_data$treatment_effect_estimate + deviation, 0.21, 52,
                         summary_measure_likelihood = "normal")
}

for (method in names(eb_regression_expected)) {
  test_that(paste0("the ", method, " power parameter keeps its recorded values"), {
    fixture <- eb_regression_model(method)

    got <- vapply(eb_regression_deviations, function(deviation) {
      fixture$model$power_parameter_estimation(
        eb_regression_target(fixture$source_data, deviation)
      )
    }, numeric(1))

    expect_equal(got, eb_regression_expected[[method]], tolerance = 1e-10)
  })
}
