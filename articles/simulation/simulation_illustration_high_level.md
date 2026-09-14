# Simulation study logic - high level

## Introduction

The aim of this document is to illustrate how to run the simulation
study for user-defined configurations. It explains how to define a
specific scenario (source and target study characterstics), instantiate
a Bayesian model for partial extrapolation, define the configuration to
evaluate the frequentist OCs of this model.

The simulation study pipeline is designed in such a way that the
complexity behind model creation and data generation is abstracted away,
so that it is very easy for a new user to evaluate a specific method in
arbitrary scenarios. This “high-level” description of the simulation
study implementation is accompanied with a corresponding “low-level”
description in another vignette, which describes in more details the
components used at each step.

Source other scripts

``` r

env <- "full"
config_dir <- paste0(system.file(paste0("conf/", env), package = "BExTE"), "/")
scenarios_config <- yaml::read_yaml(paste0(config_dir, "scenarios_config.yml"))
```

## Load the case study configuration

Load the simulation configuration and the Belimumab case study
configuration from YAML files.

``` r

set.seed(42)
config_path <- system.file("conf/simulation_config.yml", package = "BExTE")
simulation_config <- yaml::yaml.load_file(config_path)

case_study <- "botox"
config_path <- system.file("conf/case_studies/botox.yml", package = "BExTE")
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

Create a source_data instance, where information about the source data
is stored. We can also specify the denominator in the source treatment
effect summary measure (optional), in the in case we want to modify it.

``` r

source_denominator <- case_study_config$source$responses$control / case_study_config$source$total
source_data <- SourceData$new(case_study_config, source_denominator)
print(source_data$to_dict())
```

    ## $source_treatment_effect_estimate
    ## [1] 0.2
    ## 
    ## $source_standard_error
    ## [1] 0.1
    ## 
    ## $endpoint
    ## [1] "continuous"
    ## 
    ## $summary_measure_likelihood
    ## [1] "normal"
    ## 
    ## $source_sample_size_control
    ## [1] 235
    ## 
    ## $source_sample_size_treatment
    ## [1] 233
    ## 
    ## $equivalent_source_sample_size_per_arm
    ## [1] 233.9957
    ## 
    ## $source_control_rate
    ## [1] NA
    ## 
    ## $source_treatment_rate
    ## [1] NA

Alternatively, if we want to use the control rate from the source study
data:

``` r

source_data <- SourceData$new(case_study_config)
print(source_data$to_dict())
```

    ## $source_treatment_effect_estimate
    ## [1] 0.2
    ## 
    ## $source_standard_error
    ## [1] 0.1
    ## 
    ## $endpoint
    ## [1] "continuous"
    ## 
    ## $summary_measure_likelihood
    ## [1] "normal"
    ## 
    ## $source_sample_size_control
    ## [1] 235
    ## 
    ## $source_sample_size_treatment
    ## [1] 233
    ## 
    ## $equivalent_source_sample_size_per_arm
    ## [1] 233.9957
    ## 
    ## $source_control_rate
    ## [1] NA
    ## 
    ## $source_treatment_rate
    ## [1] NA

Create an instance of the BinaryTargetData class, which will allow us to
sample target study data. Note that this target_data depends on the
specific parameters chosen for the scenario (in particular, the drift
and target sample size).

``` r

summary_measure_likelihood <- case_study_config$summary_measure_likelihood
endpoint <- case_study_config$endpoint
target_data <- TargetDataFactory$new()
target_data <- target_data$create(
  source_data = source_data, case_study_config = case_study_config,
  target_sample_size_per_arm = target_sample_size_per_arm, treatment_drift = drift, summary_measure_likelihood = source_data$summary_measure_likelihood, target_to_source_std_ratio = 1
)
```

Here, we use a factory method design pattern. The target_data object is
of the BinaryTargetData class, which inherits from the TargetData class.

``` r

print(target_data$to_dict())
```

    ## $summary_measure_likelihood
    ## [1] "normal"
    ## 
    ## $target_sample_size_per_arm
    ## [1] 91
    ## 
    ## $target_treatment_effect
    ## [1] 0.6
    ## 
    ## $target_standard_deviation
    ## [1] 1.529692
    ## 
    ## $target_control_rate
    ## [1] NA
    ## 
    ## $target_treatment_rate
    ## [1] NA

Now, we define the model we want to use for inferring the treatment
effect in the target study. Again, the model class definition relies on
the factory method design patter, which is very convenient in this
situation, as you can use the same function with different arguments to
instantiate any model:

``` r

model <- Model$new()

model <- model$create(
  case_study_config = case_study_config,
  method = method,
  method_parameters = method_parameters,
  source_data = source_data
)
```

Why does the model depend on the source data? Because the model depends
on the type of endpoint and summary measure, which are stored within the
source_data object.

## Launching the simulation

We first explicitly retrieve parameters that are important for computing
the OCs (the boundary of the null space and the critical value for the
Bayesian decision criterion), as well as the number of replicates for
the simulation study (which will be 10000)

``` r

theta_0 <- case_study_config$theta_0
critical_value <- simulation_config$critical_value
n_replicates <- scenarios_config$n_replicates
```

And now, it is finally time to compute the frequentist OCs of this model
in this scenario:

``` r

sim_outputs <- model$estimate_frequentist_operating_characteristics(
  theta_0 = theta_0,
  target_data = target_data,
  n_replicates = n_replicates,
  critical_value = critical_value,
  confidence_level = 0.95,
  null_space = case_study_config$null_space,
  verbose = 0,
  n_samples_quantiles_estimation = simulation_config$n_samples_quantiles_estimation,
  method = method,
  case_study = case_study
)

format_simulation_output_table(sim_outputs)
```

    ##               Metric    Value               95% CI
    ##  Success Probability  0.99540 [ 0.99387,  0.99663]
    ##             Coverage  0.83830 [ 0.83094,  0.84547]
    ##                  MSE  0.04734 [ 0.04649,  0.04819]
    ##                 Bias -0.10636 [-0.11008, -0.10264]
    ##       Posterior Mean  0.49364 [ 0.48992,  0.49736]
    ##     Posterior Median  0.48248 [ 0.47850,  0.48646]
    ##            Precision  0.32018 [ 0.31904,  0.32132]
    ##    Credible Interval       NA [ 0.20253,  0.84289]
    ##           ESS Moment  5.97814 [ 4.95184,  7.00443]
    ##        ESS Precision  6.63423 [ 5.73947,  7.52898]
    ##             ESS ELIR 87.52925 [87.26959, 87.78891]

At this point, the pipeline includes some logic to store the results as
a row in a results table. Once we have looped over all scenarios and
methods, the results table is then used to make figures
