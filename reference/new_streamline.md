# Create a streamline object

A convenience constructor that wraps the
[streamline](https://astamm.github.io/riot/reference/streamline.md) S7
class.

## Usage

``` r
new_streamline(points, point_data = list(), streamline_data = list())
```

## Arguments

- points:

  A numeric matrix with at least three columns named `"X"`, `"Y"`, and
  `"Z"`. Rows correspond to ordered points along the tract.

- point_data:

  A named list of numeric vectors, each of length `nrow(points)`,
  holding per-point scalar attributes. Defaults to an empty list.

- streamline_data:

  A named list of numeric scalars (length-1 vectors) holding
  per-streamline attributes. Defaults to an empty list.

## Value

An object of class `<riot::streamline>`.

## See also

[`new_bundle()`](https://astamm.github.io/riot/reference/new_bundle.md)
