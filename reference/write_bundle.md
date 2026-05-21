# Export bundles from R

This function exports a bundle stored as a
[bundle](https://tractoverse.github.io/fiber/reference/bundle.html)
object to a file in one of the supported formats. Supported formats
include VTK (`.vtk`), VTP (`.vtp`), FDS (`.fds`), TRK (`.trk`), TCK
(`.tck`), TRX (`.trx`), FIB (`.fib`), and DPY (`.dpy`). For formats that
require a reference image (such as TRX, FIB, and DPY), the user must
provide the path to a reference image file.

## Usage

``` r
write_bundle(x, file, reference_file = NULL)
```

## Arguments

- x:

  A [bundle](https://tractoverse.github.io/fiber/reference/bundle.html)
  object.

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

The input bundle (invisibly) so that the function can be used in pipes.

## Details

Warning: we rely on DIPY to provide support to save bundles in `.trk`,
`.trx`, `.tck`, `.dpy` and `.fib` formats. Among these formats, only
`.trk` and `.trx` formats are able to keep track of additional
attributes assigned to either streamlines or points.

## See also

[`read_bundle()`](https://tractoverse.github.io/riot/reference/read_bundle.md)
to import bundles into R.

## Examples

``` r
uf_left  <- read_bundle(system.file("extdata", "UF_left.vtp",  package = "riot"))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> v The bundle stored in /home/runner/work/_temp/Library/riot/extdata/UF_left.vtp has been successfully imported.
if (FALSE) { # \dontrun{
out <- fs::file_temp(ext = ".vtp")
write_bundle(uf_left, file = out)
} # }
```
