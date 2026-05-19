# riot (development version)

### Bug fixes

* **Windows `R CMD check` fix: `quarto` CLI `TMPDIR` error.**
  The `R-CMD-check` workflow now sets `QUARTO_PATH=nonexistent` on Windows
  before running the check. The `quarto` R package calls
  `system2("quarto", "-V", env = paste0("TMPDIR=", …))`, which on Windows
  passes the env assignment as a positional argument to the CLI rather than
  setting it as an environment variable, causing
  `ERROR: Unknown command "TMPDIR=…"`. Setting `QUARTO_PATH` to a nonexistent
  value makes `find_quarto()` return `NULL` immediately, so `system2` is
  never called.

* **Windows `R CMD check` fix: `configure` fails with "unexpected end of input".**
  `configure`, `configure.win`, and `src/Makevars.in` have been replaced by a
  static `src/Makevars` that uses POSIX backtick syntax (per *Writing R
  Extensions*) to call `tools/configure.R` directly at compile time:
  ```makefile
  PKG_CPPFLAGS = `"${R_HOME}/bin/Rscript" --vanilla ../tools/configure.R --cppflags`
  PKG_LIBS     = `"${R_HOME}/bin/Rscript" --vanilla ../tools/configure.R --libs`
  ```
  `tools/configure.R` calls `rvtk::CppFlags()` or `rvtk::LdFlags(modules = …)`
  and writes the result to stdout via `cat()`. The previous approach embedded a
  multi-line R expression in a `Rscript -e` argument inside a shell `$()`
  subshell; under Rtools' `bash` on Windows the embedded newlines caused R to
  receive a truncated expression, producing "unexpected end of input".
  `configure`, `configure.win`, and `cleanup` are now no-op stubs kept only to
  suppress R CMD check warnings about missing scripts.

* **`configure` / `cleanup` / `configure.win` execute-permission warnings silenced.**
  The git index mode for all three files is now `100755`, so R CMD check no
  longer needs to correct missing execute permissions at check time.

* **macOS `R CMD check` fix: `_NSEventTrackingRunLoopMode` not found.**
  The `configure` script now calls `rvtk::LdFlagsFile()` with an explicit
  `modules` argument, linking only the VTK I/O and Common modules that riot
  actually uses.  Previously, when `rvtk` fell back to its pre-built static
  bundle (the case for the CRAN binary on macOS CI), `-Wl,-all_load` forced
  every symbol from every `.a` — including rendering modules that reference
  `_NSEventTrackingRunLoopMode` from `AppKit.framework` — into `riot.so`,
  causing `dlopen()` to fail at check time.

# riot 2.0.0

## API rename: `read_bundle()` and `write_bundle()`

* **Breaking change**: `read_tractogram()` and `write_tractogram()` are renamed
  to `read_bundle()` and `write_bundle()` for consistency with the `bundle`
  data model.

## DIPY dependency declaration modernised

* The optional DIPY Python dependency is now declared via
  `reticulate::py_require("dipy")` (reticulate ≥ 1.41) instead of the
  previous manual `py_module_available()` check. Reticulate will automatically
  provision DIPY in an ephemeral virtual environment when one of the
  DIPY-backed formats (`.trx`, `.fib`, `.dpy`) is first used.

## S7 data model: `streamline` and `bundle` classes moved to `{fiber}`

* **Breaking change**: the `maf_df` tibble (with columns `X`, `Y`, `Z`,
  `PointId`, `StreamlineId`) is replaced by two **S7** classes now defined in
  the [`fiber`](https://tractoverse.github.io/fiber/) package:
  * `streamline` — stores three typed slots accessed with `@`:
    - `@points`: an $n \times 3$ numeric matrix with columns `"X"`, `"Y"`,
      `"Z"` for the ordered coordinates of the $n$ points along the tract.
      `PointId` is implicit in row order and is no longer stored.
    - `@point_data`: a named list of numeric vectors of length $n$, holding
      per-point scalar attributes (e.g. fractional anisotropy at each point).
    - `@streamline_data`: a named list of numeric scalars (length-1 vectors)
      holding per-streamline attributes (e.g. a tract-level weight or mean FA).
  * `bundle` — stores two typed slots:
    - `@streamlines`: a list of `streamline` objects. `StreamlineId` is
      implicit in list position and is no longer stored.
    - `@bundle_data`: a named list of bundle-level metadata (e.g. the affine
      transform used during tracking).
* **riot** no longer depends on **S7** directly; the S7 classes, constructors,
  predicates, and methods (`streamline()`, `is_streamline()`,
  `bundle()`, `is_bundle()`, `format()`, `print()`, `length()`, `[[`, `[`,
  …) are all provided by **fiber** and re-exported from there.
* **riot** now imports **fiber** instead of **S7**.
* `read_bundle()` returns a `streamline` when the file contains exactly one
  tract, and a `bundle` otherwise.
* `write_bundle()` accepts both `streamline` and `bundle` objects.
* The `readr` package is no longer a dependency.

## C++ layer: elimination of intermediate CSV files

* **Breaking change** (internal): the C++ reader functions (`ReadVTK`,
  `ReadVTP`, `ReadFDS`) no longer write a temporary CSV file. They now return
  a `cpp11::writable::list` directly to R, eliminating all temporary file I/O
  and the associated string-reference issues.
* The C++ writer functions (`WriteVTK`, `WriteVTP`, `WriteFDS`) no longer
  read from a temporary CSV. They now accept a `cpp11::list` directly from R.
* The helper `WriteCSV` (vtkPolyData → CSV) and `ReadCSV` (CSV →
  vtkPolyData) are replaced by `PolyDataToList` and `ListToPolyData`
  respectively, operating entirely in memory.

## VTK bindings delegated to `rvtk`

* VTK discovery, compilation flags, and pre-built static library distribution
  are now handled entirely by the
  [`rvtk`](https://github.com/astamm/rvtk) package (pending CRAN
  submission). `rvtk` supplies pre-compiled VTK headers and libraries so that
  no manual VTK installation is required on most platforms: it honours a
  user-supplied `VTK_DIR` environment variable first, then tries Homebrew
  (macOS), `pkg-config` (macOS/Linux), and well-known system prefixes; on
  Windows it checks `VTK_DIR`, Rtools45 pacman, and common MSYS2 prefixes; if
  no suitable system VTK is found it downloads pre-built static libraries
  automatically from the `rvtk` GitHub releases.
* `rvtk` is listed as an `Imports` dependency; downstream packages no longer
  need to locate VTK themselves.
* The `Remotes: astamm/rvtk` field will be removed from `DESCRIPTION` once
  `rvtk` is available on CRAN.

# riot 1.2.0

* **Breaking change in system requirements**: riot no longer bundles VTK
  source files. Instead, it links against an externally installed VTK
  (>= 9.1.0) at compile time. VTK must be present on the host before
  installing the package. Both shared and static VTK builds are supported;
  static builds on macOS and Linux must have been compiled with `-fPIC`.
* VTK is discovered at install time via `configure` / `configure.win` using,
  in order of preference:
  1. A user-supplied `VTK_DIR` environment variable.
  2. Homebrew (macOS).
  3. `pkg-config` (macOS and Linux).
  4. Well-known system include paths (`/usr`, `/usr/local`) (Linux).
  5. The Rtools42+ pacman package for the active MSYS2 environment
     (e.g. `mingw-w64-ucrt-x86_64-vtk` for UCRT64) (Windows).
* On Windows, VTK is loaded dynamically at run time via `addDLLDirectory()`
  to avoid having to bundle VTK runtime DLLs inside the package.
* Removed all bundled VTK source files, reducing the installed package size
  considerably.
* Updated `SystemRequirements` in `DESCRIPTION` to document the external VTK
  dependency.

# riot 1.1.1

* Modified VTK source files to avoid compilation warnings arising when using 
LLVM or Apple clang or GNU gcc compilers.
* Now ships a shrunk version of VTK source files to avoid unsuccessful downloads 
from VTK website.
* Fix compilation errors in `vtkzlib` raised by `clang16`.

# riot 1.1.0

* Update VTK to `v9.2.4`;
* Avoid some prototype checks for `vtkzlib` when using LLVM Clang compiler.

# riot 1.0.0

In this first major release, we:

* Added support to read
[MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html)
`.tck/.tsf` file formats (#5).
* Added support to read [TrackVis](https://trackvis.org/docs/?subsect=fileformat)
`.trk` file formats (#5).
* Use only one core to compile VTK for compliance with CRAN policy (thanks to
Prof. B. Ripley).
* Added tilde expansion on file paths.

We make it the first major release as we consider that the most popular
tractography formats are now supported by **riot**. We chose by design to
support only VTK and medInria file formats for writing.

# riot 0.0.1

* Added a `NEWS.md` file to track changes to the package.
* Supports for reading from and writing to `.vtk`, `.vtp` and `.fds` file 
  formats.
