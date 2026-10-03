# Find Calibration Parameter

This function finds the calibration parameter for type I error control
in empirical Bayes power prior methods. It is based on the code in
Nikolakopoulos et al, 2018, "Dynamic borrowing through adaptive power
priors that control type I error". We just renamed the variables to be
more explicit. The function finds the calibration parameter by the same
bisection search as the original, but evaluates the type I error at each
step exactly rather than by simulation. The result is deterministic.

## Usage

``` r
findCalibrationParameter(
  n_iter = 1e+06,
  source_sample_size_per_arm,
  target_sample_size_per_arm,
  source_treatment_effect_estimate,
  desired_tie = 0.065,
  significance_level = 0.05,
  target_data_sampling_variance,
  source_data_sampling_variance,
  tolerance = 1e-04,
  theta_0 = 0
)
```

## Arguments

- n_iter:

  Formerly the number of simulated target estimates used to estimate the
  type I error. The type I error is now integrated exactly by
  [`adaptive_power_prior_type_I_error()`](https://tristanfauvel.github.io/BExTE/reference/adaptive_power_prior_type_I_error.md),
  so this argument is ignored. It is retained because existing method
  configurations still supply it.

- source_sample_size_per_arm:

  Sample size per arm in the source study

- target_sample_size_per_arm:

  Sample size per arm in the target study

- source_treatment_effect_estimate:

  Treatment effect estimate in the source study

- desired_tie:

  Desired type I error rate

- significance_level:

  Significance level for hypothesis testing

- target_data_sampling_variance:

  Sampling variance of the target study data

- source_data_sampling_variance:

  Sampling variance of the source study data

- tolerance:

  Tolerance for convergence of the estimation

- theta_0:

  True mean for type I error computation

## Value

A matrix containing the calibration parameter and other related values
