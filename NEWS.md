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
  5. The Rtools45 / UCRT64 pacman package
     `mingw-w64-ucrt-x86_64-vtk` (Windows).
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
