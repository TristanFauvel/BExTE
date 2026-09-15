## Only packages whose exports this package uses bare belong in the @import
## tags below. Everything else stays in DESCRIPTION's Imports - which
## guarantees it is installed without loading it - and is reached with
## pkg::fun() at the point of use, so its namespace loads on first call
## rather than on library(BExTE). That matters for the Shiny app, which
## attaches the package to serve a web UI that touches none of the
## simulation stack: an @importFrom of five RBesT symbols that nothing used
## bare was pulling in rstan and ~200 MB of resident memory at startup.
#' @keywords internal
#' @import rlang dplyr tidyr readr parallel foreach extrafont
#' @import R6 ggplot2 viridis stringr assertions
"_PACKAGE"

## usethis namespace: start
#' @importFrom purrr imap
#' @importFrom latex2exp TeX
#' @importFrom jsonlite write_json toJSON
#' @importFrom ggnewscale new_scale_color
#' @importFrom gridExtra grid.arrange
#' @importFrom Bolstad2 sintegral
#' @importFrom progress progress_bar
#' @importFrom yaml yaml.load_file read_yaml
#' @importFrom parallel makeCluster clusterEvalQ stopCluster clusterExport detectCores
#' @importFrom doParallel registerDoParallel
#' @importFrom truncnorm rtruncnorm
#' @importFrom HDInterval inverseCDF
#' @importFrom pwr pwr.t.test pwr.norm.test ES.h pwr.2p2n.test
## usethis namespace: end
NULL
