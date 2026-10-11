## Only names this package uses bare belong in the @importFrom tags below.
## No tag imports a whole package. Everything else in DESCRIPTION's Imports
## is installed but not loaded, and is reached with pkg::fun() at the point
## of use, so its namespace loads on first call rather than on
## library(BExTE). That matters for BExTE-app, which attaches the package to
## serve a web UI that touches none of the simulation stack: an @importFrom
## of five RBesT symbols that nothing used bare was pulling in rstan and
## ~200 MB of resident memory at startup.
##
## Plotting, table and report code uses packages from Suggests. Each entry
## point calls check_plot_packages(), check_table_packages() or
## check_parallel_packages() before it uses them.
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr %>% across all_of any_of arrange case_when distinct
#' @importFrom dplyr everything first group_by left_join mutate mutate_if
#' @importFrom dplyr n_distinct pull rename_with row_number rowwise select
#' @importFrom dplyr summarize ungroup where
#' @importFrom tidyr pivot_wider unite unnest
#' @importFrom rlang := duplicate sym
#' @importFrom assertions assert_whole_number
## usethis namespace: end
NULL
