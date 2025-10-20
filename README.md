
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
- [TrackVis](http://trackvis.org/docs/?subsect=fileformat) `.trk` files.

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
#> ✔ The tractogram stored in '/private/var/folders/3j/k56349vx2x9_f27779mgy8zm0000gn/T/RtmpWDrUDz/temp_libpath81137943942/riot/extdata/UF_left.vtk' has been successfully imported.
uf_left_vtk
#> ℹ Tractogram with 2042 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 9, 15, 18, 18.9505386875612, 23, and 33.
#> cli-33595-8
```

``` r
uf_left_vtp <- read_tractogram(system.file(
  "extdata",
  "UF_left.vtp",
  package = "riot"
))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✔ The tractogram stored in '/private/var/folders/3j/k56349vx2x9_f27779mgy8zm0000gn/T/RtmpWDrUDz/temp_libpath81137943942/riot/extdata/UF_left.vtp' has been successfully imported.
uf_left_vtp
#> ℹ Tractogram with 2042 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 9, 15, 18, 18.9505386875612, 23, and 33.
#> cli-33595-14
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
#> ✔ The tractogram stored in '/private/var/folders/3j/k56349vx2x9_f27779mgy8zm0000gn/T/RtmpWDrUDz/temp_libpath81137943942/riot/extdata/UF_left.fds' has been successfully imported.
uf_left_fds
#> ℹ Tractogram with 2042 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 9, 15, 18, 18.9505386875612, 23, and 33.
#> cli-33595-20
```

### [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html) `.tck/.tsf` files

``` r
af_left_tck <- read_tractogram(system.file(
  "extdata",
  "AF_left.tck",
  package = "riot"
))
#> ✔ The tractogram stored in '/private/var/folders/3j/k56349vx2x9_f27779mgy8zm0000gn/T/RtmpWDrUDz/temp_libpath81137943942/riot/extdata/AF_left.tck' has been successfully imported.
af_left_tck
#> ℹ Tractogram with 5000 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 8, 23, 28, 28.0602, 33, and 54.
#> cli-33595-26
```

### [TrackVis](http://trackvis.org/docs/?subsect=fileformat) `.trk` files

``` r
cc_mid_trk <- read_tractogram(system.file(
  "extdata",
  "CCMid.trk",
  package = "riot"
))
#> ✔ The tractogram stored in '/private/var/folders/3j/k56349vx2x9_f27779mgy8zm0000gn/T/RtmpWDrUDz/temp_libpath81137943942/riot/extdata/CCMid.trk' has been successfully imported.
cc_mid_trk
#> ℹ Tractogram with 525 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 29, 189, 224, 214.619047619048, 243, and 270.
#> cli-33595-32
```

## Dependencies

The [**riot**](https://astamm.github.io/riot/) package has two
dependencies: [VTK](https://vtk.org/) and
[TinyXML-2](https://github.com/leethomason/tinyxml2). They both have
been slightly altered with respect to the original softwares for
compliance with [CRAN](https://cran.r-project.org) policy. Specifically:

- `vtk/include/utf8.h` header file has been modified to ensure LF line
  endings;
- some source files of the `CommonDataModel` and `vtkzlib` modules have
  been modified to avoid compilation warnings arising when using LLVM or
  Apple clang or GNU gcc compilers;
- `tinyxml2.cpp` has been modified to avoid the use of `stdout` and
  `printf` as per *Writing R Extensions* manual recommendations because
  `R` has its own input/output mechanism for writing to the console.

Moreover, **riot** now ships a shrunk version of VTK source files to
avoid unsuccessful downloads from VTK website.

## Acknowledgements

The authors would like to thank Tim Schäfer, the author of the
[**freesurferformats**](https://CRAN.R-project.org/package=freesurferformats)
package, for his helpful code to read
[MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html)
and [TrackVis](http://trackvis.org/docs/?subsect=fileformat)
tractography file formats.
