# Gauss quadrature rule for a discrete measure

The `n_nodes`-point Gauss rule of the measure \\\sum_k w_k
\delta\_{x_k}\\: the rule that integrates every polynomial of degree
below `2 * n_nodes` exactly against it. It is built by the Lanczos
process on `diag(nodes)` started from `sqrt(weights)`, which yields the
measure's Jacobi matrix; the eigenvalues of that matrix are the rule's
nodes and the squared first components of its eigenvectors the weights
(Golub and Welsch, 1969). Every Lanczos vector is orthogonalised twice
against all the previous ones, which keeps the recurrence stable where
the plain three-term one loses orthogonality within a few dozen steps.

## Usage

``` r
gauss_rule_for_discrete_measure(nodes, weights, n_nodes)
```

## Arguments

- nodes:

  Atoms of the measure.

- weights:

  Positive masses of the atoms.

- n_nodes:

  Number of nodes wanted. A measure with fewer distinct atoms gets a
  rule with as many nodes as it has atoms, which is then exact.

## Value

A list with the rule's `nodes` and `weights`; the weights sum to
`sum(weights)`.
