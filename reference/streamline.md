# The streamline S7 class

A streamline represents a single fibre tract. It stores three data
compartments that mirror the conceptual levels found in tractography
file formats:

- `@points` — an \\n \times 3\\ numeric matrix whose columns are named
  `"X"`, `"Y"`, and `"Z"`, holding the ordered 3-D coordinates of the
  \\n\\ points along the tract.

- `@point_data` — a named list of numeric vectors, each of length \\n\\,
  holding per-point scalar attributes (e.g. fractional anisotropy
  sampled at every point).

- `@streamline_data` — a named list of numeric scalars (length-1
  vectors) holding per-streamline attributes (e.g. a tract-level weight
  or mean FA).

## Usage

``` r
streamline(points = NULL, point_data = list(), streamline_data = list())
```

## Arguments

- points:

  A numeric matrix with columns `"X"`, `"Y"`, and `"Z"`.

- point_data:

  A named list of per-point numeric vectors.

- streamline_data:

  A named list of per-streamline numeric scalars.

## Details

Use the
[`new_streamline()`](https://astamm.github.io/riot/reference/new_streamline.md)
constructor to create instances. Slots are accessed with the `@`
operator: `sl@points`, `sl@point_data`, `sl@streamline_data`.
