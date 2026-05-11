# riot 1.3.0

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

## New data model: `streamline` and `bundle` objects

* **Breaking change**: the `maf_df` tibble (with columns `X`, `Y`, `Z`,
  `PointId`, `StreamlineId`) is replaced by two new S3 classes:
  * `streamline` — a numeric matrix with named columns `X`, `Y`, `Z` (plus
    optional per-point scalar attribute columns). Each row is an ordered point
    along a single tract. `PointId` is implicit in row order and is no longer
    stored.
  * `bundle` — an ordered list of `streamline` objects representing a
    collection of tracts. `StreamlineId` is implicit in list position and is
    no longer stored.
* `read_bundle()` now returns a `streamline` when the file contains
  exactly one tract, and a `bundle` otherwise.
* `write_bundle()` accepts both `streamline` and `bundle` objects.
* New constructors and predicates exported: `new_streamline()`,
  `is_streamline()`, `new_bundle()`, `is_bundle()`.
* `print()` and `format()` methods provided for both classes.
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
