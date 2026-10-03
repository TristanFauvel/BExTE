# Column types expected across the simulation results

Maps the column names shared by the scenario, source and results frames
to the type each is expected to hold. Only columns whose type is
load-bearing downstream are listed;
[`check_colnames()`](https://tristanfauvel.github.io/BExTE/reference/check_colnames.md)
ignores columns absent from the spec.

## Usage

``` r
expected_coltypes
```
