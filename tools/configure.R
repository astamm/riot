args <- commandArgs(trailingOnly = TRUE)
flag <- if (length(args)) args[1L] else "--cppflags"

vtk_modules <- c(
  "VTK_IOLegacy",
  "VTK_IOXML",
  "VTK_IOXMLParser",
  "VTK_IOCore",
  "VTK_CommonCore",
  "VTK_CommonDataModel",
  "VTK_CommonExecutionModel",
  "VTK_CommonMath",
  "VTK_CommonMisc",
  "VTK_CommonSystem",
  "VTK_CommonTransforms"
)

if (flag == "--cppflags") {
  rvtk::CppFlags()
} else if (flag == "--libs") {
  # LdFlagsFile() writes the (potentially very long) list of static VTK
  # libraries to an .rsp response file and returns "@vtk_libs.rsp".
  # This avoids Windows command-line length limits for the linker invocation.
  # Make invokes this script with cwd=src/, so path="vtk_libs.rsp" creates
  # src/vtk_libs.rsp, and the linker resolves @vtk_libs.rsp from that same cwd.
  # Note: LdFlagsFile() already calls writeLines() internally, so no cat() here.
  rvtk::LdFlagsFile(path = "vtk_libs.rsp", modules = vtk_modules)
}
