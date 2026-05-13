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
  the [`fiber`](https://astamm.github.io/fiber/) package:
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
  predicates, and methods (`new_streamline()`, `is_streamline()`,
  `new_bundle()`, `is_bundle()`, `format()`, `print()`, `length()`, `[[`, `[`,
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
