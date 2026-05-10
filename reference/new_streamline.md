# Create a streamline object

A `streamline` is a numeric matrix whose rows are ordered 3-D points
along a single fibre tract. The first three columns must be named `"X"`,
`"Y"`, and `"Z"`. Any additional columns carry per-point scalar or
vector attributes.

## Usage

``` r
new_streamline(mat)
```

## Arguments

- mat:

  A numeric matrix with at least three columns named `"X"`, `"Y"`, and
  `"Z"`.

## Value

An object of class `streamline`.
