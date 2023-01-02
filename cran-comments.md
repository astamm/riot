## Test environments
* local macOS R installation, R 4.2.2
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
      installed size is 201.9Mb
      sub-directories of 1Mb or more:
        extdata    5.4Mb
        libs     196.3Mb

The size varies according to the system on which the package is installed.
