test_that("write_stan_file_if_changed creates a file that does not exist yet", {
  path <- withr::local_tempfile(fileext = ".stan")

  changed <- write_stan_file_if_changed(path, "parameters { real x; }")

  expect_true(changed)
  expect_true(file.exists(path))
  expect_identical(readLines(path), "parameters { real x; }")
})


test_that("write_stan_file_if_changed leaves an unchanged file alone", {
  path <- withr::local_tempfile(fileext = ".stan")
  code <- "parameters { real x; }\nmodel { x ~ normal(0, 1); }"
  write_stan_file_if_changed(path, code)

  # cmdstanr decides whether to recompile by comparing timestamps, so rewriting
  # identical code would force a rebuild on every model construction.
  old_time <- as.POSIXct("2020-01-01 00:00:00", tz = "UTC")
  Sys.setFileTime(path, old_time)

  changed <- write_stan_file_if_changed(path, code)

  expect_false(changed)
  expect_equal(as.numeric(file.mtime(path)), as.numeric(old_time), tolerance = 1)
})


test_that("write_stan_file_if_changed rewrites when the model code changes", {
  path <- withr::local_tempfile(fileext = ".stan")
  write_stan_file_if_changed(path, "parameters { real x; }")
  Sys.setFileTime(path, as.POSIXct("2020-01-01 00:00:00", tz = "UTC"))

  changed <- write_stan_file_if_changed(path, "parameters { real y; }")

  expect_true(changed)
  expect_identical(readLines(path), "parameters { real y; }")
  expect_gt(file.mtime(path), as.POSIXct("2021-01-01 00:00:00", tz = "UTC"))
})


test_that("write_stan_file_if_changed handles code given as multiple lines", {
  path <- withr::local_tempfile(fileext = ".stan")
  code <- c("parameters {", "  real x;", "}")

  expect_true(write_stan_file_if_changed(path, code))
  expect_identical(readLines(path), code)
  expect_false(write_stan_file_if_changed(path, code))
})


# Records every cmdstan_model() call. A call that compiles creates the
# executable it was asked for, as cmdstanr does, so the rename that follows
# has something to move.
recording_cmdstan_model <- function(calls) {
  function(stan_file, exe_file = NULL, compile = TRUE, force_recompile = FALSE,
           ...) {
    calls$args <- c(calls$args, list(list(
      stan_file = stan_file, exe_file = exe_file, compile = compile,
      force_recompile = force_recompile
    )))
    if (compile) {
      writeLines("compiled", exe_file)
    }
    "compiled model"
  }
}

compile_with_recording <- function(calls, directory, code = "parameters { real x; }") {
  testthat::with_mocked_bindings(
    compile_stan_model("a_model", code, stan_directory = directory),
    cmdstan_model = recording_cmdstan_model(calls),
    .package = "cmdstanr"
  )
}


test_that("compile_stan_model builds into a temporary file and renames it", {
  # Parallel workers that need the same model before it is cached all build
  # it. Built straight into the cached path, their copies interleave into a
  # corrupt executable - one came out twice the size of the others and
  # segfaulted on every fit. Each build now goes to a file of its own and is
  # renamed into place, which replaces the cached executable in one step.
  directory <- withr::local_tempdir()
  calls <- new.env(parent = emptyenv())

  result <- compile_with_recording(calls, directory)

  expect_identical(result, "compiled model")
  build <- calls$args[[1]]
  load <- calls$args[[2]]
  expect_true(build$force_recompile)
  expect_identical(dirname(build$exe_file), normalizePath(directory))
  expect_false(identical(basename(build$exe_file), "a_model.exe"))

  # The model is then loaded from the renamed executable, never compiled
  # again by cmdstanr's own timestamp check.
  expect_identical(basename(load$exe_file), "a_model.exe")
  expect_false(load$compile)
  expect_identical(sort(list.files(directory)), c("a_model.exe", "a_model.stan"))
})


test_that("compile_stan_model reuses an up-to-date executable", {
  directory <- withr::local_tempdir()
  calls <- new.env(parent = emptyenv())
  compile_with_recording(calls, directory)

  calls$args <- NULL
  compile_with_recording(calls, directory)

  expect_length(calls$args, 1)
  expect_false(calls$args[[1]]$compile)
})


test_that("compile_stan_model rebuilds after changing the Stan source", {
  directory <- withr::local_tempdir()
  calls <- new.env(parent = emptyenv())
  compile_with_recording(calls, directory, "parameters { real x; }")

  calls$args <- NULL
  compile_with_recording(calls, directory, "parameters { real y; }")

  expect_length(calls$args, 2)
  expect_true(calls$args[[1]]$force_recompile)
})


test_that("compile_stan_model caches the model outside the package library", {
  # inst/stan is excluded from the build (.Rbuildignore), so
  # system.file("stan", package = "BExTE") is "" for an installed copy and
  # pasting a model name onto it writes to the filesystem root. Even when the
  # directory does exist, a managed R installation keeps the library
  # read-only, so the compiled model cannot live there either.
  cache_dir <- tools::R_user_dir("BExTE", "cache")
  expect_true(startsWith(stan_model_directory(), cache_dir))
  expect_identical(formals(compile_stan_model)$stan_directory,
                   quote(stan_model_directory()))
})


test_that("processes compiling the same new model at once all get a working one", {
  skip_on_cran()
  skip_if_not(
    !inherits(try(cmdstanr::cmdstan_path(), silent = TRUE), "try-error"),
    "CmdStan is not installed"
  )

  directory <- withr::local_tempdir()
  package_root <- normalizePath(testthat::test_path("..", ".."))
  # A model no cache holds yet, so every process has to build it.
  code <- paste0(
    "parameters { real x; } model { x ~ normal(", round(stats::runif(1), 6),
    ", 1); }"
  )

  workers <- lapply(seq_len(4), function(i) {
    callr::r_bg(
      function(package_root, code, directory) {
        pkgload::load_all(package_root, quiet = TRUE)
        model <- compile_stan_model("concurrent", code, stan_directory = directory)
        fit <- model$sample(chains = 1, iter_warmup = 100, iter_sampling = 100,
                            refresh = 0, show_messages = FALSE)
        fit$return_codes()
      },
      args = list(package_root, code, directory)
    )
  })
  for (worker in workers) {
    worker$wait(timeout = 600000)
  }

  expect_identical(
    vapply(workers, function(worker) as.integer(worker$get_result()), integer(1)),
    rep(0L, 4)
  )
  # Every build was renamed into place or cleaned up: nothing half-written or
  # temporary is left behind.
  expect_identical(sort(list.files(directory)),
                   c("concurrent.exe", "concurrent.stan"))
})


test_that("clear_stan_model_cache empties the model cache", {
  cache <- withr::local_tempdir()
  file.create(file.path(cache, c("a_model.stan", "a_model.exe")))

  # inst/scripts/main.R clears the cache to force a recompile. It used to do
  # that by listing system.file("stan", package = "BExTE"), which stopped
  # being where the models live.
  removed <- clear_stan_model_cache(cache)

  expect_length(list.files(cache), 0)
  expect_length(removed, 2)
})


test_that("clear_stan_model_cache copes with a cache that does not exist yet", {
  absent <- file.path(withr::local_tempdir(), "never-created")

  expect_length(clear_stan_model_cache(absent), 0)
})
