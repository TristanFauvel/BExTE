# BExTE: CRAN readiness and wider uptake

Review date: 2026-10-11. The findings come from a reading of DESCRIPTION, NAMESPACE, LICENSE, `R/`, `man/`, `tests/` and `vignettes/`. `R CMD check --as-cran` results are in the Progress section.

## Progress (2026-10-11)

`R CMD check --as-cran --no-manual` on a copy of the tree (after `roxygen2::roxygenise()`) gives 0 errors, 2 warnings and 3 notes. The examples take 53 s, or 113 s with `--run-donttest`. The tests take 87 s, and the vignettes rebuild in 13 s. The tarball is 754 KB.

Done (items 1 and 3–7 of part 1):
- License: DESCRIPTION says `License: GPL (>= 3)`. The proprietary `LICENSE` file is deleted. The README badge links to the GPL-3 page.
- `.Rbuildignore` no longer excludes `tests/`. It now excludes `tests/test_scripts.R` (it sources files that do not exist), the vignette subfolders and rendered `.html` files.
- Tests:
  - 34 tests slower than 2 s have `skip_on_cran()`, and so has every test that checks for CmdStan.
  - With `compile_stan_model()` blocked, no test that runs on CRAN reaches Stan; the only exceptions are tests that mock cmdstanr.
  - Four test files read `inst/` or `_pkgdown.yml` through relative paths. Those that read shipped configs now use `system.file()`. `test-documentation-consistency.R` skips when the source tree is missing.
  - `pkgload` and `tibble` were added to `Suggests`, because the tests use them.
- Vignettes: `Separate`, `Pooling` and `simulation_illustration_high_level` moved to the top level. They use `rmarkdown::html_vignette`, render in about 2 s each, and do not use Stan.
- `library()` calls removed from `R/`.
- DESCRIPTION: removed `NeedsCompilation`, `UseLTO`, `Biarch` and `LazyData`. `SystemRequirements` lists only pandoc.
- Every exported object has `@examples`.
  - Code that is slow or needs LaTeX is in `\donttest{}`. Stan code is in `\donttest{}`, with a check that cmdstanr and CmdStan are present.
  - `BinomialPDCCPP` uses `\dontrun{}`, because its inference takes several minutes.
- The example writers found 7 bugs. All are fixed:
  - Stan draws: `stan_draws_directory()` now puts them in the user cache folder (`tools::R_user_dir("BExTE", "cache")/stan/draws/`), next to the compiled models. Before, it used the package install folder, which CRAN forbids. A per-process `tempdir()` would not work, because the parent process clears the workers' draws.
  - `ObservedTargetData` now sets `sample$standard_deviation` to SE × √(n per arm). Simulated data uses the same scale. `TestThenPoolDifference`, `TestThenPoolEquivalence` and `GaussianPValueBasedPP` now run on observed data. A new test file, `test-observed_target_data.R`, checks this. The examples no longer set the SD by hand.
  - `run_simulation_env()`: every `dir.create()` call in `R/` is recursive, and the example no longer warns.
  - `inst/conf/methods_plots_config.R` now writes `\\hat{\\psi}`, so the Egidi mixture plots render.
  - Plain data frames: 31 `df[, "parameters"]` subsets now pass `drop = FALSE`. The two empirical-Bayes `_vs_drift` functions also accept `parameters_combinations` as a string. Every plot and table example now runs on a plain `data.frame`, and the examples no longer call `dplyr::as_tibble()`.
  - Case-study paths: the 21 reads of a case-study config use `file.path()`, so `case_studies_config_dir` works with or without a trailing `/`. The examples no longer add one.
  - `format_case_study_config()`: its docs now say that it returns a `kableExtra` HTML table.
- CmdStan is optional (item 2 of part 1, item 3 of part 2):
  - `cmdstanr` and `posterior` are in `Suggests`. `bayesplot` is there too, because only the articles use it. RBesT imports `posterior`, so it is installed anyway.
  - Every Stan path goes through `compile_stan_model()`, which calls `check_stan_available()`. Without `cmdstanr` or CmdStan, the error tells the user to install them or to set `engine: quadrature`.
  - `GaussianCommensuratePowerPrior` and `GaussianCommensuratePrior` now run `inference()` by quadrature by default. Before, they always used Stan for one data set. `engine: stan` still selects Stan. On the Belimumab case study, quadrature agrees with Stan within Stan's run-to-run variation and is 3 to 50 times faster.
  - Under quadrature these two models report MCMC diagnostics as 0 in simulation results, not `NA`, like the other models that never sample.
  - Stan tests use `skip_if_not_installed("cmdstanr")`. With `cmdstanr` hidden, they skip and the quadrature tests pass. A new test file, `test-commensurate-quadrature-inference.R`, checks the quadrature posterior against an independent integral over tau.
  - The commensurate articles run without Stan. Their Stan sections run only when CmdStan is present.
  - README and `inst/scripts/install.R` no longer install CmdStan. `Rscript install.R --with-stan` adds it.

Still open:
- `roxygen2::roxygenise()` was run in the repo with the CmdStan change, so `man/` and `NAMESPACE` now match `R/`. Check that no other session's edits to `NAMESPACE` were lost.
- The remaining check warnings:
  - `cmdstanr` is a strong dependency (item 2 of part 1). Fixed; check again.
  - `qpdf` is missing on this machine (local tool, not a package problem).
- The remaining check notes:
  - Unused Imports: `BSDA`, `Hmisc`, `extraDistr`. (`bayesplot` is now in `Suggests`.) The code uses all three, but only inside R6 classes, which the check does not scan. To clear the note, add one `importFrom()` for each.
  - About 480 "no visible binding / global function" notes. Add `importFrom(stats, ...)` / `importFrom(utils, ...)` and `utils::globalVariables()` or `.data$`.
  - Rd "lost braces" in `GaussianPDCCPP.Rd` (`z_{1-c/2}`) and `method_parameter_positions.Rd`.
  - Undocumented R6 fields in `Model`, `MCMCModel`, `BinomialCPP` and `BinomialConjugate` (roxygen warning).
- Three tests fail in the source tree because uncommitted changes delete config folders (`inst/conf/combined/`, `combined_aprepitant/`, `pipeline_tests/`). They pass or skip in the check, which builds from a copy of the tree:
  - `test-analysis_design_prior.R`;
  - `test-compute-bayesian-ocs.R`;
  - `test-simulation_time_to_event.R`.
- Examples change global state on purpose: the plot and table examples source configs into `.GlobalEnv`. They restore options and the theme afterwards.
- The lattice code uses about 4 BLAS threads. Set `OPENBLAS_NUM_THREADS=2` in CI, so the CPU-to-elapsed-time ratio stays below CRAN's limit.

## 1. What blocks a CRAN release

### Must fix

1. **License conflict.** Done (2026-10-11). `LICENSE` says "Proprietary License … property of the European Medicines Agency … copying prohibited". DESCRIPTION and the README badge say GPL-3. CRAN accepts only open-source licenses, and it will reject this mismatch.
   - First get written permission from the EMA (and Quinten, if relevant) to release under GPL-3.
   - Then use `License: GPL (>= 3)`, with no `file LICENSE`.
   - Delete the proprietary text.
2. **`cmdstanr` in `Imports`.** Done (2026-10-11): `cmdstanr` is in `Suggests`, and quadrature is the default engine for every model. It is not on CRAN. CRAN packages may depend only on CRAN or Bioconductor packages. There are three options:
   - Move `cmdstanr` to `Suggests` and keep `Additional_repositories`. Guard every Stan call with `requireNamespace("cmdstanr", quietly = TRUE)`. Tests and vignettes must pass without it. This is the least work.
   - Switch to `rstan` with precompiled models through `rstantools`, as RBesT does. This is more work, but users then need no CmdStan install.
   - Drop MCMC where quadrature or lattice methods already exist. Many of the binomial methods seem to work this way already.
3. **`.Rbuildignore` excludes `^tests$`.** Done (2026-10-11). The tarball ships no tests, but CRAN expects tests that run within its time limit.
   - Remove that line.
   - Use `skip_on_cran()` on slow tests and Stan tests. Today only 2 tests use it, and 8 test files use Stan.
4. **Vignettes are only in subfolders** Done (2026-10-11). (`vignettes/methods/`, `vignettes/simulation/`, …). `R CMD build` builds only top-level `.Rmd` files, so CRAN sees no vignettes.
   - Move a few short vignettes to the top level.
   - Keep the rest as pkgdown articles.
   - Exclude the rendered `.html` files with `.Rbuildignore`. They bring the folder to 14 MB, and CRAN warns above 5 MB.
5. **`library()` calls in `R/`.** Done (2026-10-11). They are in `plot_effect_denominator_change_factor.R:1-2`, `plot_effect_target_standard_deviation.R:1-2` and `simulation_bayesian_ocs.R:1`. Remove them, because package code must not attach packages.
6. **`NeedsCompilation: yes` and `UseLTO: true` with no `src/`.** Done (2026-10-11). Remove both.
   - Also drop `Biarch`.
   - Remove the false `SystemRequirements` entries (pngquant, GNU make), unless the package really needs them.
7. **Examples.** Done (2026-10-11). Only 20 of 381 Rd files have `\examples`. CRAN asks for a runnable example for every exported function, and you export 143 objects. Wrap slow examples in `\donttest{}`, not `\dontrun{}`.

### Likely reviewer comments

- **Too many dependencies.** Done (2026-10-11). There were 44 `Imports`, and CRAN warns above 20. `Imports` now has 21 packages. CRAN counts 19 of them, because it does not count base packages (`parallel`, `tools`).
  - Plotting, table and report packages moved to `Suggests`: `ggplot2`, `ggnewscale`, `grid`, `gridExtra`, `latex2exp`, `purrr`, `stringr`, `viridis`, `knitr`, `kableExtra` and `tinytex`.
  - The parallel backend moved to `Suggests`: `foreach` and `doSNOW`. Only parallel runs need it.
  - Each entry point first calls `check_plot_packages()`, `check_table_packages()` or `check_parallel_packages()`. These call `rlang::check_installed()`, which names the missing packages and offers to install them.
  - Removed:
    - `extrafont` and `truncnorm`, which no code used;
    - `ParallelLogger`, so `futile.logger` is the only logger;
    - `doParallel`, because the analysis cluster now uses `doSNOW`, as the simulation cluster does.
  - Kept: `BSDA`, `Bolstad2`, `Hmisc` and `futile.logger`. The method code uses them, and we do not rewrite their functions only to cut the count.
  - NAMESPACE has no whole-package `import()`. It uses `importFrom()` only for names that the code calls without `pkg::`. Code calls the `Suggests` packages with `pkg::`.
- **Global side effects.**
  - `options(error = global_error_handler)` (`run_simulation_env.R:164`, now set for parallel runs too) and `options(clusterPort = …)` must be reset with `on.exit()` or `withr`.
  - `set.seed()` inside functions changes the user's RNG state.
  - File writes must default to `tempdir()` or a path the user gives. The cache uses `tools::R_user_dir()`, which is fine, but give users a way to clear it.
- **Cores.** The default is `parallel::detectCores()`. CRAN allows at most 2 cores during checks.
- **Console output.** There are 13 bare `print()` or `cat()` calls. Use `message()`, which users can silence.
- **DESCRIPTION.**
  - Write a real `Description` of several sentences. Do not start with "This package".
  - Name the methods and cite the papers as `<doi:…>`.
  - Quote package and software names, for example `'Stan'`.
  - Remove `Date` or keep it current.
  - Make sure the maintainer email will stay valid.
- **Missing files.** Add `NEWS.md`, `cran-comments.md` and `inst/CITATION`.
- **Bundled app code.** Done (2026-10-11). The paper-reproduction scripts, run configs and `paper_*` functions moved to the sister folder `../BExTEpaper`. `inst/scripts/` keeps only `install.R` and `knit_vignettes.R`. `inst/conf/` keeps the configs that the package code reads.

### Steps

1. Fix the items above.
2. Run `devtools::check(cran = TRUE)`, `rhub::rhub_check()` and `devtools::check_win_devel()`.
3. Get 0 errors, 0 warnings and 0 notes, apart from "New submission".

## 2. What it would take to be used like RBesT

RBesT succeeds because it does one job well: robust meta-analytic priors. Its API is small and stable, and its docs are tied to the method papers. It is easy to install. It also had a pharma sponsor (Novartis) and FDA/EMA use behind it. Measured against that, BExTE lacks the following.

1. **A small, clear user API.** Done (2026-10-11). BExTE exported 156 objects, many of them internal helpers or paper-specific functions, so a new user could not tell where to start. It now exports 73: 21 core functions, 7 cache and calibration utilities, and the 45 R6 classes.
   - The core: `source_data()`, `target_data()`; one prior builder per method (`separate_prior()`, `pooling_prior()`, `power_prior()`, `npp()`, `npp_kl()`, `rmp()`, `egidi_mixture()`, `commensurate_prior()`, `commensurate_power_prior()`, `eb_power_prior()`, `pvalue_power_prior()`, `pdccpp()`, `test_then_pool()`); `posterior()`, `ess()`, `decision()`; `oc_frequentist()`, `oc_bayesian()`, `design_prior()`.
   - The two kinds of operating characteristics have separate functions and result classes, as RBesT has `oc2S()` and `pos2S()`. `oc_frequentist()` fixes the true effect, and labels each row as type I error or power. `oc_bayesian()` averages over a design prior.
   - The 83 paper and pipeline functions (`plot_*`, `table_*`, `run_simulation_env()`, `simulation_*()`, the ESS and data-generation helpers, ...) are internal now, with `@keywords internal` and no `@examples`. Their code stays in BExTE.
   - `../BExTEpaper/setup.R` attaches the 9 pipeline functions its scripts call. Its `R/` code and tests already run inside the BExTE namespace.
   - The pkgdown articles in subfolders call the internal helpers with `BExTE:::`. CRAN does not build them.
   - Not checked: BExTE-app, which may call functions that are now internal.
   - Move the paper reproduction to a separate repo or a "BExTEpaper" package. Done (2026-10-11): it is now the plain project folder `../BExTEpaper`, with its own git repo.
2. **A standard R interface.** Done (2026-10-11). R6 classes such as `BinomialNPP$new()` feel foreign to most R statisticians. The functions above are an S3 front end over the R6 classes (`R/api_*.R`):
   - Builders return light specs. `posterior()` creates the R6 model through `Model$create()` and runs `inference()`. `post$model` gives the R6 object for advanced use.
   - `print`, `summary`, `plot`, `quantile` and `as.data.frame` methods cover the data, priors, posteriors, decision rules and both OC result classes.
   - `tests/testthat/test-s3-api.R` checks each wrapper against the direct R6 calls.
   - The vignettes "Get started with BExTE" (new), "The BExTE interface" (new, a guide to every function), "Separate analysis", "Pooling" and "Plan a trial: operating characteristics" use this API.
3. **Easy install.** Make the CmdStan requirement optional, or remove it. This matters more than anything else for uptake in pharma, where locked-down machines are common. Done (2026-10-11): no method needs Stan. Stan stays as an optional reference engine (`engine: stan`).
4. **Validation and trust.** Pharma users need:
   - a published method reference for each prior;
   - high test coverage;
   - results compared against reference packages (RBesT, `psborrow2`, `NPP`, `hdbayes`);
   - a validation report, as in RBesT's `inst/sbc` folder and validation vignette;
   - a stable version (1.0 or higher) with a change log.

   Also consider the R Validation Hub's `riskmetric` criteria.
5. **A peer-reviewed software paper.** Publish in the Journal of Statistical Software, the R Journal or JOSS, and add a `CITATION` file. Pair it with the methods paper.
6. **Short, task-based vignettes:**
   - "Get started: borrow a historical control in 5 minutes";
   - "Choose a borrowing method";
   - "Plan a trial: operating characteristics";
   - "Report to a regulator".

   The current vignettes are long, case-study driven, and live in subfolders.
7. **Community and visibility.**
   - Use a public GitHub repo with an open license and issues enabled. This depends on item 1 of part 1.
   - Get listed in the CRAN Task View *ClinicalTrials*.
   - Give talks at PSI, the R/Pharma conference and the useR! conference.
   - Join the openstatsware / ASA BIOP software working group.
   - Get an EMA or industry case study that uses the package.
8. **Long-term care.** Make a clear maintenance plan with two or more named maintainers and a funding or institutional home. Users avoid packages that may be abandoned.

## Suggested order

1. Fix the license.
2. Make `cmdstanr` optional. Done (2026-10-11).
3. Cut down the exported API. Done (2026-10-11), and the dependencies are done.
4. Do the CRAN check items and submit to CRAN.
5. Work on the paper and the outreach.
