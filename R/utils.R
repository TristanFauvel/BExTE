#' Format a case study configuration as a printable table
#'
#' @param case_study_config Case study configuration list.
#'
#' @return An HTML table of class `kableExtra` (from [knitr::kable()] and
#'   kableExtra), with one row per configuration field, grouped into general,
#'   target and source settings. The data-generation vignettes print it to
#'   describe a case study.
#'
#' @keywords internal
format_case_study_config <- function(case_study_config) {
  rlang::check_installed(c("knitr", "kableExtra"), reason = "to format tables.")
  if (case_study_config$endpoint == "continuous" ||
      case_study_config$endpoint == "recurrent_event") {
    data <- data.frame(
      Parameter = c(
        "Name",
        "Control",
        "Summary Measure Likelihood",
        "Theta 0",
        "Endpoint",
        "Null Space",
        "Sampling Approximation",
        "Control",
        "Treatment",
        "Total",
        "Treatment Effect",
        "Standard Error",
        "Control",
        "Treatment",
        "Total",
        "Treatment Effect",
        "Standard Error"
      ),
      Value = c(
        case_study_config$name,
        case_study_config$control,
        case_study_config$summary_measure_likelihood,
        case_study_config$theta_0,
        case_study_config$endpoint,
        case_study_config$null_space,
        case_study_config$sampling_approximation,
        case_study_config$target$control,
        case_study_config$target$treatment,
        case_study_config$target$total,
        case_study_config$target$treatment_effect,
        case_study_config$target$standard_error,
        case_study_config$source$control,
        case_study_config$source$treatment,
        case_study_config$source$total,
        case_study_config$source$treatment_effect,
        case_study_config$source$standard_error
      )
    )

    # Create the table with headers and horizontal lines
    return(knitr::kable(data,
          col.names = c("Parameter", "Value"),
          align = "l") %>%
      kableExtra::add_header_above(c("Case Study Configuration" = 2)) %>%
      kableExtra::kable_styling("striped", full_width = FALSE) %>%
      kableExtra::pack_rows("General", 1, 7) %>%
      kableExtra::pack_rows("Target", 8, 12) %>%
      kableExtra::pack_rows("Source", 13, 17))
  } else if (case_study_config$endpoint == "time_to_event") {
    data <- data.frame(
      Parameter = c(
        "Name",
        "Summary Measure Likelihood",
        "Theta 0",
        "Endpoint",
        "Null Space",
        "Sampling Approximation",
        "Control (Target)",
        "Treatment (Target)",
        "Total (Target)",
        "Treatment Effect (Target)",
        "Standard Error (Target)",
        "Maximum follow-up time (Target)",
        "Accrual period (Target)",
        "Follow-up after recruitment (Target)",
        "Weibull shape (Target)",
        "Weibull relapse-free probability (Target)",
        "Control (Source)",
        "Treatment (Source)",
        "Total (Source)",
        "Treatment Effect (Source)",
        "Standard Error (Source)",
        "Maximum follow-up time (Source)"
      ),
      Value = c(
        case_study_config$name,
        case_study_config$summary_measure_likelihood,
        case_study_config$theta_0,
        case_study_config$endpoint,
        case_study_config$null_space,
        case_study_config$sampling_approximation,
        case_study_config$target$control,
        case_study_config$target$treatment,
        case_study_config$target$total,
        case_study_config$target$treatment_effect,
        case_study_config$target$standard_error,
        case_study_config$target$max_follow_up_time,
        case_study_config$target$accrual_period,
        case_study_config$target$final_follow_up,
        case_study_config$target$weibull_shape,
        case_study_config$target$weibull_relapse_free_probability,
        case_study_config$source$control,
        case_study_config$source$treatment,
        case_study_config$source$total,
        case_study_config$source$treatment_effect,
        case_study_config$source$standard_error,
        case_study_config$source$max_follow_up_time
      )
    )

    # Create the table with headers and horizontal lines
    return(knitr::kable(data,
          col.names = c("Parameter", "Value"),
          align = "l") %>%
      kableExtra::add_header_above(c("Case Study Configuration" = 2)) %>%
      kableExtra::kable_styling("striped", full_width = FALSE) %>%
      kableExtra::pack_rows("General", 1, 6) %>%
      kableExtra::pack_rows("Target", 7, 16) %>%
      kableExtra::pack_rows("Source", 17, 22))
  } else if (case_study_config$endpoint == "binary") {
    data <- data.frame(
      Parameter = c(
        "Name",
        "Control",
        "Summary Measure Likelihood",
        "Theta 0",
        "Endpoint",
        "Null Space",
        "Sampling Approximation",
        "Target Control",
        "Target Treatment",
        "Target Total",
        "Target Responses (Control)",
        "Target Responses (Treatment)",
        "Target Treatment Effect",
        "Target Standard Error",
        "Source Control",
        "Source Treatment",
        "Source Total",
        "Source Responses (Control)",
        "Source Responses (Treatment)",
        "Source Treatment Effect",
        "Source Standard Error"
      ),
      Value = c(
        case_study_config$name,
        case_study_config$control,
        case_study_config$summary_measure_likelihood,
        case_study_config$theta_0,
        case_study_config$endpoint,
        case_study_config$null_space,
        case_study_config$sampling_approximation,
        case_study_config$target$control,
        case_study_config$target$treatment,
        case_study_config$target$total,
        case_study_config$target$responses$control,
        case_study_config$target$responses$treatment,
        case_study_config$target$treatment_effect,
        case_study_config$target$standard_error,
        case_study_config$source$control,
        case_study_config$source$treatment,
        case_study_config$source$total,
        case_study_config$source$responses$control,
        case_study_config$source$responses$treatment,
        case_study_config$source$treatment_effect,
        case_study_config$source$standard_error
      )
    )

    # Create the table with headers and horizontal lines
    return(knitr::kable(data,
          col.names = c("Parameter", "Value"),
          align = "l") %>%
      kableExtra::add_header_above(c("Case Study Configuration" = 2)) %>%
      kableExtra::kable_styling("striped", full_width = FALSE) %>%
      kableExtra::pack_rows("General", 1, 7) %>%
      kableExtra::pack_rows("Target", 8, 14) %>%
      kableExtra::pack_rows("Source", 15, 21))
  } else {
    return(invisible(NULL))
  }
}


#' Write Stan code to a file only when the content would change
#'
#' cmdstanr decides whether to rebuild by comparing the timestamps of the model
#' file and the executable, so rewriting identical code would force a rebuild
#' every time a model is constructed. Leaving an unchanged file untouched also
#' means parallel workers do not write over a file another worker is compiling.
#'
#' @param path Path of the Stan model file.
#' @param stan_model_code Stan code, as a single string or a character vector.
#'
#' @return TRUE when the file was written, FALSE when it was already up to date.
#' @noRd
write_stan_file_if_changed <- function(path, stan_model_code) {
  if (file.exists(path)) {
    current <- tryCatch(readLines(path, warn = FALSE), error = function(e) NULL)
    if (identical(current, unlist(strsplit(stan_model_code, "\n", fixed = TRUE)))) {
      return(invisible(FALSE))
    }
  }

  # Written beside the target and renamed over it, so a worker reading the
  # file never sees it half-written and mistakes it for different code.
  write_file_atomically(path, function(temporary) {
    return(writeLines(stan_model_code, con = temporary))
  })

  return(invisible(TRUE))
}

#' Create a file under a temporary name, then rename it into place
#'
#' A rename within one directory replaces the target in a single step, so a
#' process reading or running the file sees either the old one or the new one,
#' never a mixture. Several processes may do this at once: each writes its own
#' temporary file, and whichever renames last wins.
#'
#' @param path Final path of the file.
#' @param write Function of one argument, the temporary path, that creates the
#'   file there.
#'
#' @return `path`, invisibly.
#' @noRd
write_file_atomically <- function(path, write) {
  temporary <- file.path(
    dirname(path),
    paste0(basename(path), ".", Sys.getpid(), ".",
           paste(sample(c(letters, 0:9), 8, replace = TRUE), collapse = ""),
           ".tmp")
  )
  on.exit(unlink(temporary), add = TRUE)

  write(temporary)
  if (!file.rename(temporary, path)) {
    stop("Could not move ", temporary, " to ", path, call. = FALSE)
  }

  return(invisible(path))
}

#' Draw a seed for one Stan sampler run
#'
#' Taken from the session random number stream, which the scenario simulation
#' seeds from the configuration. Runs are therefore reproducible, while every
#' replicate still gets its own stream: a single fixed seed would correlate
#' draws across replicates that are meant to be independent.
#'
#' @return A positive integer seed.
#' @noRd
stan_sampler_seed <- function() {
  return(sample.int(.Machine$integer.max, size = 1))
}

#' Directory holding the Stan draws of one model in one process
#'
#' Parallel workers share a case study and a method, and the draws cleanup
#' removes files by age, so a shared directory lets one worker delete the CSVs
#' backing another worker's fit. cmdstanr reads those files lazily, so give each
#' process a directory of its own.
#'
#' The directories sit in the user cache directory, next to the compiled
#' models: a package must not write into its own installation, and a
#' per-process `tempdir()` would hide the workers' draws from the parent
#' process that clears them.
#'
#' @param case_study Case study name.
#' @param method Method name.
#' @param process_id Identifier of the process writing the draws.
#'
#' @return Path of the directory, which is not created here.
#' @noRd
stan_draws_directory <- function(case_study, method, process_id = Sys.getpid()) {
  return(file.path(
    tools::R_user_dir("BExTE", "cache"),
    "stan",
    "draws",
    paste0(tolower(case_study), "_", method, "_", process_id)
  ))
}

#' Remove the Stan draws of one model across every process
#'
#' @description Each process writes to its own directory, so one run leaves
#'   a directory per worker behind. They hold intermediate MCMC output that
#'   runs to gigabytes for the larger case studies, so a finished run clears
#'   them. The prefix is taken from `stan_draws_directory()` rather than
#'   rebuilt here, so the two cannot drift apart.
#'
#' @param case_study Case study name.
#' @param method Method name.
#' @param root Directory the per-process directories sit in.
#'
#' @return Paths of the directories that were removed, invisibly.
#' @examples
#' root <- file.path(tempdir(), "bexte-draws")
#' dir.create(file.path(root, "belimumab_rmp_1234"), recursive = TRUE)
#' dir.create(file.path(root, "belimumab_rmp_5678"))
#' dir.create(file.path(root, "botox_rmp_1234"))
#' clear_stan_draws("Belimumab", "rmp", root = root)
#' list.files(root)
#' unlink(root, recursive = TRUE)
#' @export
clear_stan_draws <- function(case_study,
                             method,
                             root = dirname(stan_draws_directory(case_study, method))) {
  prefix <- basename(stan_draws_directory(case_study, method, process_id = ""))
  entries <- list.files(root, full.names = TRUE)
  names <- basename(entries)

  # A method whose name extends another's shares its prefix, so require the
  # remainder to be the process id and nothing else.
  suffix <- substring(names, nchar(prefix) + 1L)
  mine <- startsWith(names, prefix) & grepl("^[0-9]+$", suffix)

  unlink(entries[mine], recursive = TRUE)
  return(invisible(entries[mine]))
}


#' Directory holding the compiled Stan models
#'
#' @description `inst/stan` is excluded from the built package, so
#'   `system.file("stan", package = "BExTE")` returns `""` once BExTE is
#'   installed and every model path would resolve to the filesystem root.
#'   Compiled models are build artifacts rather than package contents, so
#'   they belong in the user cache directory, which stays writable even when
#'   the library does not.
#'
#' @return Path of the directory, created if it does not exist.
#' @noRd
stan_model_directory <- function() {
  directory <- file.path(tools::R_user_dir("BExTE", "cache"), "stan")
  dir.create(directory, showWarnings = FALSE, recursive = TRUE)
  return(directory)
}

#' Remove the compiled Stan models
#'
#' @description The models are compiled on first use and cached in
#'   `stan_model_directory()`. Clearing the cache forces the next run to
#'   recompile them, which is what BExTEpaper's `scripts/main.R` does when its
#'   `delete_stan_files` switch is set.
#'
#' @param directory Directory holding the cached models.
#'
#' @return Paths of the files that were removed, invisibly.
#' @examples
#' directory <- file.path(tempdir(), "bexte-stan-cache")
#' dir.create(directory)
#' file.create(file.path(directory, c("model.stan", "model.exe")))
#' clear_stan_model_cache(directory)
#' list.files(directory)
#' unlink(directory, recursive = TRUE)
#' @export
clear_stan_model_cache <- function(directory = stan_model_directory()) {
  cached <- list.files(directory, full.names = TRUE)
  file.remove(cached)
  return(invisible(cached))
}

#' Stop unless 'cmdstanr' and 'CmdStan' are installed
#'
#' 'cmdstanr' is only suggested, and 'CmdStan' needs a C++ toolchain, so
#' neither may be present. Every model runs on quadrature by default; Stan is
#' only needed when a configuration asks for `engine: stan`.
#'
#' @param has_cmdstanr Whether 'cmdstanr' is installed. An argument so that
#'   tests can simulate its absence.
#' @return `TRUE`, invisibly, when Stan can be used.
#' @noRd
check_stan_available <- function(
    has_cmdstanr = requireNamespace("cmdstanr", quietly = TRUE)) {
  if (!has_cmdstanr) {
    stop(
      "The Stan engine needs the 'cmdstanr' package, which is not installed. ",
      "Install it from https://stan-dev.r-universe.dev, ",
      "or set `engine: quadrature` in the MCMC configuration.",
      call. = FALSE
    )
  }
  cmdstan_found <- tryCatch(
    {
      cmdstanr::cmdstan_path()
      TRUE
    },
    error = function(e) FALSE
  )
  if (!cmdstan_found) {
    stop(
      "The Stan engine needs 'CmdStan', which was not found. ",
      "Run cmdstanr::install_cmdstan(), ",
      "or set `engine: quadrature` in the MCMC configuration.",
      call. = FALSE
    )
  }
  return(invisible(TRUE))
}

compile_stan_model <- function(model_name, stan_model_code,
                               stan_directory = stan_model_directory()) {
  check_stan_available()

  stan_model_file_path <- file.path(stan_directory, paste0(model_name, ".stan"))
  stan_exe_file_path <- file.path(stan_directory, paste0(model_name, ".exe"))

  stan_file_changed <- write_stan_file_if_changed(
    stan_model_file_path,
    stan_model_code
  )

  executable_is_stale <- !file.exists(stan_exe_file_path) ||
    file.mtime(stan_exe_file_path) < file.mtime(stan_model_file_path)

  # An executable left over from an earlier version of the code is rebuilt
  # rather than silently reused. Parallel workers that need a model before it
  # is cached all build it, so each builds into a file of its own and renames
  # it into place: built straight into the cached path, their copies
  # interleaved into an executable that segfaulted on every fit. None of the
  # models use reduce_sum or map_rect, so within-chain threading cannot
  # engage: building with STAN_THREADS would only make the autodiff stack
  # thread-local, which costs speed for no parallelism in return.
  if (stan_file_changed || executable_is_stale) {
    write_file_atomically(stan_exe_file_path, function(temporary) {
      return(cmdstanr::cmdstan_model(stan_model_file_path,
                              exe_file = temporary,
                              force_recompile = TRUE,
                              quiet = TRUE))
    })
  }

  # Loaded without compiling: cmdstanr's own timestamp check would otherwise
  # rebuild straight into the cached path again.
  stan_model <- cmdstanr::cmdstan_model(stan_model_file_path,
                                        exe_file = stan_exe_file_path,
                                        compile = FALSE)

  return(stan_model)
}

#' Print a function's source code
#'
#' @description Used by the vignettes to display the implementation of key
#'   functions inline, next to their explanation.
#'
#' @param function_obj The function to print the source of.
#'
#' @return `NULL`, invisibly; prints the function's source code as a side effect.
#'
#' @keywords internal
read_function_code <- function(function_obj){
  function_name <- substitute(function_obj)

  # Use deparse() to get the function's source code
  function_code <- deparse(function_obj)

  # Prepend the function name and assignment
  return(cat(paste0(function_name, " <- ", paste(function_code, collapse = "\n"), sep = "")))
}

#' Summarise the posterior draws consumed by the simulation
#'
#' Computes the moments, the credible interval bounds and the convergence
#' diagnostics in a single pass over the draws. The estimators are the ones the
#' simulation reported when these quantities were collected separately:
#' `bayesplot::rhat()` is `posterior::rhat()`, and `bayesplot::neff_ratio()`
#' multiplied back up by the number of draws is `posterior::ess_basic()`.
#'
#' @param draws Posterior draws, restricted to the variables of interest.
#'
#' @return A summary data frame with one row per variable.
#' @noRd
summarise_posterior_draws <- function(draws) {
  rlang::check_installed("posterior", reason = "to summarise MCMC draws.")
  if (!requireNamespace("posterior", quietly = TRUE)) {
    stop("Summarising Stan draws needs the 'posterior' package. ",
         "Install it, or set `engine: quadrature` in the MCMC configuration.",
         call. = FALSE)
  }
  return(posterior::summarise_draws(
    draws,
    posterior::default_summary_measures(),
    extra_quantiles = ~ posterior::quantile2(., probs = c(0.025, 0.975)),
    rhat = posterior::rhat,
    n_eff = posterior::ess_basic
  ))
}

#' Check that a value is a single number
#'
#' A like-for-like replacement for assertions::assert_number() in code that
#' builds an object per scenario or per result row. It accepts exactly what
#' assert_number() accepts - one numeric value, NA and Inf included - but
#' costs about 0.4us against 190us, because it does not inspect its own call
#' or dispatch over a list of validators. The argument is only deparsed when
#' the check fails, so the message still names the offending value.
#'
#' @param x Value to check.
#' @param arg_name Name to report; defaults to the deparsed argument.
#'
#' @return `x`, invisibly. Called for the error it raises.
#' @noRd
assert_single_number <- function(x, arg_name = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 1L) {
    detail <- if (!is.numeric(x)) {
      paste0("class is ", class(x)[1], ", not numeric")
    } else {
      paste0("length is ", length(x), ", not 1")
    }
    stop(sprintf("'%s' is not a number! (%s)", arg_name, detail), call. = FALSE)
  }

  return(invisible(x))
}

#' Equivalent sample size per arm of a two-arm study
#'
#' @description The per-arm size of a balanced study with the same variance
#'   of the treatment-effect estimate: `1 / n_control + 1 / n_treatment` equals
#'   `2 / n`. For equal arms it is the arm size itself.
#'
#'   The per-patient sampling standard deviation `standard_deviation` and the
#'   standard error are related by `SE = standard_deviation / sqrt(n)` with
#'   this `n`, for the source and the target alike. Effective sample sizes of
#'   priors are counted in the same unit: patients per arm of a balanced
#'   study.
#'
#' @param n_control,n_treatment Arm sizes. Vectors recycle.
#' @return The harmonic mean of the arm sizes.
#' @keywords internal
#' @export
effective_arm_size <- function(n_control, n_treatment) {
  return(2 * n_control * n_treatment / (n_control + n_treatment))
}

#' Equivalent sample size per arm of a target study
#'
#' @param target A target data object, a list or a data frame with
#'   `sample_size_control` and `sample_size_treatment`.
#' @return See `effective_arm_size()`.
#' @keywords internal
#' @export
target_effective_arm_size <- function(target) {
  return(effective_arm_size(target$sample_size_control, target$sample_size_treatment))
}
