# Default bounds on the calibrated Beta shape parameters

The lower bound keeps the density integrable by quadrature - a shape
much below this puts so much mass in the endpoint singularity that the
Gauss-Jacobi rule needs impractically many nodes - and the upper bound
stops the search running off to a degenerate point mass when one of the
two KL terms can be driven to zero on its own.

## Usage

``` r
NPP_KL_DEFAULT_BOUNDS
```
