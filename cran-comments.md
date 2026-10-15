## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Test environments

* Local: Ubuntu, R 4.5, `R CMD check --as-cran`.
* win-builder: R-devel and R-release.

## Notes for the reviewers

* The examples and tests that take more than a few seconds are in
  `\donttest{}` or use `skip_on_cran()`.
* 'Stan' (through 'cmdstanr') is optional. 'cmdstanr' is in Suggests, and
  `Additional_repositories` points to its repository. No example, test or
  vignette needs it.
