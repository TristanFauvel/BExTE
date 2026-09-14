# Simulation study logic - low level

## Introduction

In the vignette “Simulation study logic - high level”, we illustrated
how to run the simulation study. We saw that many aspects are abstracted
away, to improve ease of use. In this vignette, we dive deeper into some
core aspects of the implementation. Methods implementation are described
in separate vignettes.

## Load the Belimumab case study configuration

Load the simulation configuration and the Belimumab case study
configuration from YAML files.

``` r

set.seed(42)
config_path <- system.file("conf/simulation_config.yml", package = "BExTE")
simulation_config <- yaml::yaml.load_file(config_path)

env <- "full"
config_dir <- paste0(system.file(paste0("conf/", env), package = "BExTE"), "/")
scenarios_config <- yaml::read_yaml(paste0(config_dir, "scenarios_config.yml"))

case_study <- "belimumab"
config_path <- system.file("conf/case_studies/belimumab.yml", package = "BExTE")
case_study_config <- yaml::yaml.load_file(config_path)
```

The case study configuration file contains all necessary information
about the case study, this includes: treatment effect distribution,
endpoint type, side of the null hypothesis, sample sizes, treatment
effect estimate in the source study, etc.

The simulation configuration specifies parameters such as the number of
simulation replicates, the number of drift values considered, the
critical value for the Bayesian decision criterion, the environment, the
case studies to iterate on and the methods considered.

Any modification to the simulation settings should be made through these
configuration files.

## Specific scenario

For a given case study, we will loop over different methods. Here, we
choose the RMP for illustration. For the considered method, we also loop
over target study sample size, drift, control drift, and method
parameters.

Here, we choose the following :

``` r

method <- "RMP"
method_parameters <- list(
  initial_prior = "noninformative", # This corresponds to the fact that the posterior for the adults data is derived from an uninformative prior (for consistency with other methods). May be removed in future releases.
  prior_weight = 0.5, # weight on the informative component of the mixture
  empirical_bayes = FALSE # Corresponds to whether some parameters of the prior are based on observed data.
)

target_sample_size_per_arm <- 91
drift <- 0.4
```

## Create data objects

If we wanted to load the original source study data without any
modification, we would use :

``` r

original_source_data <- ObservedSourceData$new(case_study_config)
```

Specify the denominator in the source data summary measure:

``` r

odds_control <- original_source_data$control_rate / (1 - original_source_data$control_rate)
denominator_change_factor <- 1.5
source_denominator <- denominator_change_factor * odds_control

source_data <- SourceData$new(case_study_config, source_denominator)
print(source_data$to_dict())
```

    ## $source_treatment_effect_estimate
    ## [1] 0.480132
    ## 
    ## $source_standard_error
    ## [1] 0.1206626
    ## 
    ## $endpoint
    ## [1] "binary"
    ## 
    ## $summary_measure_likelihood
    ## [1] "normal"
    ## 
    ## $source_sample_size_control
    ## [1] 562
    ## 
    ## $source_sample_size_treatment
    ## [1] 563
    ## 
    ## $equivalent_source_sample_size_per_arm
    ## [1] 562.4996
    ## 
    ## $source_control_rate
    ## [1] 0.4873323
    ## 
    ## $source_treatment_rate
    ## [1] 0.6057425

## Data generation

Create an instance of the BinaryTargetData class, which will allow us to
sample target study data. Note that this target_data depends on the
specific parameters chosen for the scenario (in particular, the drift
and target sample size).

The `TargetData` class implements a method to generate treatment effect
summary measures. This data generation method depends on the endpoint
and whether we use sampling approximation or not. Let us illustrate this
in the Belimumab example.

``` r

summary_measure_likelihood <- case_study_config$summary_measure_likelihood
endpoint <- case_study_config$endpoint

print(summary_measure_likelihood)
```

    ## [1] "normal"

``` r

print(endpoint)
```

    ## [1] "binary"

Here, the endpoint is binary, but we assume that the treatment effect
(which is a log(OR)), is normally distributed. We can sample the
treatment effect summary measure for each replicate by sampling a
Gaussian, which is an approximation to the true data-generating process.
The use of this approximation is determined by specifying
`sampling_approximation = TRUE` in the case study configuration file. By
setting `sampling_approximation = FALSE`, we sampled data according to
the true data-generating process. This is recommended for small target
study sample sizes (typically less than 40 per arm).

First, let’s instantiate the target data object (and then we will see
how to sample synthetic data):

``` r

target_data <- TargetDataFactory$new()

target_data <- target_data$create(source_data = source_data, case_study_config = case_study_config, target_sample_size_per_arm = target_sample_size_per_arm, treatment_drift = drift, summary_measure_likelihood = source_data$summary_measure_likelihood)
```

### Applying drift

When instantiating the target_data object, we first need to compute the
response rates in the control and treatment arms based on treatment and
control drifts. This is, in turn, used to determine the true treatment
effect, and the sampling standard deviation.

Here, we reproduce the code that is contained in the BinaryData class
definition :

``` r

self <- target_data
```

The following is used for normally distributed treatment effects :

``` r

# We compute the rate in each arm, based on the drift (defined on the log scale)
self$control_rate <- source_data$control_rate
self$treatment_rate <- rate_from_drift_logOR(drift, source_data$treatment_rate)

# The target treatment effect corresponds to the source treatment effect+ the drift
self$treatment_effect <- self$drift + source_data$treatment_effect_estimate

# We compute the sampling standard deviation for the summary measure:
self$standard_deviation <- standard_error_log_odds_ratio(
  self$sample_size_control * (1 - self$control_rate),
  self$sample_size_treatment * (1 - self$treatment_rate),
  self$sample_size_control * self$control_rate,
  self$sample_size_treatment * self$treatment_rate
) * sqrt(self$sample_size_per_arm)

print(self$treatment_effect)
```

    ## [1] 0.880132

``` r

print(self$standard_deviation)
```

    ## [1] 2.935578

### Approximate sampling

Now, let’s take a look at the `generate()` method of the
`BinaryTargetData` class. In case when then normal sampling
approximation is used, this function return n_replicates samples.
`self$treatment_effect` is the mean and `self$standard_deviation` is the
standard deviation of the Gaussian we will sample summary data from.

``` r

n_replicates <- scenarios_config$n_replicates
samples <- sample_aggregate_normal_data(self$treatment_effect, self$standard_deviation^2, n_replicates, self$sample_size_per_arm)

samples <- data.frame(
  treatment_effect_estimate = samples$treatment_effect_estimate,
  treatment_effect_standard_error = samples$treatment_effect_standard_error,
  sample_size_per_arm = samples$sample_size_per_arm
)
```

Note that the whole implementation always assumes that the number of
participants in each arm of the target study is the same.

What `sample_aggregate_normal_data` does is that is returns a sample
mean and a sample variance for normally distributed data (we proceed
this way because the sample mean and sample variance are not
independent):

``` r

read_function_code(sample_aggregate_normal_data)
```

    ## sample_aggregate_normal_data <- function (mean, variance, n_replicates, n_samples_per_arm) 
    ## {
    ##     sample_mean <- rnorm(n_replicates, mean = mean, sd = sqrt(variance/n_samples_per_arm))
    ##     if (n_samples_per_arm > 1) {
    ##         degrees_of_freedom <- n_samples_per_arm - 1
    ##         sample_variance <- variance * rchisq(n_replicates, df = degrees_of_freedom)/degrees_of_freedom
    ##     }
    ##     else {
    ##         sample_variance <- rep(NA_real_, n_replicates)
    ##     }
    ##     sample_standard_error <- sqrt(sample_variance/n_samples_per_arm)
    ##     samples <- data.frame(treatment_effect_estimate = sample_mean, 
    ##         treatment_effect_standard_error = sample_standard_error, 
    ##         sample_size_per_arm = n_samples_per_arm, standard_deviation = sqrt(sample_variance))
    ##     return(samples)
    ## }

So, the “samples” correspond, for each replicate, to the corresponding
sample mean and standard error on the mean.

### Exact sampling

“Exact sampling”, in this context, means that we rely on the true
data-generating process.

``` r

log_OR_samples <- sample_log_odds_ratios(self$sample_size_control, self$sample_size_treatment, self$treatment_rate, self$control_rate, n_replicates)

samples <- data.frame(treatment_effect_estimate = log_OR_samples$log_odds_ratio, treatment_effect_standard_error = log_OR_samples$std_err_log_odds_ratio, sample_size_per_arm = self$sample_size_per_arm)
```

### Estimation of OCs based on the samples

For a given target treatment effect, we generate some simulated summary
data :

Note that, here, we sample aggregate data from a normal distribution
(this is specified in `case_study_config`):

``` r

print(case_study_config$sampling_approximation)
```

    ## [1] FALSE

``` r

target_data_samples <- target_data$generate(n_replicates)
```

We create the model, loop through the replicates, perform inference, and
compute the test decision and important characteristics of the posterior
distribution of the target treatment effect (mean, median, credible
interval) as well as, if applicable, the posterior value of borrowing
parameters (such as the posterior weight in the RMP).

``` r

model <- Model$new()

model <- model$create(
  case_study_config = case_study_config,
  method = method,
  method_parameters = method_parameters,
  source_data = source_data
)

self <- model

test_decisions <- numeric(n_replicates)
posterior_means <- numeric(n_replicates)
posterior_medians <- numeric(n_replicates)
credible_intervals <- matrix(numeric(2 * n_replicates), nrow = n_replicates)
prior_proba_no_benefit <- numeric(n_replicates)

posterior_parameters <- NULL

target_data_samples <- target_data$generate(n_replicates)

theta_0 <- case_study_config$theta_0
critical_value <- simulation_config$critical_value
null_space <- case_study_config$null_space
confidence_level <- simulation_config$confidence_level

for (r in seq_along(1:nrow(target_data_samples))) {
  target_data$sample <- target_data_samples[r, ]

  self$inference(target_data = target_data)

  test_decisions[r] <- self$test_decision(critical_value = critical_value, theta_0 = theta_0, null_space = null_space, confidence_level = 0.95)
  posterior_means[r] <- self$post_mean
  posterior_medians[r] <- self$posterior_median()


  credible_intervals[r, ] <- self$credible_interval(level = 0.95)

  if (is.null(posterior_parameters) && !is.null(self$posterior_parameters)) {
    posterior_parameters <- data.frame(self$posterior_parameters)
  } else if (!is.null(self$posterior_parameters)) {
    posterior_parameters <- rbind(posterior_parameters, data.frame(self$posterior_parameters))
  }
}
```

How inference is performed is detailed, for each method, in a separate
vignette.

The null hypothesis is $`H_0: \theta_T \leq \theta_0`$. A decision is
made based on the posterior probability of a positive treatment effect.
The null hypothesis is rejected if :
``` math
 Pr\left(\theta > \theta_0 \mid \mathbf{D}_T, \mathbf{D}_S\right) \geq \phi 
```

Here is the detail of the test_decision function:

``` r

read_function_code(self$test_decision)
```

    ## $ <- function (critical_value, theta_0, null_space, confidence_level) 
    ## {
    ##     if (self$mcmc == TRUE) {
    ##         stopifnot(`Only the 97.5 and 2.5 percentiles are computed, so you can only consider ` = critical_value == 
    ##             (1 + confidence_level)/2)
    ##         percentile_97.5 <- self$credible_interval_97.5
    ##         percentile_2.5 <- self$credible_interval_2.5
    ##         if (null_space == "left") {
    ##             return(percentile_2.5 > theta_0)
    ##         }
    ##         else {
    ##             return(percentile_97.5 < theta_0)
    ##         }
    ##     }
    ##     else {
    ##         if (null_space == "left") {
    ##             return(1 - self$posterior_cdf(theta_0) > critical_value)
    ##         }
    ##         else {
    ##             return(self$posterior_cdf(theta_0) > critical_value)
    ##         }
    ##     }
    ## } self <- function (critical_value, theta_0, null_space, confidence_level) 
    ## {
    ##     if (self$mcmc == TRUE) {
    ##         stopifnot(`Only the 97.5 and 2.5 percentiles are computed, so you can only consider ` = critical_value == 
    ##             (1 + confidence_level)/2)
    ##         percentile_97.5 <- self$credible_interval_97.5
    ##         percentile_2.5 <- self$credible_interval_2.5
    ##         if (null_space == "left") {
    ##             return(percentile_2.5 > theta_0)
    ##         }
    ##         else {
    ##             return(percentile_97.5 < theta_0)
    ##         }
    ##     }
    ##     else {
    ##         if (null_space == "left") {
    ##             return(1 - self$posterior_cdf(theta_0) > critical_value)
    ##         }
    ##         else {
    ##             return(self$posterior_cdf(theta_0) > critical_value)
    ##         }
    ##     }
    ## } test_decision <- function (critical_value, theta_0, null_space, confidence_level) 
    ## {
    ##     if (self$mcmc == TRUE) {
    ##         stopifnot(`Only the 97.5 and 2.5 percentiles are computed, so you can only consider ` = critical_value == 
    ##             (1 + confidence_level)/2)
    ##         percentile_97.5 <- self$credible_interval_97.5
    ##         percentile_2.5 <- self$credible_interval_2.5
    ##         if (null_space == "left") {
    ##             return(percentile_2.5 > theta_0)
    ##         }
    ##         else {
    ##             return(percentile_97.5 < theta_0)
    ##         }
    ##     }
    ##     else {
    ##         if (null_space == "left") {
    ##             return(1 - self$posterior_cdf(theta_0) > critical_value)
    ##         }
    ##         else {
    ##             return(self$posterior_cdf(theta_0) > critical_value)
    ##         }
    ##     }
    ## }

In most cases, we cannot determine the posterior median analytically, in
which case we use the following:

``` r

read_function_code(self$posterior_median)
```

    ## $ <- function (...) 
    ## {
    ##     return(self$post_median)
    ## } self <- function (...) 
    ## {
    ##     return(self$post_median)
    ## } posterior_median <- function (...) 
    ## {
    ##     return(self$post_median)
    ## }

We apply a similar logic for determining the credible interval:

``` r

read_function_code(self$credible_interval)
```

    ## $ <- function (level = 0.95) 
    ## {
    ##     if (level != 0.95) {
    ##         stop("Not implemented for other than 95% CrI")
    ##     }
    ##     return(c(self$posterior_summary["cri95L"], self$posterior_summary["cri95U"]))
    ## } self <- function (level = 0.95) 
    ## {
    ##     if (level != 0.95) {
    ##         stop("Not implemented for other than 95% CrI")
    ##     }
    ##     return(c(self$posterior_summary["cri95L"], self$posterior_summary["cri95U"]))
    ## } credible_interval <- function (level = 0.95) 
    ## {
    ##     if (level != 0.95) {
    ##         stop("Not implemented for other than 95% CrI")
    ##     }
    ##     return(c(self$posterior_summary["cri95L"], self$posterior_summary["cri95U"]))
    ## }

Posterior moments, by contrast, are determined at the inference stage
(which is method-specific).

As explained above, we repeat these computations for each replicate.
This is done through the “simulation_for_given_treatment_effect”
function:

``` r

confidence_level <- 0.95
results <- self$simulation_for_given_treatment_effect(
  target_data,
  n_replicates,
  critical_value,
  theta_0,
  confidence_level = confidence_level,
  null_space = null_space,
  verbose = 0,
  method = method, 
  case_study = case_study,
  n_samples_quantiles_estimation = simulation_config$n_samples_quantiles_estimation
)

knitr::kable(head(data.frame(results), 10))
```

| test_decisions | posterior_means | posterior_medians | credible_intervals.1 | credible_intervals.2 | prior_weight | ess_moments | ess_precisions | ess_elir | fit_success | mcmc_ess | rhat | n_divergences |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|---:|---:|---:|
| 1 | 0.5673998 | 0.5405891 | 0.2965325 | 1.098863 | 0.8462310 | 152.295151 | 110.258937 | 232.2789 | Success | 0 | 0 | 0 |
| 1 | 1.2286195 | 1.2876861 | 0.4462771 | 2.028622 | 0.2178680 | -40.460578 | -27.307658 | 285.9150 | Success | 0 | 0 | 0 |
| 1 | 1.2635530 | 1.3203701 | 0.4690570 | 2.012590 | 0.1796471 | -39.406415 | -29.489784 | 262.7402 | Success | 0 | 0 | 0 |
| 1 | 0.7152660 | 0.6153437 | 0.3462383 | 1.486563 | 0.6738361 | 4.323507 | 13.021071 | 242.5081 | Success | 0 | 0 | 0 |
| 1 | 0.5716207 | 0.5426290 | 0.2978235 | 1.120394 | 0.8412188 | 144.415453 | 103.917785 | 236.4531 | Success | 0 | 0 | 0 |
| 1 | 0.7981703 | 0.6657059 | 0.3665324 | 1.596480 | 0.5788667 | -19.225952 | -2.725697 | 239.4168 | Success | 0 | 0 | 0 |
| 1 | 0.5849379 | 0.5505143 | 0.3056191 | 1.165022 | 0.8273016 | 118.564482 | 84.651242 | 232.5907 | Success | 0 | 0 | 0 |
| 1 | 1.5233720 | 1.5610790 | 0.5526753 | 2.260532 | 0.0717964 | -28.858394 | -32.958789 | 303.5196 | Success | 0 | 0 | 0 |
| 1 | 0.8052472 | 0.6701841 | 0.3674842 | 1.607610 | 0.5715412 | -20.404522 | -3.504868 | 241.2475 | Success | 0 | 0 | 0 |
| 1 | 0.6920255 | 0.6022666 | 0.3385139 | 1.454790 | 0.7014348 | 15.463702 | 20.222337 | 248.4749 | Success | 0 | 0 | 0 |

Now that we have the results of inference and test decisions for each
replicate, we can compute the operating characteristics:

``` r

test_decisions <- results$test_decisions
posterior_means <- results$posterior_means
posterior_medians <- results$posterior_medians
credible_intervals <- results$credible_intervals
posterior_parameters <- results$posterior_parameters

# Determine whether the true value of the target treatment effect lies within the credible interval (to compute the coverage)
target_treatment_effect <- target_data$treatment_effect

estimate_in_CrI <- (
  credible_intervals[, 1] <= target_treatment_effect &
    target_treatment_effect <= credible_intervals[, 2]
)

coverage <- mean(estimate_in_CrI)

conf_int_coverage <- binom.test(sum(estimate_in_CrI), length(estimate_in_CrI), conf.level = confidence_level)$conf.int

errors <- (posterior_means - target_treatment_effect)
squared_errors <- errors ^ 2
mse <- mean(squared_errors)
conf_int_mse <- Hmisc::smean.cl.boot(squared_errors, conf.int = confidence_level)[2:3]

bias <- mean(errors)
conf_int_bias <- Hmisc::smean.cl.boot(errors, conf.int = confidence_level)[2:3]

post_mean <- mean(posterior_means)
conf_int_posterior_mean <- Hmisc::smean.cl.boot(posterior_means, conf.int = confidence_level)[2:3]

post_median <- mean(posterior_medians)
conf_int_posterior_median <- Hmisc::smean.cl.boot(posterior_medians, conf.int = confidence_level)[2:3]

posterior_params <- list()
if (!is.null(posterior_parameters)) {
  for (parameter in colnames(posterior_parameters)) {
    posterior_params[[parameter]] <- mean(posterior_parameters[[parameter]])

    ci <- Hmisc::smean.cl.boot(posterior_parameters[[parameter]], conf.int = confidence_level)
    posterior_params[[paste0("conf_int_lower_", parameter)]] <- ci[2]
    posterior_params[[paste0("conf_int_upper_", parameter)]] <- ci[3]
  }
}

half_widths <- (credible_intervals[, 2] - credible_intervals[, 1]) / 2
precision <- mean(half_widths)
conf_int_precision <-  Hmisc::smean.cl.boot(half_widths, conf.int = confidence_level)[2:3]

credible_interval <- colMeans(credible_intervals)

proba_success <- mean(test_decisions)
conf_int_proba_success <- binom.test(sum(test_decisions), length(test_decisions), conf.level = confidence_level)$conf.int
mcse_proba_success <- sqrt(proba_success * (1 - proba_success) / n_replicates)

results$ess_elir <- na.omit(results$ess_elir)
ess_elir  <- mean(results$ess_elir)
conf_int_ess_elir <- Hmisc::smean.cl.boot(ess_elir, conf.int = confidence_level)[2:3]
```

``` r

sessionInfo()
```

    ## R version 4.2.0 (2022-04-22)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 24.04.5 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so
    ## 
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices datasets  utils     methods   base     
    ## 
    ## other attached packages:
    ## [1] ggplot2_4.0.3 BExTE_0.0.2  
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] matrixStats_1.5.0    fs_2.1.0             assertions_0.3.0    
    ##   [4] progress_1.2.3       doParallel_1.0.17    RColorBrewer_1.1-3  
    ##   [7] rstan_2.32.7         latex2exp_0.9.8      tensorA_0.36.2.1    
    ##  [10] tools_4.2.0          backports_1.5.1      bslib_0.12.0        
    ##  [13] R6_2.6.1             rpart_4.1.16         otel_0.2.0          
    ##  [16] colorspace_2.1-3     Hmisc_5.3-0          nnet_7.3-17         
    ##  [19] withr_3.0.3          prettyunits_1.2.0    tidyselect_1.2.1    
    ##  [22] gridExtra_2.3.1      processx_3.9.0       compiler_4.2.0      
    ##  [25] extrafontdb_1.1      textshaping_1.0.5    cli_3.6.6           
    ##  [28] htmlTable_2.5.0      HDInterval_0.2.4     xml2_1.6.0          
    ##  [31] desc_1.4.3           posterior_1.7.1      sass_0.4.10         
    ##  [34] scales_1.4.0         checkmate_2.3.4      mvtnorm_1.4-2       
    ##  [37] S7_0.2.2             readr_2.2.0          pkgdown_2.2.1       
    ##  [40] QuickJSR_1.11.0      systemfonts_1.3.2    stringr_1.6.0       
    ##  [43] digest_0.6.39        StanHeaders_2.39.1   foreign_0.8-82      
    ##  [46] rmarkdown_2.32       svglite_2.2.2        base64enc_0.1-6     
    ##  [49] pkgconfig_2.0.3      htmltools_0.5.9      extrafont_0.20      
    ##  [52] fastmap_1.2.0        pwr_1.3-0            htmlwidgets_1.6.4   
    ##  [55] rlang_1.3.0          rstudioapi_0.19.0    jquerylib_0.1.4     
    ##  [58] farver_2.1.2         generics_0.1.4       jsonlite_2.0.0      
    ##  [61] dplyr_1.2.1          distributional_0.9.0 inline_0.3.21       
    ##  [64] magrittr_2.0.5       kableExtra_1.4.1     Formula_1.2-6       
    ##  [67] loo_2.10.1.9000      Rcpp_1.1.2           abind_1.4-8         
    ##  [70] ggnewscale_0.5.2     viridis_0.6.5        lifecycle_1.0.5     
    ##  [73] stringi_1.8.9        yaml_2.3.12          pkgbuild_1.4.8      
    ##  [76] grid_4.2.0           parallel_4.2.0       crayon_1.5.3        
    ##  [79] hms_1.1.4            knitr_1.52           ps_1.9.3            
    ##  [82] pillar_1.11.1        codetools_0.2-18     stats4_4.2.0        
    ##  [85] rstantools_2.7.1     glue_1.8.1           evaluate_1.0.5      
    ##  [88] data.table_1.18.6.1  renv_1.0.11          RcppParallel_6.2.1  
    ##  [91] vctrs_0.7.3          tzdb_0.5.0           Rdpack_2.6.6        
    ##  [94] foreach_1.5.2        Rttf2pt1_1.3.14      gtable_0.3.6        
    ##  [97] purrr_1.2.2          tidyr_1.3.2          assertthat_0.2.1    
    ## [100] cachem_1.1.0         xfun_0.60            rbibutils_2.4.1     
    ## [103] tidyverse_2.0.0      roxygen2_8.1.0       ragg_1.5.2          
    ## [106] viridisLite_0.4.3    truncnorm_1.0-9      Bolstad2_1.0-29     
    ## [109] RBesT_1.11-0         tibble_3.3.1         iterators_1.0.14    
    ## [112] cluster_2.1.3        statmod_1.5.2        cmdstanr_0.9.0
