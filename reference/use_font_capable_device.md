# Open a graphics device that can render the plot font

Composing a figure measures text:
[`grid::convertWidth()`](https://rdrr.io/r/grid/grid.convert.html) and
friends do it directly, and
[`ggplot2::ggplotGrob()`](https://ggplot2.tidyverse.org/reference/ggplotGrob.html)
does it again while it assembles the guides. That measurement runs on
whatever graphics device is current. Setting `options(device = )` is not
enough, because it only decides what gets opened when no device is open
at all; a device the caller already had open is used as it is, and a
plain [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device cannot load
the Computer Modern CID font the plot themes ask for. A stray device
left behind by earlier code - another test file, an interactive session,
a previous figure - then breaks a figure that is itself fine.

Opening a cairo device here makes the measurement independent of what
the caller left behind. It is a no-op when cairo is unavailable, or when
the current device is already a cairo one, so nesting these costs
nothing.

## Usage

``` r
use_font_capable_device()
```

## Value

A function that closes the device this opened and makes the caller's
previous device current again. Call it from
[`on.exit()`](https://rdrr.io/r/base/on.exit.html).
