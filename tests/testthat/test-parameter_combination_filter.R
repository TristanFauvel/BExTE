
test_that("the drop-dimensions spelling is what breaks it", {
  ## Pinning the actual mechanism, so nobody reintroduces `[, ]` thinking it
  ## is a harmless no-op.
  one_column <- data.frame(power_parameter = 0.25)

  expect_true(is.data.frame(one_column))
  expect_false(is.data.frame(one_column[, ]))
  expect_true(is.data.frame(one_column[, , drop = FALSE]))
})
