## tipping_point() and update.bexte_prior().

tp_source <- function() {
  source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
}

tp_target <- function() {
  target_data(n_control = 39, n_treatment = 53,
              responses_control = 17, responses_treatment = 28)
}

tp_proba <- function(prior, target, critical_value = 0.975) {
  post <- posterior(prior, target)
  api_success_proba(post, api_hypothesis(decision(critical_value), prior$source$config))
}

test_that("update() changes one argument and keeps the others", {
  src <- tp_source()
  prior <- rmp(src, weight = 0.5, empirical_bayes = TRUE)
  updated <- update(prior, weight = 0.8)
  expect_s3_class(updated, "bexte_rmp")
  expect_equal(updated$method_parameters$prior_weight, 0.8)
  expect_true(updated$method_parameters$empirical_bayes)
  expect_identical(updated$source, src)
  expect_error(update(prior, weight = 2), "should lie in")
  expect_error(update(prior, a0 = 0.5), "no argument `a0`")
  expect_error(update(prior, 0.5), "by name")
})

test_that("the tipping point in the RMP weight puts the probability at the critical value", {
  src <- tp_source()
  tgt <- tp_target()
  tp <- tipping_point(rmp(src, weight = 0.5), tgt, decision(0.975),
                      parameter = "weight", values = seq(0, 1, by = 0.1))
  expect_s3_class(tp, "bexte_tipping_point")
  points <- attr(tp, "tipping_points")
  expect_length(points, 1)
  expect_equal(tp_proba(rmp(src, weight = points), tgt), 0.975, tolerance = 1e-4)
  rule <- decision(0.975)
  expect_false(rule(posterior(rmp(src, weight = points - 0.01), tgt)))
  expect_true(rule(posterior(rmp(src, weight = points + 0.01), tgt)))
  expect_equal(attr(tp, "observed"), 0.5)
  expect_named(as.data.frame(tp), c("value", "success_proba", "success"))
})

test_that("the power prior has one tipping point in a0", {
  tp <- tipping_point(power_prior(tp_source(), a0 = 0.5), tp_target(), decision(0.975),
                      parameter = "a0", values = seq(0, 1, by = 0.1))
  expect_true(all(diff(tp$success_proba) > 0))
  expect_length(attr(tp, "tipping_points"), 1)
})

test_that("the tipping point in a count is a whole number where the decision changes", {
  src <- tp_source()
  tgt <- tp_target()
  prior <- rmp(src, weight = 0.5)
  tp <- tipping_point(prior, tgt, decision(0.975),
                      parameter = "responses_treatment", values = c(0, 53))
  point <- attr(tp, "tipping_points")
  expect_length(point, 1)
  expect_equal(point, round(point))
  rule <- decision(0.975)
  at <- function(r) {
    rule(posterior(prior, target_data(n_control = 39, n_treatment = 53,
                                      responses_control = 17, responses_treatment = r)))
  }
  # The observed count (28) does not succeed, so the tipping point is the
  # first count above it that succeeds.
  expect_false(attr(tp, "observed_success"))
  expect_true(at(point))
  expect_false(at(point - 1))
  expect_error(
    tipping_point(prior, tgt, decision(0.975), "responses_treatment", c(0.5, 53)),
    "whole numbers"
  )
})

test_that("the tipping point in the target estimate matches the closed form", {
  src <- source_data(n_control = 100, n_treatment = 100, estimate = 0.3, se = 0.15)
  tgt <- target_data(n_control = 100, n_treatment = 100, estimate = 0.2, se = 0.15)
  tp <- tipping_point(separate_prior(src), tgt, decision(0.975),
                      parameter = "estimate", values = seq(-0.5, 1, by = 0.1))
  expect_equal(attr(tp, "tipping_points"), qnorm(0.975) * 0.15, tolerance = 1e-3)
})

test_that("the tipping point in the critical value is the posterior probability", {
  src <- tp_source()
  tgt <- tp_target()
  prior <- rmp(src, weight = 0.5)
  tp <- tipping_point(prior, tgt, decision(0.975), "critical_value", c(0.5, 0.999))
  expect_equal(attr(tp, "tipping_points"), tp_proba(prior, tgt), tolerance = 1e-5)
})

test_that("a grid with one decision gives no tipping point", {
  tp <- tipping_point(rmp(tp_source(), weight = 0.5), tp_target(), decision(0.975),
                      parameter = "weight", values = c(0, 0.2, 0.4))
  expect_length(attr(tp, "tipping_points"), 0)
  expect_output(print(tp), "No tipping point")
})

test_that("tipping_point() rejects parameters it cannot vary", {
  src <- tp_source()
  tgt <- tp_target()
  expect_error(tipping_point(rmp(src), tgt, decision(), "a0", c(0, 1)), "not an argument")
  # A binary target has no `estimate`.
  expect_error(tipping_point(rmp(src), tgt, decision(), "estimate", c(0, 1)), "not an argument")
  expect_error(tipping_point(rmp(src), tgt, decision(), "empirical_bayes", c(0, 1)),
               "numeric argument")
  expect_error(tipping_point(rmp(src), tgt, decision(), "weight", 0.5), "at least two")
})

test_that("tipping_point() warns about grid values the builder rejects", {
  expect_warning(
    tp <- tipping_point(npp(tp_source(), a0_mean = 0.5, a0_sd = 0.2), tp_target(),
                        decision(0.975), parameter = "a0_sd", values = c(0.1, 0.2, 0.6)),
    "failed at a0_sd = 0.6"
  )
  expect_true(is.na(tp$success[3]))
})

test_that("print() and plot() run", {
  tp <- tipping_point(rmp(tp_source(), weight = 0.5), tp_target(), decision(0.975),
                      parameter = "weight", values = seq(0, 1, by = 0.25))
  expect_output(print(tp), "Tipping points")
  skip_if_not_installed("ggplot2")
  expect_s3_class(plot(tp), "ggplot")
})
