args <- commandArgs(trailingOnly = TRUE)
flag <- if (length(args)) args[1L] else "--cppflags"

if (flag == "--cppflags") {
  rvtk::CppFlags()
} else if (flag == "--libs") {
  # Do NOT pass modules= here. filter_libs() matches module names against
  # library filenames directly: on Windows, rvtk's static libs are named
  # libvtkIOLegacy-9.5.a but CMake module names are "VTK_IOLegacy" (uppercase
  # prefix + underscore), so none pass the filter and the .rsp file ends up
  # empty.  modules=NULL returns the full rvtk-bundled set, which is correct
  # on all platforms:
  #   - Windows: full prebuilt static bundle via .rsp response file
  #   - macOS/Linux system VTK: filter_libs is not called, flags come from vtk.conf
  rvtk::LdFlagsFile(path = "vtk_libs.rsp")
}
