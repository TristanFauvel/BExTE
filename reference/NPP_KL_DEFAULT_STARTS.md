# Default starting values for the KL calibration search

The objective is not convex in the `Beta` shape parameters: the
compatible and the maximum-tolerable-discrepancy terms pull the prior in
opposite directions, and which of them dominates depends on where the
search starts. These five starts bracket the shapes the answer takes in
practice - the uniform prior, a symmetric unimodal one, and the three
corners where one shape is above one and the other below.

## Usage

``` r
NPP_KL_DEFAULT_STARTS
```
