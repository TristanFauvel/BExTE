# Expectation over a Beta-distributed control rate of a function of the treatment rate

Computes \\E_v\[g(\theta + v)\]\\ for each effect \\\theta\\, where \\v
\sim Beta(a, b)\\ is the control rate and \\g\\ is the treatment arm's
distribution function or density - the distribution function and density
of a difference of independent Beta variables.

The control rate is integrated in rate space by Gauss-Legendre
quadrature over the Beta's effective support, cut where \\\theta + v\\
leaves \\\[0, 1\]\\. There \\g\\ has a corner, or a jump for a density
with a shape parameter of one, and a rule on a piece that straddled it
would converge slowly; on each smooth piece a few dozen nodes reach an
accuracy a midpoint rule in probability space needs hundreds of
thousands of nodes for.

## Usage

``` r
beta_difference_expectation(
  effect,
  shape1,
  shape2,
  treatment_function,
  n_nodes = 32L,
  tail = 1e-15
)
```

## Arguments

- effect:

  Treatment effects at which to evaluate the expectation.

- shape1, shape2:

  Shape parameters of the control rate's Beta.

- treatment_function:

  Function of the treatment rate, vectorised.

- n_nodes:

  Nodes per smooth piece.

- tail:

  Probability left outside the effective support on each side.

## Value

One value per effect.
