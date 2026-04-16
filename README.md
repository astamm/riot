
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riot <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/astamm/riot/workflows/R-CMD-check/badge.svg)](https://github.com/astamm/riot/actions)
[![test-coverage](https://github.com/astamm/riot/workflows/test-coverage/badge.svg)](https://github.com/astamm/riot/actions)
[![Codecov test
coverage](https://codecov.io/gh/astamm/riot/branch/master/graph/badge.svg)](https://app.codecov.io/gh/astamm/riot?branch=master)
[![pkgdown](https://github.com/astamm/riot/workflows/pkgdown/badge.svg)](https://github.com/astamm/riot/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/riot)](https://CRAN.R-project.org/package=riot)
[![R-CMD-check](https://github.com/astamm/riot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/astamm/riot/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/astamm/riot/graph/badge.svg)](https://app.codecov.io/gh/astamm/riot)
<!-- badges: end -->

## Overview

The [**riot**](https://astamm.github.io/riot/) (R Input/Output for
Tractography) package provides an R interface for importing and
exporting tractography data to and from `R`. Currently supported
importing formats are:

- native [VTK](https://vtk.org) `.vtk` and `.vtp` files;
- [medInria](https://med.inria.fr) `.fds` files;
- [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html)
  `.tck/.tsf` files; and,
- [TrackVis](https://trackvis.org/docs/?subsect=fileformat) `.trk`
  files.

The package reads tractography data into a
[tibble](https://tibble.tidyverse.org) in which each row is a point
characterized by at least the following five variables:

- `X`, `Y`, `Z`: 3D coordinates of the current point;
- `PointId`: Identification number of the current point among all points
  of the streamline it belongs to;
- `StreamlineId`: Identification number of the streamline which the
  current point belongs to.

The points might also have attributes or a color assigned to them, in
which case, additional variables will be properly created to import them
as well. The user can perform statistical analysis on the point cloud
and store any new variable that (s)he would deem to be useful as
additional column of the [tibble](https://tibble.tidyverse.org). The
package also allows to write back the
[tibble](https://tibble.tidyverse.org), including all newly created
attributes, into the following exporting formats:

- native [VTK](https://vtk.org) `.vtk` and `.vtp` files; or,
- [medInria](https://med.inria.fr) `.fds` files.

## Installation

You can install the released version of
[**riot**](https://astamm.github.io/riot/) from
[CRAN](https://cran.r-project.org) with:

``` r
install.packages("riot")
```

Alternatively you can install the development version of
[**riot**](https://astamm.github.io/riot/) from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("astamm/riot")
```

## Example

``` r
library(riot)
```

### Native [VTK](https://vtk.org) `.vtk` and `.vtp` files

``` r
uf_left_vtk <- read_tractogram(system.file(
  "extdata",
  "UF_left.vtk",
  package = "riot"
))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The tractogram stored in '/private/var/folders/f3/ycwwj6td205fvwjmcfj53w5r0000gn/T/RtmpVW9OFz/temp_libpath10047b5015c5/riot/extdata/UF_left.vtk' has been successfully imported.
uf_left_vtk
#> ℹ Tractogram with 2042 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 9, 15, 18, 18.9505386875612, 23, and 33.
#> cli-27115-8
```

``` r
uf_left_vtp <- read_tractogram(system.file(
  "extdata",
  "UF_left.vtp",
  package = "riot"
))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The tractogram stored in '/private/var/folders/f3/ycwwj6td205fvwjmcfj53w5r0000gn/T/RtmpVW9OFz/temp_libpath10047b5015c5/riot/extdata/UF_left.vtp' has been successfully imported.
uf_left_vtp
#> ℹ Tractogram with 2042 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 9, 15, 18, 18.9505386875612, 23, and 33.
#> cli-27115-14
```

### [medInria](https://med.inria.fr) `.fds` files

``` r
uf_left_fds <- read_tractogram(system.file(
  "extdata",
  "UF_left.fds",
  package = "riot"
))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The tractogram stored in '/private/var/folders/f3/ycwwj6td205fvwjmcfj53w5r0000gn/T/RtmpVW9OFz/temp_libpath10047b5015c5/riot/extdata/UF_left.fds' has been successfully imported.
uf_left_fds
#> ℹ Tractogram with 2042 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 9, 15, 18, 18.9505386875612, 23, and 33.
#> cli-27115-20
```

### [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html) `.tck/.tsf` files

``` r
af_left_tck <- read_tractogram(system.file(
  "extdata",
  "AF_left.tck",
  package = "riot"
))
#> ✔ The tractogram stored in '/private/var/folders/f3/ycwwj6td205fvwjmcfj53w5r0000gn/T/RtmpVW9OFz/temp_libpath10047b5015c5/riot/extdata/AF_left.tck' has been successfully imported.
af_left_tck
#> ℹ Tractogram with 5000 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 8, 23, 28, 28.0602, 33, and 54.
#> cli-27115-26
```

### [TrackVis](https://trackvis.org/docs/?subsect=fileformat) `.trk` files

``` r
cc_mid_trk <- read_tractogram(system.file(
  "extdata",
  "CCMid.trk",
  package = "riot"
))
#> ✔ The tractogram stored in '/private/var/folders/f3/ycwwj6td205fvwjmcfj53w5r0000gn/T/RtmpVW9OFz/temp_libpath10047b5015c5/riot/extdata/CCMid.trk' has been successfully imported.
cc_mid_trk
#> ℹ Tractogram with 525 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 29, 189, 224, 214.619047619048, 243, and 270.
#> cli-27115-32
```

## Dependencies

### VTK

Since version 1.2.0, **riot** no longer bundles VTK source files.
Instead it links against an **externally installed**
[VTK](https://vtk.org/) (\>= 9.1.0). VTK must be present on the host
before installing the package. Both shared and static VTK builds are
supported; static builds on macOS and Linux must have been compiled with
`-fPIC`.

At install time, `configure` (Unix-like) / `configure.win` (Windows)
search for VTK in the following order:

1.  `VTK_DIR` environment variable (highest priority).
2.  [Homebrew](https://brew.sh) — macOS only (`brew install vtk`).
3.  `pkg-config` — macOS and Linux.
4.  Well-known system prefix paths (`/usr`, `/usr/local`) — Linux.
5.  Rtools42+ pacman package for the active MSYS2 environment
    (e.g. `mingw-w64-ucrt-x86_64-vtk` for UCRT64) — Windows.

### TinyXML-2

**riot** bundles [TinyXML-2](https://github.com/leethomason/tinyxml2).
`tinyxml2.cpp` has been modified to avoid the use of `stdout` and
`printf` as per *Writing R Extensions* manual recommendations because
`R` has its own input/output mechanism for writing to the console.

## Acknowledgements

The authors would like to thank Tim Schäfer, the author of the
[**freesurferformats**](https://CRAN.R-project.org/package=freesurferformats)
package, for his helpful code to read
[MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html)
and [TrackVis](https://trackvis.org/docs/?subsect=fileformat)
tractography file formats.
