## One-shot setup for BExTE.
##
##   Rscript install.R              # BExTE and its R dependencies
##   Rscript install.R --with-stan  # also cmdstanr and CmdStan
##
## Run it either from a directory holding a release tarball
## (BExTE_<version>.tar.gz) or from a source checkout.
##
## BExTE runs without Stan: every method computes its posterior by quadrature
## or in closed form. Stan is an optional reference engine (`engine: stan` in
## the MCMC configuration). It needs cmdstanr, which is only the R interface,
## and a CmdStan installation, which needs a C++ toolchain.

with_stan <- "--with-stan" %in% commandArgs(trailingOnly = TRUE)

if (getRversion() < "4.0.0") {
  stop("BExTE needs R 4.0.0 or later; this is ", getRversion(), ".")
}

## cmdstanr is not on CRAN. DESCRIPTION's Additional_repositories field is not
## consistently honoured by the resolvers, so set the repository explicitly.
options(repos = c(
  CRAN = "https://cloud.r-project.org",
  if (with_stan) c(stan = "https://stan-dev.r-universe.dev")
))

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

tarballs <- sort(Sys.glob("BExTE_*.tar.gz"), decreasing = TRUE)

if (length(tarballs) > 0) {
  message("Installing ", tarballs[[1]], " and its dependencies ...")
  pak::pkg_install(paste0("local::", tarballs[[1]]), ask = FALSE)
} else if (file.exists("DESCRIPTION")) {
  message("Installing dependencies for the checkout in ", getwd(), " ...")
  pak::local_install_deps(".", ask = FALSE)
} else {
  stop(
    "Found neither BExTE_<version>.tar.gz nor a DESCRIPTION in ", getwd(), ".\n",
    "Run this from the directory you downloaded the release into, or from a ",
    "source checkout."
  )
}

if (with_stan) {
  if (!requireNamespace("cmdstanr", quietly = TRUE)) {
    pak::pkg_install("cmdstanr", ask = FALSE)
  }

  ## cmdstanr ships no CmdStan of its own, and install_cmdstan() compiles it,
  ## so check the toolchain before spending the build on a failure.
  cmdstan_installed <- !is.null(tryCatch(
    cmdstanr::cmdstan_path(),
    error = function(e) NULL
  ))

  if (cmdstan_installed) {
    message("CmdStan already present at ", cmdstanr::cmdstan_path(), ".")
  } else {
    message("Installing CmdStan (this compiles, and takes a few minutes) ...")
    cmdstanr::check_cmdstan_toolchain(fix = TRUE)
    cmdstanr::install_cmdstan()
  }
}

message(
  "\nDone. For a browser interface, install BExTE-app:\n",
  "  remotes::install_github(\"TristanFauvel/BExTE-app\")\n"
)
