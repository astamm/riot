# Convert a flat named list (C++ output) to a streamline or bundle

The input is the named list returned by `ReadVTK()`, `ReadVTP()`, or
`ReadFDS()`, which has at minimum columns `"X"`, `"Y"`, `"Z"`,
`"PointId"`, and `"StreamlineId"`. Each streamline is assembled as a
numeric matrix with columns `"X"`, `"Y"`, `"Z"` plus any extra per-point
attribute columns. `PointId` and `StreamlineId` are dropped — they are
implicit in the row order and list position respectively.

## Usage

``` r
flat_list_to_bundle(lst)
```

## Arguments

- lst:

  A named list with at least the columns `"X"`, `"Y"`, `"Z"`,
  `"PointId"`, and `"StreamlineId"`.

## Value

A
[streamline](https://astamm.github.io/riot/reference/new_streamline.md)
or [bundle](https://astamm.github.io/riot/reference/new_bundle.md).

## Details

Returns a `streamline` when the data contain exactly one streamline,
otherwise a `bundle`.
