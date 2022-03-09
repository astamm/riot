
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riot

<!-- badges: start -->

[![R-CMD-check](https://github.com/astamm/riot/workflows/R-CMD-check/badge.svg)](https://github.com/astamm/riot/actions)
[![test-coverage](https://github.com/astamm/riot/workflows/test-coverage/badge.svg)](https://github.com/astamm/riot/actions)
[![Codecov test
coverage](https://codecov.io/gh/astamm/riot/branch/master/graph/badge.svg)](https://app.codecov.io/gh/astamm/riot?branch=master)
[![pkgdown](https://github.com/astamm/riot/workflows/pkgdown/badge.svg)](https://github.com/astamm/riot/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/riot)](https://CRAN.R-project.org/package=riot)
<!-- badges: end -->

The goal of `riot` is to provide readers and writers from and to
standard file formats (`.vtk`, `.vtp` and `.fds`) that store diffusion
MRI tractography data.

## Installation

You can install the development version of
[`riot`](https://astamm.github.io/riot/) from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("astamm/riot")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(riot)
uf_left  <- read_fascicles(system.file("extdata", "UF_left.vtp",  package = "riot"))
#> Number of data points: 38697
#> Number of streamlines: 2042
#> ✓ The fascicles stored in '/Users/stamm-a/Library/R/x86_64/4.1/library/riot/extdata/UF_left.vtp' have been successfully imported.
uf_left
#> # A tibble: 38,697 × 5
#>        X     Y      Z PointId StreamlineId
#>    <dbl> <dbl>  <dbl>   <dbl>        <dbl>
#>  1  13.7 -41.8 -13.1        1            1
#>  2  13.0 -40.4 -13.9        2            1
#>  3  13.9 -37.5 -13.8        3            1
#>  4  14.3 -34.7 -12.8        4            1
#>  5  15.2 -32.7 -11.8        5            1
#>  6  14.3 -29.2 -11.3        6            1
#>  7  12.8 -25.5  -9.73       7            1
#>  8  12.4 -22.6  -9.89       8            1
#>  9  11.1 -20.0 -10.7        9            1
#> 10  12.8 -16.6 -12.8       10            1
#> # … with 38,687 more rows
```
