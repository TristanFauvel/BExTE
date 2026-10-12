# Bayesian Extrapolation of Treatment Effects

[![R Package Build](https://github.com/TristanFauvel/BExTE/actions/workflows/build.yml/badge.svg)](https://github.com/TristanFauvel/BExTE/actions/workflows/build.yml)
[![pkgdown](https://github.com/TristanFauvel/BExTE/actions/workflows/pkgdown.yml/badge.svg)](https://tristanfauvel.github.io/BExTE/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version](https://img.shields.io/badge/version-0.0.2-blue.svg)](DESCRIPTION)
[![R >= 3.5.0](https://img.shields.io/badge/R-%3E%3D3.5.0-276DC3.svg)](https://www.r-project.org/)

A collection of R tools to :

- Study frequentist and Bayesian operating characteristics of clinical trial designs leveraging Bayesian partial extrapolation (also known as borrowing).
- Analyze clinical trial data using Bayesian partial extrapolation methods.

<div class="row row-cols-1 row-cols-sm-2 row-cols-lg-4 g-3 my-4">
<div class="col"><a href="articles/index.html" class="card h-100 text-decoration-none"><div class="card-body"><h5 class="card-title">📚 Vignettes</h5><p class="card-text small text-muted">Step-by-step guides to simulation studies, data generation, borrowing methods, and case-study replications.</p></div></a></div>
<div class="col"><a href="reference/index.html" class="card h-100 text-decoration-none"><div class="card-body"><h5 class="card-title">🔧 API reference</h5><p class="card-text small text-muted">Every exported function and R6 class, grouped by topic: data, priors, fitting, operating characteristics, and the R6 classes.</p></div></a></div>
<div class="col"><a href="https://github.com/TristanFauvel/BExTE-app" class="card h-100 text-decoration-none"><div class="card-body"><h5 class="card-title">🖥️ Browser app</h5><p class="card-text small text-muted">Configure, run, and analyze a simulation study from BExTE-app, a separate Shiny app, without hand-editing config files.</p></div></a></div>
<div class="col"><a href="news/index.html" class="card h-100 text-decoration-none"><div class="card-body"><h5 class="card-title">📝 Changelog</h5><p class="card-text small text-muted">What changed in each release.</p></div></a></div>
</div>


## Quick start

### Installation

BExTE needs R >= 4.0. It needs no C++ toolchain and no CmdStan: every method
computes its posterior by quadrature or in closed form.

Download `BExTE_0.0.2.tar.gz` and `install.R` from the latest release into the
same directory, then run:

```
Rscript install.R
```

That installs the dependencies and BExTE itself. Load the package with:

```r
library(BExTE)
```

<details>
<summary>Installing by hand</summary>

```r
install.packages("pak")
pak::pkg_install("local::/path/to/BExTE_0.0.2.tar.gz")
```

</details>

### A first analysis

Describe the source study, choose a borrowing prior, analyse the target study,
and plan the trial:

```r
library(BExTE)

src  <- source_data(config = system.file("conf/case_studies/belimumab.yml", package = "BExTE"))
tgt  <- target_data(n_control = 39, n_treatment = 53,
                    responses_control = 17, responses_treatment = 28)
pri  <- rmp(src, weight = 0.5)          # or npp(), power_prior(), commensurate_prior(), ...
post <- posterior(pri, tgt)
summary(post); plot(post); ess(post)

success <- decision(critical_value = 0.975)
success(post)

# Frequentist operating characteristics: type I error and power at fixed true effects
oc_frequentist(pri, success, n_per_arm = 46, drift = c(-0.48, 0, 0.3), n_rep = 1000)
# The same, for arms of different sizes
oc_frequentist(pri, success, n_control = 39, n_treatment = 53, drift = 0, n_rep = 1000)
# Bayesian operating characteristics: averaged over a design prior
oc_bayesian(pri, success, design_prior("source_posterior"), n_per_arm = 46)
```

The vignette "Get started with BExTE" (`vignette("BExTE")`) walks through these
steps. The R6 classes behind these functions (for example `Model` and
`BinomialNPP`) stay available for advanced use.

<details>
<summary>Optional: Stan as a reference engine</summary>

Two families of methods can also sample their posterior with Stan, as a check
on the quadrature: the binomial conditional power priors and the Gaussian
commensurate priors. To use it, set `engine: stan` in the MCMC configuration
and install `cmdstanr` and CmdStan. `cmdstanr` is not on CRAN:

```r
install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev",
                                        getOption("repos")))
cmdstanr::check_cmdstan_toolchain(fix = TRUE)
cmdstanr::install_cmdstan()
```

Alternatively, run `Rscript install.R --with-stan`.

</details>

<details>
<summary>Working from a source checkout</summary>

`renv.lock` pins every dependency. From the checkout:

```r
renv::restore()
devtools::load_all()
```

</details>

### Reproducing the paper

The scripts that run the paper's simulation study and make its figures and
tables live in BExTEpaper, a separate folder next to this package. See the
README there.

### Browser-based interface

Instead of hand-editing config files and running scripts, you can
configure, run, and analyze a simulation study from a browser with
[BExTE-app](https://github.com/TristanFauvel/BExTE-app), a Shiny app built on
this package:

```r
remotes::install_github("TristanFauvel/BExTE-app")
BExTEapp::run_bexte_app()
```

## Design logic

There are three main objects in the simulation framework: source data, target data, and models.
Source data are defined based on the case study configuration. Target data depend on the source data, and the specific scenario (drift, sample size). Models correspond to specific methods, and depend on the source data. They implement methods to estimate their operating characteristics. The target data objects implement a sample method, allowing to sample many replicates of the target study.

## Access documentation

The full documentation website is available at [tristanfauvel.github.io/BExTE](https://tristanfauvel.github.io/BExTE/).

To access it locally instead :
browseURL("docs/index.html")

## Methods and configurations requiring MCMC inference

MCMC inference with Stan is used in the following scenarios :

- RMP x aprepitant
- separate x aprepitant
- pooling x aprepitant
- conditional_power_prior x aprepitant

When using MCMC inference, the method inherits from the MCMCModel class. The initialize() method contains a string with the Stan code. This code is saved in a temporary Stan file which is used to compile the model (using `self$stan_model <- cmdstanr::cmdstan_model(stan_file_path)`). At inference

### Comparison with existing packages

- psborrow2 implements Bayesian dynamic borrowing in scenarios where a two-arm RCT is supplemented with external data on the control arm.

- RBEsT focuses on meta-analytic and mixture models

## Contributing

New contributors are always welcome. Please have a look at the [contribution guidelines](CONTRIBUTING.md) on how to get started and to make sure your code complies with our guidelines.

## Rationale of the design

The core of the code implements the inference logic: a source data class represents source data, which are observed. Target data are represented in a different class. They different as we can sample target data replicates. When initializing a model, source data are provided to it, as well as methods parameters and MCMC configuration (if applicable), so as to define a prior. Inference is performed by using the inference method on target data, which updates properties of the model object with moments of the treatment effect posterior distribution and, if applicable, computes the posterior distribution of borrowing parameters. Note that inference proceeds in two steps: first, if the method uses empirical Bayes, prior parameters are updated based on the target data sample, second Bayes" rule is applied.

When launching a simulation study, all scenarios are generated based on the provided configuration files. These scenarios are then sequentially treated: source data and target data are initiated, and a model is defined. Target data replicates are then generated depending on the target data characteristics. The model is then fitted on each data replicate, and the corresponding inference metrics and frequentist metrics are computed.
The data from the simulation are then analyzed: the sweet spot is computed for each metric of interest, and the Bayesian operating characteristics are estimated.
