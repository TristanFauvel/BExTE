# Implementation of the PDCCPP

## Introduction

The aim of this document is to illustrate the PDCCPP ([Nikolakopoulos et
al (2018)](https://onlinelibrary.wiley.com/doi/10.1111/biom.12835)), the
empirical Bayes power prior (as proposed by [Gravestock et al
(2017)](https://onlinelibrary.wiley.com/doi/10.1002/pst.1814)), and the
p-value based power prior ([Liu et al,
(2018)](https://pubmed.ncbi.nlm.nih.gov/29125220/)).

## Set working directory, import functions

## Load the Belimumab case study configuration

Load the simulation configuration and the Belimumab case study
configuration from YAML files.

``` r

set.seed(42)
config_path <- system.file("conf/simulation_config.yml", package = "BExTE")
simulation_config <- yaml::yaml.load_file(config_path)

config_path <- system.file("conf/case_studies/aprepitant.yml", package = "BExTE")
case_study_config <- yaml::yaml.load_file(config_path)
```

## Create data objects

Create a source_data instance, where information about the source data
is stored

``` r

target_sample_size_per_arm <- as.integer(case_study_config$target$total / 2)
drift <- 0.4

source_data <- ObservedSourceData$new(case_study_config)
print(source_data$to_dict())
```

    ## $source_treatment_effect_estimate
    ## [1] 0.1315456
    ## 
    ## $source_standard_error
    ## [1] 0.04068993
    ## 
    ## $endpoint
    ## [1] "binary"
    ## 
    ## $summary_measure_likelihood
    ## [1] "binomial"
    ## 
    ## $source_sample_size_control
    ## [1] 293
    ## 
    ## $source_sample_size_treatment
    ## [1] 280
    ## 
    ## $equivalent_source_sample_size_per_arm
    ## [1] 286.3525
    ## 
    ## $source_control_rate
    ## [1] 0.5255973
    ## 
    ## $source_treatment_rate
    ## [1] 0.6571429

Set the observed target data (in the paediatrics population)

``` r

summary_measure_likelihood <- case_study_config$summary_measure_likelihood
endpoint <- case_study_config$endpoint
target_data <- ObservedTargetData$new(treatment_effect_estimate = case_study_config$target$treatment_effect, treatment_effect_standard_error = case_study_config$target$standard_error, target_sample_size_per_arm = as.integer(case_study_config$target$total / 2), summary_measure_likelihood = case_study_config$summary_measure_likelihood)
```

## PDCCPP

We note that the PDCCPP method was developed in the Gaussian case only,
assuming that the sampling standard deviation is known and is the same
in the source and target studies. However, in our simulation study, we
do not make this latter assumption. To reuse the code by [Nikolakopoulos
et al (2018)](https://onlinelibrary.wiley.com/doi/10.1111/biom.12835),
what we adapt the sample size per arm in the source study by replacing
it with an “effective sample size per arm at variance $`\sigma_T^2`$,
$`N_0`$: We set: $`N_0 = N_S\frac{\sigma_T^2}{\sigma_S^2}`$ So that
everything is equivalent to the case where the sampling std is
$`\sigma_T`$ in the target study and the source study, but with a sample
size per arm $`N_0`$ in the source study (instead of $`N_S`$)

``` r

method <- "PDCCPP"
method_parameters <- list(
  initial_prior = "noninformative", # This corresponds to the fact that the posterior for the adults data is derived from an uninformative prior (for consistency with other methods). May be removed in future releases.
  empirical_bayes = FALSE, # Corresponds to whether some parameters of the prior are based on observed data.
  desired_tie = 0.065,
  significance_level = 0.05,
  tolerance = 0.0001,
  n_iter = 1e6
)
```

Now, we define the model we want to use for inferring the treatment
effect in the target study.

``` r

env <- "full"
config_dir <- paste0(system.file(paste0("conf/", env), package = "BExTE"), "/")
mcmc_config <- yaml::read_yaml(paste0(config_dir, "/mcmc_config.yml"))

model <- Model$new()

model <- model$create(
  case_study_config = case_study_config,
  method = method,
  method_parameters = method_parameters,
  source_data = source_data,
  mcmc_config = mcmc_config
)
```

### Inference with the PDCCPP

To perform inference, we would simply use:

``` r

# Perform Bayesian inference based on observed target data.
model$inference(target_data = target_data)
```

    ## [1] "Success"

This inference steps set the following attributes which, taken together,
specify the posterior distribution.

``` r

print(model$wpost) # Posterior weight
```

    ## NULL

``` r

print(model$vague_posterior_mean)
```

    ## NULL

``` r

print(model$vague_posterior_variance)
```

    ## NULL

``` r

print(model$info_posterior_mean)
```

    ## NULL

``` r

print(model$info_posterior_variance)
```

    ## NULL

Now, let us see how this is implemented:

``` r

read_function_code(model$inference)
```

    ## $ <- function (target_data) 
    ## {
    ##     self$empirical_bayes_update(target_data)
    ##     return(super$inference(target_data))
    ## } model <- function (target_data) 
    ## {
    ##     self$empirical_bayes_update(target_data)
    ##     return(super$inference(target_data))
    ## } inference <- function (target_data) 
    ## {
    ##     self$empirical_bayes_update(target_data)
    ##     return(super$inference(target_data))
    ## }

The first step in inference is to update the prior based on target_data
if needed, in case where the method uses empirical Bayes. With empirical
Bayes, some parameters of the prior are set based on observed target
data. The second step is to compute the moments of the treatment effect
posterior distribution. Note that we use the same inference function for
all methods/scenarios combinations that do not require MCMC (in which
case we need samples from the posterior and not only the parameters of
the posterior).

In the study protocol, we specified that the variance of the vague
component of the RMP should be such that this prior corresponds to the
information provided by a single subject per arm in the target study.
This is a form of empirical Bayes:

``` r

read_function_code(model$empirical_bayes_update)
```

    ## $ <- function (target_data) 
    ## {
    ##     if (target_data$sample$treatment_effect_standard_error == 
    ##         Inf) {
    ##         stop("The standard error on the treatment effect is Inf")
    ##     }
    ##     self$posterior_parameters$power_parameter <- self$power_parameter_estimation(target_data = target_data)
    ##     self$prior_var <- power_prior_variance(self$prior$source$standard_error, 
    ##         self$posterior_parameters$power_parameter)
    ##     if (is.numeric(self$prior_var) && length(self$prior_var) == 
    ##         0) {
    ##         stop("self$prior_var is numeric(0)")
    ##     }
    ## } model <- function (target_data) 
    ## {
    ##     if (target_data$sample$treatment_effect_standard_error == 
    ##         Inf) {
    ##         stop("The standard error on the treatment effect is Inf")
    ##     }
    ##     self$posterior_parameters$power_parameter <- self$power_parameter_estimation(target_data = target_data)
    ##     self$prior_var <- power_prior_variance(self$prior$source$standard_error, 
    ##         self$posterior_parameters$power_parameter)
    ##     if (is.numeric(self$prior_var) && length(self$prior_var) == 
    ##         0) {
    ##         stop("self$prior_var is numeric(0)")
    ##     }
    ## } empirical_bayes_update <- function (target_data) 
    ## {
    ##     if (target_data$sample$treatment_effect_standard_error == 
    ##         Inf) {
    ##         stop("The standard error on the treatment effect is Inf")
    ##     }
    ##     self$posterior_parameters$power_parameter <- self$power_parameter_estimation(target_data = target_data)
    ##     self$prior_var <- power_prior_variance(self$prior$source$standard_error, 
    ##         self$posterior_parameters$power_parameter)
    ##     if (is.numeric(self$prior_var) && length(self$prior_var) == 
    ##         0) {
    ##         stop("self$prior_var is numeric(0)")
    ##     }
    ## }

The posterior is given by :

``` math
p(\theta_T | \boldsymbol{y}_S, \boldsymbol{y}_T) = \widetilde{w}\mathcal{N}\left(\theta_T \bigg| \frac{\mu_v}{N_T\frac{\sigma^2_v}{\sigma^2_T} + 1} + \frac{\overline{y}_T}{\frac{\sigma^2_T}{N_T\sigma_v^2} + 1}, \left(\sigma_v^{-2} + \frac{N_T}{\sigma^2_T} \right)^{-1}\right) + (1- \widetilde{w})\mathcal{N}\left(\theta_T \bigg| \frac{\overline{y}_S}{N_T\frac{\nu^2_S}{\sigma^2_T} + 1} + \frac{\overline{y}_T}{\frac{\sigma^2_T}{N_T\nu_S^2} + 1}, \left(\nu_S^{-2} + \frac{N_T}{\sigma^2_T} \right)^{-1}\right),
```

where $`\mathcal{N}(\theta_T | \mu, \sigma^2)`$ denotes the probability
density function of a normal distribution with mean $`\mu`$ and variance
$`\sigma^2`$, evaluated at $`\theta_T`$.

The code to compute the posterior moments is the following :

``` r

read_function_code(model$posterior_moments)
```

    ## $ <- function (target_data) 
    ## {
    ##     self$post_mean <- self$posterior_mean(target_data)
    ##     self$post_var <- self$posterior_variance(target_data)
    ## } model <- function (target_data) 
    ## {
    ##     self$post_mean <- self$posterior_mean(target_data)
    ##     self$post_var <- self$posterior_variance(target_data)
    ## } posterior_moments <- function (target_data) 
    ## {
    ##     self$post_mean <- self$posterior_mean(target_data)
    ##     self$post_var <- self$posterior_variance(target_data)
    ## }

With :

``` r

read_function_code(model$posterior_mean)
```

    ## $ <- function (target_data) 
    ## {
    ##     post_mean <- (self$prior_mean/(self$prior_var/target_data$sample$treatment_effect_standard_error^2 + 
    ##         1)) + (target_data$sample$treatment_effect_estimate/(1 + 
    ##         target_data$sample$treatment_effect_standard_error^2/self$prior_var))
    ##     assertions::assert_number(post_mean)
    ##     return(post_mean)
    ## } model <- function (target_data) 
    ## {
    ##     post_mean <- (self$prior_mean/(self$prior_var/target_data$sample$treatment_effect_standard_error^2 + 
    ##         1)) + (target_data$sample$treatment_effect_estimate/(1 + 
    ##         target_data$sample$treatment_effect_standard_error^2/self$prior_var))
    ##     assertions::assert_number(post_mean)
    ##     return(post_mean)
    ## } posterior_mean <- function (target_data) 
    ## {
    ##     post_mean <- (self$prior_mean/(self$prior_var/target_data$sample$treatment_effect_standard_error^2 + 
    ##         1)) + (target_data$sample$treatment_effect_estimate/(1 + 
    ##         target_data$sample$treatment_effect_standard_error^2/self$prior_var))
    ##     assertions::assert_number(post_mean)
    ##     return(post_mean)
    ## }

and :

``` r

read_function_code(model$posterior_variance)
```

    ## $ <- function (target_data) 
    ## {
    ##     return(1/(1/self$prior_var + 1/target_data$sample$treatment_effect_standard_error^2))
    ## } model <- function (target_data) 
    ## {
    ##     return(1/(1/self$prior_var + 1/target_data$sample$treatment_effect_standard_error^2))
    ## } posterior_variance <- function (target_data) 
    ## {
    ##     return(1/(1/self$prior_var + 1/target_data$sample$treatment_effect_standard_error^2))
    ## }

The variance of a mixture of two distributions is given by :

``` r

read_function_code(model$mixture_variance)
```

    ## $ <- NULL model <- NULL mixture_variance <- NULL

A crucial aspect of this inference step is the computation of the
posterior mixture weights:

The posterior weight of the vague component $`\widetilde{w}`$ is given
by:

``` math
    \tilde{w} = \frac{wC_v}{wC_v + (1-w)C_S}
```
Where $`C_v`$ and $`C_S`$ are proportional to the marginal likelihood
(or prior predictive probability) of the aggregate data for each
Gaussian component:
``` math
C_v =  \frac{1}{\sqrt{\sigma_v^2 + \sigma^2_T/N_T}}\exp\left(-\frac{1}{2}\frac{(\overline{y}_T - \mu_v)^2}{\sqrt{\sigma_v^2 + \sigma^2_T/N_T}}\right)
```
and :
``` math
C_S =  \frac{1}{\sqrt{\nu_S^2 + \sigma^2_T/N_T}}\exp\left(-\frac{1}{2}\frac{(\overline{y}_T - \overline{y}_S)^2}{\sqrt{\nu_S^2 + \sigma^2_T/N_T}}\right)
```

``` r

read_function_code(model$posterior_pdf)
```

    ## $ <- function (target_treatment_effect) 
    ## {
    ##     dnorm(target_treatment_effect, mean = self$post_mean, sd = sqrt(self$post_var))
    ## } model <- function (target_treatment_effect) 
    ## {
    ##     dnorm(target_treatment_effect, mean = self$post_mean, sd = sqrt(self$post_var))
    ## } posterior_pdf <- function (target_treatment_effect) 
    ## {
    ##     dnorm(target_treatment_effect, mean = self$post_mean, sd = sqrt(self$post_var))
    ## }

``` r

read_function_code(model$posterior_cdf)
```

    ## $ <- function (target_treatment_effect) 
    ## {
    ##     pnorm(target_treatment_effect, mean = self$post_mean, sd = sqrt(self$post_var))
    ## } model <- function (target_treatment_effect) 
    ## {
    ##     pnorm(target_treatment_effect, mean = self$post_mean, sd = sqrt(self$post_var))
    ## } posterior_cdf <- function (target_treatment_effect) 
    ## {
    ##     pnorm(target_treatment_effect, mean = self$post_mean, sd = sqrt(self$post_var))
    ## }

Let us plot the posterior pdf :

``` r

library(ggplot2)
x_values <- seq(-0.5, 2, by = 0.01) # Range of values for x

prior_pdf <- model$prior_pdf(x_values)
posterior_pdf <- model$posterior_pdf(x_values)

df <- data.frame(x = x_values, prior_pdf = prior_pdf, posterior_pdf = posterior_pdf)

# Use ggplot2 to plot both PDFs on the same plot
ggplot2::ggplot(df, ggplot2::aes(x = x)) +
  geom_line(ggplot2::aes(y = prior_pdf), color = "blue", size = 1) +
  geom_line(ggplot2::aes(y = posterior_pdf), color = "red", size = 1) +
  ggplot2::labs(
    title = "Prior and posterior distribution of the treatment effect",
    x = "Value",
    y = "Density",
    labels = c("Prior pdf", "Posterior pdf")
  ) +
  theme_minimal() +
  scale_color_manual(values = c("blue", "red")) +
  guides(color = guide_legend(title = NULL)) +
  scale_fill_manual(
    name = "PDF of the robust mixture of Gaussians",
    labels = c("Prior pdf", "Posterior pdf"),
    values = c("blue", "red")
  )
```

![](PDCCPP_files/figure-html/unnamed-chunk-15-1.png)

Being able to sample from the posterior is crucial for estimating
quantiles, we use the following:.

``` r

read_function_code(model$sample_posterior)
```

    ## $ <- function (n_samples) 
    ## {
    ##     rnorm(n_samples, mean = self$post_mean, sd = sqrt(self$post_var))
    ## } model <- function (n_samples) 
    ## {
    ##     rnorm(n_samples, mean = self$post_mean, sd = sqrt(self$post_var))
    ## } sample_posterior <- function (n_samples) 
    ## {
    ##     rnorm(n_samples, mean = self$post_mean, sd = sqrt(self$post_var))
    ## }

Illustration of this sampling approach:

``` r

samples <- model$sample_posterior(10000)
hist(samples, breaks = 60, col = "skyblue", main = "Samples from the posterior distribution of the treatment effect", xlab = "Treatment effect", ylab = "Number of samples")
```

![](PDCCPP_files/figure-html/unnamed-chunk-17-1.png)
