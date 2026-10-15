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

BExTE needs R >= 4.0. 

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
check how robust the decision is, and plan the trial:

```r
library(BExTE)

# Read both studies from a case-study configuration file ...
cfg  <- system.file("conf/case_studies/belimumab.yml", package = "BExTE")
src  <- source_data(config = cfg)
tgt  <- target_data(config = cfg)
# ... or give the arm sizes and response counts
src  <- source_data(n_control = 562, n_treatment = 563,
                    responses_control = 218, responses_treatment = 285)
tgt  <- target_data(n_control = 39, n_treatment = 53,
                    responses_control = 17, responses_treatment = 28)
pri  <- rmp(src, weight = 0.5)          # or npp(), power_prior(), commensurate_prior(), ...
post <- posterior(pri, tgt)
summary(post); plot(post); ess(post)

success <- decision(critical_value = 0.975)
success(post)

# Tipping points: the prior weight and the number of treatment responders
# at which the decision changes
tipping_point(pri, tgt, success, parameter = "weight", values = seq(0, 1, by = 0.1))
tipping_point(pri, tgt, success, parameter = "responses_treatment", values = c(0, 53))

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

### Simulation studies

BExTE computes the operating characteristics of one design. To compare
methods over a grid of scenarios, use
[BExTEsim](https://github.com/TristanFauvel/BExTE-sim). It reads YAML
configurations of case studies, scenarios and methods, runs the simulations
(in parallel if asked), writes the results to files and makes the plots and
tables:

```r
remotes::install_github("TristanFauvel/BExTE-sim")
library(BExTEsim)  # also attaches BExTE
```

### Reproducing the paper

The scripts that run the paper's simulation study and make its figures and
tables live in BExTEpaper, a separate folder next to this package. See the
README there.

### Browser-based interface

Instead of hand-editing config files and running scripts, you can
configure, run, and analyze a simulation study from a browser with
[BExTE-app](https://github.com/TristanFauvel/BExTE-app), a Shiny app built on
BExTEsim:

```r
remotes::install_github("TristanFauvel/BExTE-app")
BExTEapp::run_bexte_app()
```

## What is implemented

### Borrowing methods

Each method builds a prior from the source study. Use the function for an
analysis; use the `method` name in a simulation configuration file. Every
method works with both likelihoods of the next table.

| Method | Function | `method` name | What sets the amount of borrowing | Reference |
| --- | --- | --- | --- | --- |
| Separate analysis | `separate_prior()` | `separate` | Nothing: the source study is dropped | - |
| Pooling | `pooling_prior()` | `pooling` | Nothing: source patients count as target patients | - |
| Power prior | `power_prior()` | `conditional_power_prior` | A fixed power `a0` on the source likelihood | Ibrahim and Chen (2000) |
| Normalised power prior | `npp()` | `NPP` | A Beta prior on the power | Duan, Ye and Smith (2006) |
| KL-calibrated normalised power prior | `npp_kl()` | `NPP_KL` | A Beta prior on the power, calibrated to the target design | New in BExTE |
| Robust mixture prior | `rmp()` | `RMP` | A fixed weight on the source component | Schmidli et al. (2014) |
| Empirical mixture prior | `egidi_mixture()` | `egidi_empirical_mixture` | The mixture weight, read from the prior-data conflict in the target data | Egidi, Pauli and Torelli (2022) |
| Commensurate prior | `commensurate_prior()` | `commensurate_prior` | A heterogeneity parameter learnt from the data | Hobbs et al. (2011) |
| Commensurate power prior | `commensurate_power_prior()` | `commensurate_power_prior` | A heterogeneity parameter and a power on the source likelihood | Hobbs et al. (2011) |
| Empirical Bayes power prior | `eb_power_prior()` | `EB_PP` | The power, estimated by empirical Bayes from the target data | Gravestock and Held (2017) |
| p-value based power prior | `pvalue_power_prior()` | `p_value_based_PP` | The power, from the p-value of a test of equivalence between the studies | Liu et al. (2018) |
| Conflict-calibrated power prior | `pdccpp()` | `PDCCPP` | The power, from the distance between the studies, calibrated to a type I error rate | Nikolakopoulos et al. (2018) |
| Test-then-pool (difference) | `test_then_pool(type = "difference")` | `test_then_pool_difference` | A test for a difference between the studies | Viele et al. (2014) |
| Test-then-pool (equivalence) | `test_then_pool(type = "equivalence")` | `test_then_pool_equivalence` | A test of equivalence between the studies | Viele et al. (2014) |

The R6 class behind each method depends on the likelihood, for example
`BinomialNPP` and `GaussianNPP`. The reference website lists them all.

### Likelihoods

The likelihood is the `likelihood` argument of `source_data()`, and the
`summary_measure_likelihood` field of a case-study configuration. It fixes the
scale of the treatment effect and how the posterior is computed.

| Likelihood | Name | Endpoints | Treatment effect | Posterior |
| --- | --- | --- | --- | --- |
| Normal | `normal` | All four endpoints below | Log odds ratio, mean difference, log hazard ratio or log rate ratio | Closed form, or quadrature over the borrowing parameters |
| Exact binomial | `binomial` | Binary only | Risk difference | Quadrature over the arm response rates and the borrowing parameters |

Stan is an optional reference engine for two families: the binomial
conditional power priors and the Gaussian commensurate priors. Set
`engine: stan` in the MCMC configuration to use it.

### Endpoints

The endpoint sets how target study replicates are drawn. It comes from the
`endpoint` field of a case-study configuration. `source_data()` and
`target_data()` read a binary or a continuous endpoint from their arguments;
the other two endpoints need a configuration file.

| Endpoint | Name | Treatment effect | Replicates drawn from |
| --- | --- | --- | --- |
| Binary | `binary` | Risk difference or log odds ratio | Binomial counts in each arm |
| Continuous | `continuous` | Mean difference | Normal arm means |
| Time to event | `time_to_event` | Log hazard ratio | Exponential or Weibull event times, under a fixed-calendar design with accrual, follow-up and dropout |
| Recurrent event | `recurrent_event` | Log rate ratio | Negative binomial event counts in each arm |

### Design and analysis tools

| Tool | Function | What it gives |
| --- | --- | --- |
| Posterior | `posterior()`, `summary()`, `quantile()`, `plot()` | Mean, standard deviation, median and credible intervals of the target treatment effect, and the posterior of the borrowing parameters |
| Decision rule | `decision()` | Success when the posterior probability of benefit exceeds a critical value |
| Effective sample size | `ess()` | The prior ESS, by the `"elir"`, `"moment"` or `"precision"` rule |
| Tipping point | `tipping_point()` | The value of a prior, target data or decision argument at which the decision changes |
| Frequentist operating characteristics | `oc_frequentist()` | Probability of success at fixed true effects, which is the type I error rate under the null and the power outside it, with bias, mean squared error, coverage, credible interval half width and interval score |
| Bayesian operating characteristics | `oc_bayesian()` | Probability of success averaged over a design prior, split into average power, average type I error rate, and pre-posterior true and false positive probabilities |
| Design prior | `design_prior()` | The distribution of the true target effect: `"source_posterior"`, `"unit_information"` or `"analysis_prior"` |

A simulation study with BExTEsim adds the sweet spot of each metric: the range of drift over
which a method beats the separate analysis, or a nominal value such as the
target type I error rate.

### Case studies

`system.file("conf/case_studies", package = "BExTE")` holds six paediatric
extrapolation examples. Each one gives the source and target studies, the null
hypothesis and the endpoint.

| Case study | Endpoint | Likelihood | Source size | Target size |
| --- | --- | --- | --- | --- |
| Aprepitant | Binary | `binomial` | 573 | 109 |
| Belimumab | Binary | `normal` | 1125 | 92 |
| Botox | Continuous | `normal` | 468 | 256 |
| Dapagliflozin | Continuous | `normal` | 267 | 157 |
| Mepolizumab | Recurrent event | `normal` | 551 | 25 |
| Teriflunomide | Time to event | `normal` | 1483 | 166 |

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

## Comparison with other Bayesian borrowing packages

These packages cover different borrowing questions. The table highlights their documented scope rather than ranking methods or comparing performance.

| Package | Borrowing approaches | Data and models | Design and analysis tools |
| --- | --- | --- | --- |
| **BExTE** | Fixed and normalised power priors, robust mixtures, commensurate priors, empirical Bayes and test-based rules | Source and target treatment effects from two-arm binary, continuous, time-to-event or recurrent-event studies | Posterior analysis, effective sample size, and frequentist and Bayesian operating characteristics across source-to-target drift scenarios |
| [hdbayes](https://CRAN.R-project.org/package=hdbayes) | Power, normalised power, hierarchical, commensurate, robust MAP and latent-exchangeability priors | GLMs and survival models; multiple historical data sets | Posterior sampling, marginal likelihoods and Bayesian model averaging |
| [psborrow2](https://CRAN.R-project.org/package=psborrow2) | Hierarchical commensurate prior for borrowing external control data | Two-arm trials with external controls; binary, continuous and time-to-event endpoints | Data generation and simulation studies across borrowing settings, sample sizes and covariates |
| [RBesT](https://CRAN.R-project.org/package=RBesT) | Meta-analytic predictive (MAP) and robust MAP priors | Historical studies with normal, binomial or Poisson outcomes | Prior derivation, effective sample size, trial analysis and operating-characteristic evaluation |
| [NPP](https://CRAN.R-project.org/package=NPP) | Normalised power priors, including multiple historical data sets | Bernoulli, normal, Poisson and multinomial outcomes, plus regression models | Posterior and power-parameter sampling |

BExTE's standard analysis uses closed-form updates or quadrature; Stan is optional for selected methods. The linked package pages and their reference manuals describe the current scope of the other packages.

## Contributing

New contributors are always welcome. Please have a look at the [contribution guidelines](CONTRIBUTING.md) on how to get started and to make sure your code complies with our guidelines.

## Rationale of the design

The core of the code implements the inference logic: a source data class represents source data, which are observed. Target data are represented in a different class. They different as we can sample target data replicates. When initializing a model, source data are provided to it, as well as methods parameters and MCMC configuration (if applicable), so as to define a prior. Inference is performed by using the inference method on target data, which updates properties of the model object with moments of the treatment effect posterior distribution and, if applicable, computes the posterior distribution of borrowing parameters. Note that inference proceeds in two steps: first, if the method uses empirical Bayes, prior parameters are updated based on the target data sample, second Bayes" rule is applied.

When BExTEsim launches a simulation study, all scenarios are generated based on the provided configuration files. These scenarios are then sequentially treated: source data and target data are initiated, and a model is defined. Target data replicates are then generated depending on the target data characteristics. The model is then fitted on each data replicate, and the corresponding inference metrics and frequentist metrics are computed.
The data from the simulation are then analyzed: the sweet spot is computed for each metric of interest, and the Bayesian operating characteristics are estimated.
