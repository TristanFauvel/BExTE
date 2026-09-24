# Reproducing the paper's figures and tables

These steps rerun only the simulations that the paper's figures and tables
need, not the full simulation study, and then produce those outputs under
the numbers the manuscript uses (Figure 1–4, Figure S3–S44, Table S1, S3,
S5, and the extra figures X1–X3).

## 1. Install

You need R 4.5, a C++ toolchain, and CmdStan. From the root of the checkout:

```r
renv::restore()                              # the exact package versions in renv.lock
cmdstanr::check_cmdstan_toolchain(fix = TRUE)
cmdstanr::install_cmdstan()                  # skip if CmdStan is already installed
```

Then **install** the package. `devtools::load_all()` is not enough. The
simulations run in parallel worker processes, and those workers load the
installed package, not the checkout:

```sh
R CMD INSTALL .
```

Reinstall after every `git pull`. Otherwise the workers run the old code.

## 2. Check the pipeline with a smoke test (a few minutes)

Run this from the directory where outputs should go. It creates `results/`,
`logs/`, `user_configs/`, `figures/` and `tables/` there:

```sh
BEXTE_N_REPLICATES=200 BEXTE_NDRIFT=3 Rscript inst/scripts/reproduce_paper.R 2 S4
```

It should finish with `2 of 2 outputs produced`. These settings are only for
checking the setup; the numbers are **not** the paper's.

## 3. Run the reproduction

```sh
Rscript inst/scripts/reproduce_paper.R            # every paper output
Rscript inst/scripts/reproduce_paper.R --main     # Figures 1-4 only
Rscript inst/scripts/reproduce_paper.R 1 S10 TS5  # a chosen subset
```

The script reads the manifest in `R/paper_figures_manifest.R` and works out
the case studies, sample sizes and methods that the selection plots. It then
simulates only those, at the paper's fidelity: 10,000 replicates and 30 drift
points per scenario. Finally it exports the outputs.

**Run time.** The full reproduction took about 17 hours on a 12-core, 32 GB
workstation. A subset takes less, roughly in proportion to the case studies
it involves. Run it inside `tmux`/`screen` or with `nohup`, so that closing
the terminal does not kill it:

```sh
nohup Rscript inst/scripts/reproduce_paper.R > reproduce.log 2>&1 &
```

## 4. Where the outputs are

For a run named `paper_replication_<date>_<time>`:

| What | Where |
|---|---|
| Outputs named as in the paper (`Figure 1.png`, `Table S5.tex`, ...) | `figures/publication_figures/<run>/paper_outputs/` |
| The same figures under their generated filenames | `figures/publication_figures/<run>/` |
| Tables, plus `manifest.csv` mapping each file to its paper number | `tables/publication_tables/<run>/` |
| Simulation results | `results/<run>/results_frequentist.csv` |

To regenerate the figures from finished results, without simulating again,
for example after changing a plot:

```sh
BEXTE_RESULTS_DIR=results/paper_replication_<date>_<time> Rscript inst/scripts/reproduce_paper.R
```

## What to expect

- **Reproducibility.** The simulation seed is fixed (`seed: 42` in
  `inst/conf/simulation_config.yml`). The same commit on the same package
  versions should reproduce the figures up to Monte Carlo error. Parallel
  scheduling can change the order in which random numbers are consumed, so
  small differences are not a sign of a problem.
- **Commensurate priors.** The commensurate power prior and the commensurate
  prior are computed by quadrature, not MCMC. They use five priors on the
  commensurability parameter τ: τ² ~ IG(α, 1) with α ∈ {1/3, 1/7}, the
  Cauchy(0, 30) on log τ of Hobbs et al. (2011), and τ ~ HN(σ) with
  σ ∈ {1, 5}.

## If something goes wrong

- **The run stops before exporting.** `results/<run>/results_frequentist.csv`
  is only written when every scenario has finished. Read
  `logs/<run>/error_logs/`. An error raised inside a parallel worker is only
  recorded on the script's stderr, so read `reproduce.log` too.
- **`there is no package called 'BExTE'` or a missing dependency in a
  worker.** The package is not installed where the workers look. Run
  `R CMD INSTALL .` again, from the same R session setup (renv) that you
  run the script with.
- **Some outputs report a failure.** The export prints one status line per
  output, and the script exits with a non-zero status. The failure reason is
  in the status table.

There is also a browser interface: `BExTE::run_bexte_app()`, then the
**Replicate paper** page, does the same three steps with checkboxes.
