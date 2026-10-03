# Select the smallest acceptable weak-component weight

Implements the Egidi, Pauli and Torelli selection rule \$\$\hat\psi =
\inf\\\psi \in \[0, 1\] : P\_\psi(t\_{obs}) \ge \alpha\_{PC}\\,\$\$
separately for every replicate and using only the observed target
statistic.

## Usage

``` r
egidi_select_weak_weight(
  t_obs,
  s_target,
  mu_p,
  tau_p,
  mu_q,
  tau_q,
  alpha_pc = 0.05,
  weight_grid_step = 0.001,
  weight_scan_step = 0.02,
  weight_tolerance = 1e-12
)
```

## Arguments

- t_obs:

  Observed target treatment effect estimate, one per replicate.

- s_target:

  Target standard error, one per replicate.

- mu_p, tau_p:

  Informative component prior mean and standard deviation.

- mu_q, tau_q:

  Weak component prior mean and standard deviation.

- alpha_pc:

  Conflict threshold, 0.05 in the primary analysis.

- weight_grid_step:

  Resolution of the weight scan.

- weight_scan_step:

  Resolution of the coarse stage of the scan.

- weight_tolerance:

  Width of the weight bracket at which the crossing is considered found.

## Value

A data frame with one row per replicate and the columns `psi_weak`,
`pvalue_informative`, `pvalue_weak`, `pvalue_selected`,
`initial_conflict` and `conflict_unresolved`.

## Details

Both ends of the interval are exact and are tried first, which decides
most replicates without any search. \\P_0\\ is the conflict p-value
under the informative component alone: when it already reaches the
threshold there is no conflict to resolve and the selected weight is
zero. \\P_1\\ is the conflict p-value under the weak component alone:
when even that falls short, no weight removes the conflict, and the rule
returns one while flagging the conflict as unresolved rather than
treating it as resolved.

With common centres the mixture predictive is symmetric, \\P\_\psi\\ is
exactly \\(1 - \psi)P_p + \psi P_q\\, and the crossing is solved in
closed form. Otherwise the weight is found by scanning upwards for the
first crossing and refining it, since monotonicity in \\\psi\\ is not
guaranteed.

The scan is run in two stages, a coarse one to locate the crossing and a
fine one at `weight_grid_step` inside it, and the crossing is then
refined by
[`vectorised_bracketed_root()`](https://tristanfauvel.github.io/BExTE/reference/vectorised_bracketed_root.md).
The two-stage scan agrees with a single scan at `weight_grid_step`
unless a crossing both starts and ends inside one coarse step;
`weight_scan_step = weight_grid_step` disables the coarse stage.
