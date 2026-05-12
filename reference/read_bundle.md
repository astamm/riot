# Import bundles into R

This is the go-to function to import bundles into R. Based on both VTK
and DIPY, we currently support eight different formats detailed in the
documentation of input argument `file`.

## Usage

``` r
read_bundle(file, reference_file = NULL)
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

## Value

A [bundle](https://astamm.github.io/fiber/reference/new_bundle.html)
object when the file contains multiple streamlines, or a
[streamline](https://astamm.github.io/fiber/reference/new_streamline.html)
object when it contains exactly one. Each `streamline` is a numeric
matrix with at least three named columns `"X"`, `"Y"`, and `"Z"` (one
row per point along the tract). Additional per-point scalar attributes,
when present in the source file, appear as extra named columns.

## See also

[`write_bundle()`](https://astamm.github.io/riot/reference/write_bundle.md)
to export bundles from R.

## Examples

``` r
uf_left_vtk <- read_bundle(system.file("extdata", "UF_left.vtk",  package = "riot"))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The bundle stored in /home/runner/work/_temp/Library/riot/extdata/UF_left.vtk has been successfully imported.
```
