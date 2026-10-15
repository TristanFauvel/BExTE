#' Packages that the plot methods need
#'
#' They are in Suggests, so that users who only fit priors and compute
#' operating characteristics do not have to install them. The plots of
#' simulation studies are in BExTEsim, which checks for its own packages.
#' @noRd
PLOT_PACKAGES <- c("ggplot2", "reshape2")

#' Check that the packages for plotting are installed
#'
#' Every plotting entry point calls this first.
#'
#' @return `NULL`, invisibly. Raises an error if a package is missing and the
#'   user does not install it.
#' @noRd
check_plot_packages <- function() {
  return(rlang::check_installed(PLOT_PACKAGES, reason = "to draw plots."))
}
