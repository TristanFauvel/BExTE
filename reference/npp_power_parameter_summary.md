# Posterior summaries of the power parameter, per replicate

Once the prior is discretised, the posterior of the power parameter is
the discrete distribution given by the updated mixture weights, so its
mean and standard deviation are weighted sums over the quadrature nodes.

## Usage

``` r
npp_power_parameter_summary(posterior_weights, power_parameter)
```

## Arguments

- posterior_weights:

  `n_replicates x n_nodes` matrix of posterior mixture weights.

- power_parameter:

  Quadrature nodes, one per mixture component.

## Value

A data frame with `power_parameter_mean` and `power_parameter_std`.
