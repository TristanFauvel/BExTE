# Fast exact evaluation of the binomial power prior on the lattice.
#
# The binomial conditional power prior of binomial_power_prior_posterior()
# reduces, for a target dataset, to
#
#   density[k] = sum_j c_j t_{j+k} kernel[j, k],
#   kernel[j, k] = sum_i w(i - j) a_i b_{i+k},
#
# with a and b the discounted source likelihoods of the control and treatment
# arms, c and t the target ones, w(d) = 1 / (N - |d|) and every rate index
# confined to the lattice 1, ..., N. Only the pairs (i, k) and (j, k) with
# i + k and j + k on the lattice contribute, so the sums are taken over blocks
# of risk differences, each restricted to the source and target control rates
# that keep the treatment rate on the lattice: about a third of the products of
# the full matrices, and no N x K index matrices.
#
# When the power parameter is the same for several datasets the kernel is
# computed once, for every target control rate and risk difference, and kept;
# a dataset then costs a single weighted sum. The kernel is identified by the
# discounted likelihoods a and b themselves, not by the power parameter: power
# parameters small enough that every a_i and b_i rounds to one, which the
# p-value-based power prior gives to every conflicting dataset, share the
# kernel of a power parameter of zero.


#' Hankel matrix of shifted lattice values
#'
#' @description The `n_rows` x `n_shifts` matrix whose (r, c) entry is
#'   `values[first_row + r - 1 + first_shift + c - 1]`, and `fill` where that
#'   index leaves 1, ..., N. The same as [lattice_shift_matrix()] for
#'   contiguous rows and shifts, built from one contiguous segment of the
#'   vector, whose index vector [sequence()] builds in a single pass.
#'
#' @param values A vector of length N.
#' @param first_row,n_rows First row position and number of rows.
#' @param first_shift,n_shifts First shift and number of shifts.
#' @param fill Value outside the lattice.
#' @return A `n_rows` x `n_shifts` matrix.
#' @keywords internal
lattice_hankel <- function(values, first_row, n_rows, first_shift, n_shifts, fill = 0) {
  N <- length(values)
  lowest <- first_row + first_shift
  highest <- lowest + n_rows + n_shifts - 2L
  segment <- rep(fill, highest - lowest + 1L)
  from <- max(1L, lowest)
  to <- min(N, highest)
  if (from <= to) {
    segment[seq.int(from - lowest + 1L, to - lowest + 1L)] <- values[from:to]
  }
  shifted <- segment[sequence(rep.int(n_rows, n_shifts), from = seq_len(n_shifts))]
  dim(shifted) <- c(n_rows, n_shifts)
  shifted
}


#' Blocks of risk differences and the control rates each one reaches
#'
#' @description Splits the risk differences into blocks of consecutive values
#'   and, for each, the range of control rates in `rows` (an index range)
#'   whose treatment rate, at some difference of the block, is on the lattice.
#'
#' @param differences Increasing consecutive risk differences, in lattice units.
#' @param rows Range of control rate indices, `c(lowest, highest)`.
#' @param N Number of lattice points.
#' @param block Number of risk differences per block.
#' @return A list of blocks, each with `columns` (positions in `differences`),
#'   `first_shift`, and the row range `first` and `last`, which is empty when
#'   `first > last`.
#' @keywords internal
lattice_difference_blocks <- function(differences, rows, N, block) {
  starts <- seq.int(1L, length(differences), by = block)
  lapply(starts, function(start) {
    columns <- start:min(length(differences), start + block - 1L)
    lowest_shift <- differences[columns[1]]
    highest_shift <- differences[columns[length(columns)]]
    list(
      columns = columns,
      first_shift = lowest_shift,
      first = max(rows[1], 1L - highest_shift),
      last = min(rows[2], N - lowest_shift)
    )
  })
}


#' Kernel of the binomial power prior on blocks of risk differences
#'
#' @description For each block of risk differences k, the matrix
#'   `kernel[j, k] = sum_i w(i - j) a_i b_{i+k}` over the target control rates
#'   `j` of `target_rows` that keep `j + k` on the lattice for some `k` of the
#'   block, with `i` over the source rows `source_rows`. The source rows are
#'   restricted the same way: `b` is zero off the lattice, so the rows left out
#'   contribute nothing.
#'
#' @param source_control The discounted source control likelihood `a`, zero on
#'   the source control rates left out.
#' @param source_treatment The discounted source treatment likelihood `b`.
#' @param source_rows,target_rows Ranges `c(lowest, highest)` of source and
#'   target control rate indices.
#' @param differences Risk differences, consecutive, in lattice units.
#' @param block Number of risk differences per block.
#' @param consume A function of the block (as from
#'   [lattice_difference_blocks()], with `target_first` and `target_last`) and
#'   its kernel, called once per non-empty block.
#' @return `NULL`, invisibly.
#' @keywords internal
lattice_kernel_blocks <- function(source_control, source_treatment, source_rows, target_rows,
                                  differences, block, consume) {
  N <- length(source_control)
  width <- binomial_lattice_width(N)
  source_blocks <- lattice_difference_blocks(differences, source_rows, N, block)
  target_blocks <- lattice_difference_blocks(differences, target_rows, N, block)
  for (index in seq_along(source_blocks)) {
    source_block <- source_blocks[[index]]
    target_block <- target_blocks[[index]]
    if (source_block$first > source_block$last || target_block$first > target_block$last) {
      next
    }
    source_index <- source_block$first:source_block$last
    weight <- source_control[source_index] *
      lattice_hankel(source_treatment, source_block$first, length(source_index),
                     source_block$first_shift, length(source_block$columns))
    kernel <- crossprod(width[source_index, target_block$first:target_block$last, drop = FALSE],
                        weight)
    consume(target_block, kernel)
  }
  invisible(NULL)
}


#' Posterior density of the risk difference under the binomial power prior
#'
#' @description `sum_j c_j t_{j+k} kernel[j, k]` for every risk difference k
#'   of `differences`, computed block by block; see the comment at the top of
#'   `R/binomial_lattice_fast.R`.
#'
#' @param source_control,source_treatment Discounted source likelihoods on the
#'   lattice, the control one zero on the source rows left out.
#' @param target_control,target_treatment Target likelihoods on the lattice, the
#'   control one zero on the target control rates left out.
#' @param source_rows,target_rows Ranges of the source and target control rates
#'   with nonzero likelihood.
#' @param differences Risk differences, consecutive, in lattice units.
#' @param block Number of risk differences per block.
#' @return The unnormalised density at `differences`.
#' @keywords internal
lattice_power_prior_density <- function(source_control, source_treatment,
                                        target_control, target_treatment,
                                        source_rows, target_rows, differences,
                                        block = 256L) {
  density <- numeric(length(differences))
  lattice_kernel_blocks(
    source_control, source_treatment, source_rows, target_rows, differences, block,
    function(target_block, kernel) {
      target_index <- target_block$first:target_block$last
      likelihood <- target_control[target_index] *
        lattice_hankel(target_treatment, target_block$first, length(target_index),
                       target_block$first_shift, length(target_block$columns))
      density[target_block$columns] <<- colSums(kernel * likelihood)
    }
  )
  density
}


#' Kernel of the binomial power prior at every target control rate
#'
#' @description The kernel of [lattice_power_prior_density()] for every target
#'   control rate and every risk difference of `differences`, by default
#'   -(N - 1), ..., N - 1: zero where the treatment rate leaves the lattice,
#'   except at the edges of a block, where the target likelihood is zero anyway.
#'
#' @inheritParams lattice_power_prior_density
#' @return An N x `length(differences)` matrix; with the default differences,
#'   column `k + N` is the risk difference k.
#' @keywords internal
lattice_power_prior_full_kernel <- function(source_control, source_treatment, source_rows,
                                            differences = seq(-(length(source_control) - 1L),
                                                              length(source_control) - 1L),
                                            block = 256L) {
  N <- length(source_control)
  full <- matrix(0, N, length(differences))
  lattice_kernel_blocks(
    source_control, source_treatment, source_rows, c(1L, N), differences, block,
    function(target_block, kernel) {
      full[target_block$first:target_block$last, target_block$columns] <<- kernel
    }
  )
  full
}


#' Posterior density from a full kernel
#'
#' @inheritParams lattice_power_prior_density
#' @param kernel Output of [lattice_power_prior_full_kernel()].
#' @return The unnormalised density at `differences`.
#' @keywords internal
lattice_power_prior_density_from_kernel <- function(kernel, target_control, target_treatment,
                                                    target_rows, differences) {
  N <- nrow(kernel)
  target_index <- target_rows[1]:target_rows[2]
  likelihood <- target_control[target_index] *
    lattice_hankel(target_treatment, target_rows[1], length(target_index),
                   differences[1], length(differences))
  colSums(kernel[target_index, differences + N, drop = FALSE] * likelihood)
}


#' Posterior density from the target terms
#'
#' @description `sum_i a_i b_{i+k} T(i, k)` over the source rows kept, with
#'   `T(i, k) = sum_j w(i - j) c_j t_{j+k}` the target terms of
#'   [binomial_power_prior_target_terms()]: the same double sum as
#'   [lattice_power_prior_density()], summed over the target control rate
#'   first.
#'
#' @param terms The N x K matrix T, zero where `i + k` leaves the lattice
#'   except at the edges of a block.
#' @inheritParams lattice_power_prior_density
#' @return The unnormalised density at `differences`.
#' @keywords internal
lattice_power_prior_density_from_terms <- function(terms, source_control, source_treatment,
                                                   source_rows, differences) {
  index <- source_rows[1]:source_rows[2]
  weight <- source_control[index] *
    lattice_hankel(source_treatment, source_rows[1], length(index),
                   differences[1], length(differences))
  if (length(index) < nrow(terms)) {
    terms <- terms[index, , drop = FALSE]
  }
  colSums(terms * weight)
}


#' A value kept in a least recently used store
#'
#' @param store Environment holding the list `entries`, most recent last.
#' @param key Key of the value.
#' @param limit Number of entries kept.
#' @param compute A function of no arguments computing the value, or `NULL`
#'   to only look the key up.
#' @return The value, or `NULL` when it is not stored and `compute` is `NULL`.
#' @keywords internal
lattice_lru_cached <- function(store, key, limit, compute) {
  entries <- store$entries
  value <- entries[[key]]
  if (!is.null(value)) {
    if (!identical(names(entries)[length(entries)], key)) {
      store$entries <- c(entries[names(entries) != key], stats::setNames(list(value), key))
    }
    return(value)
  }
  if (is.null(compute)) {
    return(NULL)
  }
  value <- compute()
  if (length(entries) >= limit) {
    entries <- entries[seq.int(length(entries) - limit + 2L, length.out = limit - 1L)]
  }
  store$entries <- c(entries, stats::setNames(list(value), key))
  value
}


#' Store of binomial power prior kernels, by discounted source likelihoods
#'
#' @description `entries` holds up to [binomial_power_prior_kernel_limit()]
#'   full kernels, most recently used last, and `seen` the pairs of discounted
#'   source likelihoods met so far. A kernel is computed on the second meeting:
#'   it costs about as much as one to three datasets computed directly.
#' @keywords internal
binomial_power_prior_kernel_store <- new.env(parent = emptyenv())


#' Store of binomial target terms, by target likelihoods
#'
#' @description Holds up to [binomial_target_terms_limit()] matrices of target
#'   terms in `entries`; see [binomial_target_terms()].
#' @keywords internal
binomial_target_terms_store <- new.env(parent = emptyenv())


#' Number of power prior kernels kept per process
#'
#' @description Each is an N x (2N - 1) matrix, 16 MB at N = 1000. Set by the
#'   option `BExTE.power_prior_kernels`, 4 by default; 0 turns the cache off.
#' @return The number of kernels.
#' @keywords internal
binomial_power_prior_kernel_limit <- function() {
  as.integer(getOption("BExTE.power_prior_kernels", 4L))
}


#' Number of target terms matrices kept per process
#'
#' @description Set by the option `BExTE.target_terms_cache`, 0 (none) by
#'   default; see [binomial_target_terms()].
#' @return The number of matrices.
#' @keywords internal
binomial_target_terms_limit <- function() {
  as.integer(getOption("BExTE.target_terms_cache", 0L))
}


#' Empty the binomial power prior kernel and target terms stores
#' @return `NULL`, invisibly.
#' @keywords internal
binomial_power_prior_kernel_reset <- function() {
  for (store in list(binomial_power_prior_kernel_store, binomial_target_terms_store)) {
    rm(list = ls(envir = store, all.names = TRUE), envir = store)
  }
  invisible(NULL)
}


#' The kernel of a pair of discounted source likelihoods, if worth keeping
#'
#' @description Returns the stored kernel when there is one; computes and
#'   stores it when the pair has been met before; and otherwise records the
#'   meeting and returns `NULL`, so that the caller computes the dataset's
#'   density directly. The least recently used kernel is dropped when the store
#'   is full.
#'
#' @param source_control,source_treatment Discounted source likelihoods, as
#'   passed to [lattice_power_prior_full_kernel()].
#' @param source_rows Range of the source control rates kept.
#' @return The kernel, or `NULL`.
#' @keywords internal
binomial_power_prior_cached_kernel <- function(source_control, source_treatment, source_rows) {
  limit <- binomial_power_prior_kernel_limit()
  if (limit <= 0L) {
    return(NULL)
  }
  store <- binomial_power_prior_kernel_store
  if (is.null(store$seen)) {
    store$seen <- new.env(hash = TRUE, parent = emptyenv())
    store$n_seen <- 0L
  }
  key <- rlang::hash(list(source_control, source_treatment, source_rows))
  kernel <- lattice_lru_cached(store, key, limit, NULL)
  if (!is.null(kernel)) {
    return(kernel)
  }
  if (is.null(store$seen[[key]])) {
    if (store$n_seen >= 100000L) {
      store$seen <- new.env(hash = TRUE, parent = emptyenv())
      store$n_seen <- 0L
    }
    assign(key, TRUE, envir = store$seen)
    store$n_seen <- store$n_seen + 1L
    return(NULL)
  }
  lattice_lru_cached(store, key, limit, function() {
    lattice_power_prior_full_kernel(source_control, source_treatment, source_rows)
  })
}


#' Target terms of the binomial power prior, kept between analyses if asked
#'
#' @description The N x K matrix `T(i, k) = sum_j w(i - j) c_j t_{j+k}` of
#'   [binomial_power_prior_target_terms()]. It depends on the target data
#'   alone, so every power prior analysis of the same dataset - at another
#'   power parameter, under another configuration of the p-value-based power
#'   prior, under the empirical Bayes power prior - can read its density off
#'   it with [lattice_power_prior_density_from_terms()], at a fraction of the
#'   cost of computing it.
#'
#'   With the option `BExTE.target_terms_cache` set to a positive number, that
#'   many are kept per process, 8 to 16 MB each at N = 1000. This pays when
#'   several analyses of each dataset follow one another, as when a driver
#'   runs every configuration on a chunk of datasets before moving to the next
#'   chunk. The option is 0, keeping none, by default.
#'
#' @param target_control Target control likelihood, zero off the target
#'   control rates kept.
#' @param target_treatment Target treatment likelihood.
#' @param control_rows Range of the target control rates kept.
#' @param differences Risk differences, consecutive, in lattice units.
#' @return The N x `length(differences)` matrix T.
#' @keywords internal
binomial_target_terms <- function(target_control, target_treatment, control_rows, differences) {
  compute <- function() {
    lattice_power_prior_full_kernel(target_control, target_treatment, control_rows, differences)
  }
  limit <- binomial_target_terms_limit()
  if (limit <= 0L) {
    return(compute())
  }
  key <- rlang::hash(list(target_control, target_treatment, control_rows, differences))
  lattice_lru_cached(binomial_target_terms_store, key, limit, compute)
}
