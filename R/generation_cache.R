# Replicates generated once per scenario and shared by every method.
#
# A scenario - a case study, a design and a drift - is simulated once for each
# method and each of its parameter settings, about 56 times in the paper's grid.
# Each simulation seeds the random number generator identically and reaches
# the generation of its replicates with the same generator state, so all of
# them generate the very same replicates. For most endpoints that costs
# nothing, but the recurrent-event and time-to-event case studies fit a model to
# every replicate, and regenerating their replicates dominated their run time.
#
# The first simulation of a scenario to generate its replicates stores them on
# disk; the others read them back. The key covers everything generation reads:
# the target data's class and fields, the number of replicates, the generator
# state, and the code of the generator, so a stored set is only ever reused
# where generating would have produced exactly the same replicates. The
# generator state generation leaves behind is stored too and restored on
# reuse, so any random number drawn afterwards is also unchanged.


#' Generate the replicates of a scenario, reusing them across methods
#'
#' @description Equivalent to `target_data$generate(n_replicates)`, with the
#'   same result and the same random number generator state afterwards. When
#'   `cache_dir` is given and generation is slow enough to be worth storing, the
#'   replicates are written there, and a later call with the same target data,
#'   replicate count and generator state reads them back instead.
#'
#' @param target_data Target data object.
#' @param n_replicates Number of replicates.
#' @param cache_dir Directory to store replicates in, or `NULL` to generate
#'   them every time.
#' @param min_seconds Generation time below which replicates are not stored,
#'   because regenerating them is cheaper than reading them back.
#' @return The generated replicates.
#' @keywords internal
generate_replicates <- function(target_data, n_replicates, cache_dir = NULL,
                                min_seconds = 0.25) {
  if (is.null(cache_dir) ||
      !exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
    return(target_data$generate(n_replicates))
  }

  path <- file.path(
    cache_dir,
    paste0(generation_cache_key(target_data, n_replicates), ".rds")
  )

  if (file.exists(path)) {
    entry <- tryCatch(readRDS(path), error = function(e) NULL)
    if (!is.null(entry)) {
      assign(".Random.seed", entry$seed_after, envir = globalenv())
      return(entry$samples)
    }
  }

  start <- proc.time()[["elapsed"]]
  samples <- target_data$generate(n_replicates)
  elapsed <- proc.time()[["elapsed"]] - start

  if (elapsed >= min_seconds) {
    dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
    # Written under a temporary name and renamed into place, so that a
    # simulation running in parallel never reads a half-written file. Two
    # simulations storing the same key store identical content.
    temporary <- tempfile(tmpdir = cache_dir, fileext = ".tmp")
    saveRDS(list(samples = samples, seed_after = get(".Random.seed", envir = globalenv())),
            temporary)
    file.rename(temporary, path)
  }

  samples
}


#' Key of a set of generated replicates
#'
#' @description Hashes everything the generated replicates depend on: the
#'   target data's class, every field it holds except the per-replicate
#'   `sample`, which the replicate loop overwrites, the code of its `generate()`
#'   method, the replicate count and the random number generator state.
#'
#' @param target_data Target data object.
#' @param n_replicates Number of replicates.
#' @return A hash string.
#' @keywords internal
generation_cache_key <- function(target_data, n_replicates) {
  fields <- setdiff(ls(target_data), "sample")
  values <- mget(fields, envir = target_data)
  values <- values[!vapply(values, is.function, logical(1))]

  rlang::hash(list(
    class = class(target_data),
    fields = values[order(names(values))],
    generator = deparse(body(target_data$generate)),
    n_replicates = as.integer(n_replicates),
    seed = get(".Random.seed", envir = globalenv())
  ))
}
