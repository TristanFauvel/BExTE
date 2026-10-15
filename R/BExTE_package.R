## Only names this package uses bare belong in the @importFrom tags below.
## No tag imports a whole package. Everything else in DESCRIPTION's Imports
## is installed but not loaded, and is reached with pkg::fun() at the point
## of use, so its namespace loads on first call rather than on
## library(BExTE). That matters for BExTE-app, which attaches the package to
## serve a web UI that touches none of the simulation stack: an @importFrom
## of five RBesT symbols that nothing used bare was pulling in rstan and
## ~200 MB of resident memory at startup.
##
## The plot methods use packages from Suggests, and call
## check_plot_packages() before they use them.
##
## The simulation-study pipeline (configs, scenarios, result files, plots and
## tables of simulation studies) is in the separate package BExTEsim.
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr %>%
#' @importFrom rlang duplicate
#' @importFrom assertions assert_whole_number
#' @importFrom stats approx binom.test pnorm qnorm rbinom rchisq rnorm
## usethis namespace: end
NULL

## R CMD check does not scan the code inside R6 classes, so it reports BSDA,
## Hmisc and extraDistr as unused Imports. This function names one function
## of each, so the check sees them. Nothing calls it, and it does not load the
## three namespaces.
ignore_unused_imports <- function() {
  BSDA::zsum.test
  Hmisc::smean.cl.normal
  extraDistr::dhnorm
}
