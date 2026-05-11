# Convert a bundle (or streamline) to a flat named list for the C++ writers

Reconstructs the `X`, `Y`, `Z`, `PointId`, `StreamlineId` columns (plus
any extra per-point attribute columns and per-streamline attributes
broadcast to all points) expected by `WriteVTK()`, `WriteVTP()`, and
`WriteFDS()`.

## Usage

``` r
bundle_to_flat_list(x)
```

## Arguments

- x:

  A [bundle](https://astamm.github.io/riot/reference/bundle.md) or
  [streamline](https://astamm.github.io/riot/reference/streamline.md).

## Value

A named list suitable for passing to the C++ writer functions.
