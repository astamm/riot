## Minor version

In this minor version, riot now links against an **externally provided VTK**
(>= 9.1.0) rather than bundling VTK source files. Both shared and static VTK
builds are supported (static builds on macOS/Linux must use `-fPIC`). VTK is
discovered at install time via `configure` / `configure.win` using, in order
of preference:

1. A user-supplied `VTK_DIR` environment variable.
2. Homebrew (macOS).
3. `pkg-config` (macOS and Linux).
4. Well-known system include paths (`/usr`, `/usr/local`) (Linux).
5. The Rtools42+ pacman package for the active MSYS2 environment
   (e.g. `mingw-w64-ucrt-x86_64-vtk` for UCRT64) (Windows).

On Windows, VTK is loaded dynamically at run time (no VTK DLLs are bundled
inside the package). The `SystemRequirements` field in `DESCRIPTION` documents
the external VTK dependency for CRAN infrastructure.

## Test environments

**Local:**
* macOS, R 4.5.3 (current release)
* macOS, R-devel 4.7 (current R-devel)

**Continuous integration via GitHub Actions (`R-CMD-check.yaml`):**
* macOS latest, R release, with system VTK (Homebrew)
* Windows latest, R release (Rtools42+, UCRT64), with system VTK
* Ubuntu latest, R devel (4.6), with system VTK
* Ubuntu latest, R release, with system VTK
* Ubuntu latest, R oldrel-1, with system VTK
* Ubuntu latest, R release, without system VTK (VTK built from source)

**Win-builder:**
* [win-builder](https://win-builder.r-project.org/) R release
* [win-builder](https://win-builder.r-project.org/) R-devel (4.6)

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs.
