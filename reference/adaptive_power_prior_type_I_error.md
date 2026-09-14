# Type I error of the adaptive power prior, computed exactly

The adaptive power prior of Nikolakopoulos et al. (2018) discounts the
source data by a weight that depends on how far the target estimate
falls from the source estimate. For a given calibration parameter the
decision rule is a deterministic function of the target treatment effect
estimate, which under the null is a single normal variate. The type I
error is therefore the normal measure of a union of intervals, and can
be computed exactly rather than estimated by simulation.

The rejection region is found piecewise. Between the two cut-offs the
source data are borrowed in full, the decision statistic is linear in
the estimate, and its boundary is explicit. Outside them the borrowing
weight varies, and clearing its denominator turns the boundary condition
into a degree-six polynomial, so
[`base::polyroot()`](https://rdrr.io/r/base/polyroot.html) locates every
crossing at once.

## Usage

``` r
adaptive_power_prior_type_I_error(
  calibration_parameter,
  source_sample_size_per_arm,
  target_sample_size_per_arm,
  source_treatment_effect_estimate,
  significance_level,
  target_data_sampling_variance,
  source_data_sampling_variance,
  theta_0 = 0
)
```

## Arguments

- calibration_parameter:

  The calibration parameter, written Z_1-c/2 in the manuscript. Must be
  positive.

- source_sample_size_per_arm:

  Sample size per arm in the source study

- target_sample_size_per_arm:

  Sample size per arm in the target study

- source_treatment_effect_estimate:

  Treatment effect estimate in the source study

- significance_level:

  Significance level for hypothesis testing

- target_data_sampling_variance:

  Sampling variance of the target study data

- source_data_sampling_variance:

  Sampling variance of the source study data

- theta_0:

  Value of the treatment effect under the null hypothesis

## Value

The type I error rate, a single number in 0, 1.
