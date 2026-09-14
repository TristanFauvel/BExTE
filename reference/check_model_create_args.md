# Check the arguments a model is created from

`Model$create()` is the single entry point every method class is built
through, and it reads its configuration out of untyped lists. A key that
is absent or of the wrong shape otherwise surfaces as a comparison
against `NULL` further down, so the failure names the branch that
tripped rather than the argument that was wrong.

## Usage

``` r
check_model_create_args(
  case_study_config,
  method,
  method_parameters,
  mcmc_config = NULL
)
```

## Arguments

- case_study_config:

  A list describing the case study.

- method:

  The name of the method being created.

- method_parameters:

  A list of parameters for that method.

- mcmc_config:

  An optional list configuring MCMC.

## Value

No return value, called for side effects.
