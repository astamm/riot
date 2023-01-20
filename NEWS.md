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
* Added support to read [TrackVis](http://trackvis.org/docs/?subsect=fileformat)
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
