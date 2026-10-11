test_that("stan_draws_directory names the directory after the case study and method", {
  path <- stan_draws_directory("Belimumab", "RMP", process_id = 4321L)

  expect_match(basename(path), "belimumab", fixed = TRUE)
  expect_match(basename(path), "RMP", fixed = TRUE)
})


test_that("stan_draws_directory gives each process its own directory", {
  # Parallel workers share a case study and method, and the draws cleanup
  # removes files by age. Without a per-process directory one worker can delete
  # the CSVs backing another worker's fit, which cmdstanr reads lazily.
  first <- stan_draws_directory("belimumab", "RMP", process_id = 111L)
  second <- stan_draws_directory("belimumab", "RMP", process_id = 222L)

  expect_false(identical(first, second))
})


test_that("stan_draws_directory sits under the user cache, not the package", {
  path <- stan_draws_directory("belimumab", "RMP", process_id = 1L)

  expect_identical(basename(dirname(path)), "draws")
  expect_identical(basename(dirname(dirname(path))), "stan")
  # A package must not write into its own installation.
  expect_identical(
    dirname(dirname(dirname(path))),
    tools::R_user_dir("BExTE", "cache")
  )
  expect_false(startsWith(path, system.file(package = "BExTE")))
})


test_that("stan_draws_directory defaults to the current process", {
  expect_identical(
    stan_draws_directory("belimumab", "RMP"),
    stan_draws_directory("belimumab", "RMP", process_id = Sys.getpid())
  )
})
