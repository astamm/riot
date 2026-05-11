# Create a bundle object

A convenience constructor that wraps the
[bundle](https://astamm.github.io/riot/reference/bundle.md) S7 class.

## Usage

``` r
new_bundle(streamlines, bundle_data = list())
```

## Arguments

- streamlines:

  A list of
  [streamline](https://astamm.github.io/riot/reference/streamline.md)
  objects.

- bundle_data:

  A named list of bundle-level metadata. Defaults to an empty list.

## Value

An object of class `<riot::bundle>`.

## See also

[`new_streamline()`](https://astamm.github.io/riot/reference/new_streamline.md)
