# The half width of a credible interval and its coverage answer different
# halves of the same question, and a borrowing method can look good on one by
# doing badly on the other: shifting a narrow interval off the true effect buys
# precision at the cost of coverage. The interval score charges both at once,
# so these tests pin the arithmetic that makes that trade-off visible - in
# particular the 2 / alpha rate, which is what makes a miss expensive enough to
# outweigh the width it saved.

test_that("a covered replicate scores the full width of its interval", {
  expect_equal(interval_score(-1, 3, 0.5), 4)
  expect_equal(interval_score(0, 0, 0), 0)
})

test_that("the score is the full width, not the half width precision reports", {
  lower <- c(-1, -2, 0)
  upper <- c(1, 2, 4)
  truth <- 0.5

  half_widths <- (upper - lower) / 2
  scores <- interval_score(lower, upper, truth)

  # Every interval here covers 0.5, so the score is exactly twice `precision`.
  expect_equal(scores, 2 * half_widths)
})

test_that("missing low is penalised at 2 / alpha times the distance", {
  # Truth 0.5 below a [1, 3] interval: width 2, missed by 0.5, alpha = 0.05.
  expect_equal(interval_score(1, 3, 0.5), 2 + 40 * 0.5)
})

test_that("missing high is penalised symmetrically", {
  expect_equal(interval_score(1, 3, 3.5), 2 + 40 * 0.5)
  expect_equal(
    interval_score(1, 3, 3.5),
    interval_score(1, 3, 0.5)
  )
})

test_that("the penalty rate follows the confidence level", {
  # A 50% interval has alpha = 0.5, so a miss costs 2 / 0.5 = 4 per unit.
  expect_equal(interval_score(1, 3, 0.5, confidence_level = 0.5), 2 + 4 * 0.5)
  # A 99% interval has alpha = 0.01, so the same miss costs 200 per unit.
  expect_equal(interval_score(1, 3, 0.5, confidence_level = 0.99), 2 + 200 * 0.5)
})

test_that("the score is monotone increasing in the distance missed", {
  truths <- c(0.9, 0.5, 0, -1)
  scores <- interval_score(rep(1, 4), rep(3, 4), truths)

  expect_true(all(diff(scores) > 0))
})

test_that("a narrow interval that misses scores worse than a wide one that covers", {
  # This is the property the reviewer asked for: precision alone ranks the
  # narrow interval first, the interval score ranks it last.
  narrow_but_wrong <- interval_score(2, 2.4, 0.5)
  wide_but_right <- interval_score(-3, 4, 0.5)

  # Half width ranks them the other way round: 0.2 against 3.5.
  expect_lt((2.4 - 2) / 2, (4 - -3) / 2)
  expect_gt(narrow_but_wrong, wide_but_right)
})

test_that("it vectorises over replicates and recycles a scalar truth", {
  lower <- c(-1, 1, -5)
  upper <- c(1, 3, -2)

  expect_length(interval_score(lower, upper, 0.5), 3)
  expect_equal(
    interval_score(lower, upper, 0.5),
    c(2, 2 + 40 * 0.5, 3 + 40 * 2.5)
  )
})

test_that("it accepts one true value per replicate", {
  expect_equal(
    interval_score(c(1, 1), c(3, 3), c(2, 0.5)),
    c(2, 2 + 40 * 0.5)
  )
})

test_that("missing bounds propagate rather than scoring as covered", {
  scores <- interval_score(c(1, NA), c(3, 3), 2)

  expect_equal(scores[1], 2)
  expect_true(is.na(scores[2]))
})

test_that("empty input gives an empty score", {
  expect_equal(
    interval_score(numeric(0), numeric(0), 0.5),
    numeric(0)
  )
})

test_that("it rejects inputs that cannot describe a set of intervals", {
  expect_error(interval_score(c(1, 2), 3, 0), "same length")
  expect_error(interval_score(c(1, 2), c(3, 4), c(0, 1, 2)), "one value per interval")
  expect_error(interval_score(1, 3, 0, confidence_level = 0), "between 0 and 1")
  expect_error(interval_score(1, 3, 0, confidence_level = 1), "between 0 and 1")
  expect_error(interval_score(1, 3, 0, confidence_level = NA), "between 0 and 1")
  expect_error(interval_score(1, 3, 0, confidence_level = c(0.9, 0.95)), "between 0 and 1")
})

test_that("the mean score is never below twice the mean half width", {
  # The penalty is non-negative by construction, so the score can only ever add
  # to the width. This is the invariant the results-format contract relies on.
  set.seed(20260917)
  centres <- rnorm(200)
  half_widths <- runif(200, 0.1, 2)
  lower <- centres - half_widths
  upper <- centres + half_widths

  scores <- interval_score(lower, upper, 0)

  expect_gte(mean(scores), 2 * mean(half_widths))
})
