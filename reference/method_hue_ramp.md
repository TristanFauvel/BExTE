# A light-to-dark ramp through a method's hue

A light-to-dark ramp through a method's hue

## Usage

``` r
method_hue_ramp(hue, light_weight = 0.75, dark_weight = 0.45)
```

## Arguments

- hue:

  The method's base colour, which sits at the middle of the ramp.

- light_weight:

  How far towards white the light end sits.

- dark_weight:

  How far towards black the dark end sits.

## Value

A function mapping positions in \\\[0, 1\]\\ to hex colours.
