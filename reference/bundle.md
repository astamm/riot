# The bundle S7 class

A `bundle` is an ordered collection of
[streamline](https://astamm.github.io/riot/reference/streamline.md)
objects representing a tractogram or white-matter bundle. It stores two
compartments:

- `@streamlines` — a list of
  [streamline](https://astamm.github.io/riot/reference/streamline.md)
  objects.

- `@bundle_data` — a named list of bundle-level metadata (arbitrary R
  objects, e.g. the affine transform used during tracking).

## Usage

``` r
bundle(streamlines = list(), bundle_data = list())
```

## Arguments

- streamlines:

  A list of
  [streamline](https://astamm.github.io/riot/reference/streamline.md)
  objects.

- bundle_data:

  A named list of bundle-level metadata.

## Details

Use the
[`new_bundle()`](https://astamm.github.io/riot/reference/new_bundle.md)
constructor to create instances.
