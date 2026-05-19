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
  cat(rvtk::CppFlags())
} else if (flag == "--libs") {
  cat(rvtk::LdFlags(modules = vtk_modules))
}
