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
There were no ERRORs or WARNINGs.

There were 2 NOTEs:

### NOTE 1 — installed package size (Windows)

    installed size is 57.3 Mb
    sub-directories of 1 Mb or more:
      libs  51.7 Mb

On Windows the VTK runtime DLLs (installed from Rtools45's MSYS2 repository)
are copied into `libs/x64/` so that the package is self-contained after
installation. This inflates the size. The size on macOS and Linux is much
smaller because VTK is linked dynamically and the DLLs are not bundled.

### NOTE 2 — compiled code: `abort`, `exit`, `std::cerr`, `std::cout` (Windows)

    checking compiled code ... NOTE
    Files which contain ... Found '_exit' / 'abort' / 'exit' / std::cerr ...

All flagged symbols originate from the **VTK runtime DLLs** (e.g.
`libvtkcommoncore.dll`, `libvtksys.dll`, etc.) provided by the Rtools45 /
MSYS2 ecosystem and from the GCC/MinGW runtime libraries (`libstdc++-6.dll`,
`libgcc_s_seh-1.dll`, etc.).  These are precompiled third-party binaries
whose internals riot cannot control.  riot's own compiled code (`riot.dll`)
does not call `exit()`, `abort()`, or write to `stdout`/`stderr` directly;
those symbols appear in its import table solely because VTK's own error-
handling routines (in `vtksys` / `vtkObjectBase`) reference them through
inline code pulled in at link time.

The additional note that the VTK DLLs do not call `R_registerRoutines` /
`R_useDynamicSymbols` is expected: they are non-R shared libraries copied in
as runtime dependencies, not R extension DLLs.
