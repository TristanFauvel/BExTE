# Reproducing the paper's figures and tables

These steps rerun only the simulations that the paper's figures and tables
need, not the full simulation study, and then produce those outputs under
the numbers the manuscript uses (Figure 1–4, Figure S3–S52, Table S1, S3,
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
simulates only those, at the paper's fidelity, and exports the outputs:

- 30 drift points per scenario;
- 10,000 replicates per scenario for the continuous, recurrent-event and
  time-to-event case studies;
- no replicates at all for the two binary case studies, Aprepitant and
  Belimumab. A trial there reaches the analysis only through the responder
  counts of its two arms, so each operating characteristic is summed exactly
  over every pair of counts, weighted by its binomial probability, instead of
  averaged over simulated trials (`exact_enumeration` in the scenarios
  config). The pairs left out have probability below 1e-10. These results
  have no Monte Carlo error and their figures no error bars, and
  `BEXTE_N_REPLICATES` does not affect them. Aprepitant is analysed with its
  exact binomial likelihood; its posteriors are computed by quadrature rather
  than MCMC (see below);
- after the simulations, only the two analysis steps the figures read: the
  power baselines at the equivalent and at the nominal type I error rate. The
  sweet spot and the Bayesian operating characteristics are skipped.

**Run time.** Measured on a 12-core, 32 GB workstation:

- The five normal-likelihood case studies (botox, belimumab, dapagliflozin,
  mepolizumab, teriflunomide): about 9 hours of simulation at 10,000
  replicates, then about 1 hour for the two analysis steps.
  Belimumab is now enumerated rather than simulated, and that run time has
  not been re-measured.
- Aprepitant: an estimated 2.5 hours on 11 workers for the four methods that
  used to be the bottleneck, at 10,000 replicates. Aprepitant is now
  enumerated rather than simulated, which analyses about as many distinct
  pairs of counts as 10,000 replicates did; this has not been timed end to
  end either. The estimate was made from
  measured costs per analysis, not an end-to-end timing: the conditional power
  prior, the p-value-based power prior, the RMP and the Egidi RMP
  (`egidi_empirical_mixture`) take 0.04 to 0.8 CPU seconds per analysis by
  quadrature, against about 1 to 2 seconds by MCMC. Replicates that land on
  the same counts share one analysis, which at 10,000 replicates removes 13
  to 22 times the work. The separate and pooled analyses, and so
  test-then-pool, were already computed by quadrature. By MCMC, the same four
  methods took about 9.5 hours at only 100 replicates and would take about
  three weeks at 10,000.

  The MCMC path is still available for comparison: set `engine: stan` in the
  run's `mcmc_config.yml`. The two engines agree to within the Monte Carlo
  error of the sampler; test decisions differ only for datasets whose
  posterior probability of benefit lies within about 0.001 of 0.975.

- Figures S45–S52, the Teriflunomide time-to-event sensitivity analysis,
  need seven extra designs at 123 participants per arm: 5% and 10% loss to
  follow-up, Weibull event times, control-arm heterogeneity of ±0.405, and a
  treatment effect delayed by 12 or 24 weeks (non-proportional hazards). Each
  moves one axis away from the primary design. On a 12-core workstation, the
  eight designs took about 15 minutes at 100 replicates, so expect up to a day
  at the paper's 10,000. Leave S45–S52 out of the list to skip them. Selected
  on their own, they need only this teriflunomide block.

To reproduce everything except aprepitant, leave out Figures S33–S37 and S41
when listing the outputs.

Run it detached from your session, so that neither closing the terminal nor
a crash of the application it runs in can kill it. On Linux, a user systemd
service does both and also caps the run's memory; `BEXTE_MAX_WORKERS` lowers
the number of parallel workers, which is what memory grows with:

```sh
systemd-run --user --unit=bexte-paper-run -p MemoryHigh=12G -p Nice=10 \
  --working-directory="$PWD" -E BEXTE_MAX_WORKERS=6 \
  -p StandardOutput=append:"$PWD/reproduce.log" \
  -p StandardError=append:"$PWD/reproduce.log" \
  Rscript inst/scripts/reproduce_paper.R
```

`nohup` or `tmux` also survive closing the terminal, but not a crash of the
editor or terminal application that started them: systemd stops the whole
application, and with it everything launched from its terminals.

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
  versions should reproduce the figures up to Monte Carlo error. The paper's
  Aprepitant and Belimumab figures were simulated, so the exact results
  differ from them by that paper run's Monte Carlo error. Parallel
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

There is also a browser interface: the **Replicate paper** page of
[BExTE-app](https://github.com/TristanFauvel/BExTE-app) does the same three
steps with checkboxes.
