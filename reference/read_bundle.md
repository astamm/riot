# Import bundles into R

This is the go-to function to import bundles into R. Based on both VTK
and DIPY, we currently support eight different formats detailed in the
documentation of input argument `file`.

## Usage

``` r
read_bundle(file, reference_file = NULL, bundle_data = list())
```

## Arguments

- file:

  A string specifying the path to the file containing the tractography
  data. Currently supported files are:

  - standard [VTK](https://vtk.org) formats `.vtk` and `.vtp`,

  - [medInria](https://med.inria.fr) `.fds` format,

  - [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html)
    `.tck/.tsf` format,

  - [TrackVis](https://trackvis.org/docs/?subsect=fileformat) `.trk` and
    `.trx` formats,

  - [DIPY](https://docs.dipy.org/1.11.0/) `.dpy` format,

  - `.fib` format.

- reference_file:

  A string specifying the path to a reference image file. This is only
  required when importing `.trx`, `.fib`, or `.dpy` files, as these
  formats do not contain spatial information about the image space. The
  reference image is used to correctly position the bundle in the
  appropriate space. Default is `NULL`.

- bundle_data:

  A named list of bundle-level metadata to store in the `@bundle_data`
  slot of the returned
  [bundle](https://tractoverse.github.io/fiber/reference/bundle.html)
  object (e.g. the affine transform used during tracking, subject
  identifier, or any other scalar/vector annotation). Ignored with a
  warning when the file contains a single streamline (in which case a
  [streamline](https://tractoverse.github.io/fiber/reference/streamline.html)
  is returned). Default is [`list()`](https://rdrr.io/r/base/list.html).

## Value

A [bundle](https://tractoverse.github.io/fiber/reference/bundle.html)
object when the file contains multiple streamlines, or a
[streamline](https://tractoverse.github.io/fiber/reference/streamline.html)
object when it contains exactly one. Each `streamline` is a numeric
matrix with at least three named columns `"X"`, `"Y"`, and `"Z"` (one
row per point along the tract). Additional per-point scalar attributes,
when present in the source file, appear as extra named columns. When a
`bundle` is returned and `bundle_data` is non-empty, its `@bundle_data`
slot is populated with the supplied list.

## See also

[`write_bundle()`](https://tractoverse.github.io/riot/reference/write_bundle.md)
to export bundles from R.

## Examples

``` r
uf_left_vtk <- read_bundle(system.file("extdata", "UF_left.vtk",  package = "riot"))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The bundle stored in /home/runner/work/_temp/Library/riot/extdata/UF_left.vtk has been successfully imported.

# Attach bundle-level metadata
uf_left_vtk2 <- read_bundle(
  system.file("extdata", "UF_left.vtk", package = "riot"),
  bundle_data = list(subject = "sub-01", hemisphere = "left")
)
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The bundle stored in /home/runner/work/_temp/Library/riot/extdata/UF_left.vtk has been successfully imported.
uf_left_vtk2@bundle_data
#> $subject
#> [1] "sub-01"
#> 
#> $hemisphere
#> [1] "left"
#> 
```
