## Minor version

In this minor version, riot now links against an **externally provided VTK**
(>= 9.5.0) rather than bundling VTK source files. VTK is discovered at
install time via `configure` / `configure.win` using, in order of preference:

1. A user-supplied `VTK_DIR` environment variable.
2. Homebrew (macOS).
3. `pkg-config` (macOS and Linux).
4. Well-known system include paths (Linux).
5. The Rtools45 / MSYS2 pacman package `mingw-w64-ucrt-x86_64-vtk` (Windows).

## Test environments
* local macOS R installation, R 4.7.0
* continuous integration via GH Actions:
  * macOS latest release
  * Windows latest release (Rtools45 / UCRT)
  * Ubuntu latest release and devel
* [win-builder](https://win-builder.r-project.org/) (release and devel)
* [R-hub](https://builder.r-hub.io)

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs.
