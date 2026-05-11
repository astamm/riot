# Convert a flat named list (C++ output) to a streamline or bundle

The input is the named list returned by `ReadVTK()`, `ReadVTP()`, or
`ReadFDS()`, which has at minimum columns `"X"`, `"Y"`, `"Z"`,
`"PointId"`, and `"StreamlineId"`. Columns named in `streamline_cols`
are treated as per-streamline attributes: one value is stored per
streamline (taken from the first occurrence in each group rather than
broadcast). All remaining extra columns are treated as per-point
attributes.

## Usage

``` r
flat_list_to_bundle(lst, streamline_cols = character(0L))
```

## Arguments

- lst:

  A named list with at least the columns `"X"`, `"Y"`, `"Z"`,
  `"PointId"`, and `"StreamlineId"`.

- streamline_cols:

  Character vector of column names to store as per-streamline data.
  Defaults to `character(0)`.

## Value

A [streamline](https://astamm.github.io/riot/reference/streamline.md) or
[bundle](https://astamm.github.io/riot/reference/bundle.md).

## Details

Returns a `streamline` when the data contain exactly one streamline,
otherwise a `bundle`.
