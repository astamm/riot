## Resubmission 2

In this version, I have:

* Updated the link to freesurferformats R package CRAN page to use canonical form.
* Reduced considerably the execution time of examples.

## Resubmission 1

In this version, I have:

* Added support for MRtrix and TrackVis file formats;
* Removed the use of multiple cores for compiling VTK for compliance with CRAN
policy.

## Test environments
* local macOS R installation, R 4.1.2
* continuous integration via GH actions:
  * macOS latest release
  * windows latest release
  * windows 2022 devel
  * ubuntu 20.04 latest release and devel
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [R-hub](https://builder.r-hub.io)
  - Windows Server 2022, R-devel, 64 bit
  - Ubuntu Linux 20.04.1 LTS, R-release, GCC
  - Fedora Linux, R-devel, clang, gfortran
  - Debian Linux, R-devel, GCC ASAN/UBSAN

## R CMD check results
There was no ERROR and no WARNING.

There was 1 NOTE:

    * checking installed package size ... NOTE
        installed size is 12.9Mb
        sub-directories of 1Mb or more:
          extdata   2.4Mb
          libs     10.4Mb

The size varies according to the system on which the package is installed.
