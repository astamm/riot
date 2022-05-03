## Resubmission
This is a resubmission. As per CRAN policies

> [...] Where code is copied (or derived) from the work of others (including from R itself), care must be taken that any copyright/license statements are preserved and authorship is not misrepresented.
Preferably, an ‘Authors@R’ would be used with ‘ctb’ roles for the authors of such code. Alternatively, the ‘Author’ field should list these authors as contributors. [...]

* I added Lee Thomason as a contributor as the author of the TinyXML2 C++ XML parser.
* I checked that the file `LICENSE.md` properly preserve copyright/license statements from both VTK and TinyXML2 softwares, which was already the case in the original submission.
* I did not add the three original authors of the VTK library Ken Martin, Will Schroeder, Bill Lorensen as per their recommandations in their license

> Neither name of Ken Martin, Will Schroeder, or Bill Lorensen nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.

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

* This is a new release.
