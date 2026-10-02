# Check that the decision threshold matches the credible interval level

Models sampled by MCMC reject the null when the central credible
interval at `confidence_level` excludes it, and stop on any other
threshold. The other models reject it when the posterior probability of
benefit exceeds `critical_value`, and report the interval separately.
The two rules agree only when `critical_value` is
`(1 + confidence_level) / 2`. Any other pair would make some methods
report intervals that contradict their decisions, and would stop the
MCMC methods partway through a run, so it is refused up front.

## Usage

``` r
check_decision_threshold(config, context)
```

## Arguments

- config:

  The simulation configuration.

- context:

  The name of the configuration, used in the error.

## Value

No return value, called for side effects.
