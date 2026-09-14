# The paper figure and table manifest

Every figure and generated table in the paper, in publication order,
each paired with the generator call that produces it. Table ids are
prefixed `TS` so they never collide with a figure of the same number -
figure S8 and table S8 are different objects, and only the figure is in
scope.

## Usage

``` r
paper_manifest()
```

## Value

A list of manifest entries.
