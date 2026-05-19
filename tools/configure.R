vtk_cppflags <- rvtk::CppFlags()
vtk_libs <- rvtk::LdFlagsFile(
  path = "src/vtk_libs.rsp",
  modules = c(
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
)
template <- readLines("src/Makevars.in")
result <- gsub("@VTK_CPPFLAGS@", vtk_cppflags, template, fixed = TRUE)
result <- gsub("@VTK_LIBS@", vtk_libs, result, fixed = TRUE)
writeLines(result, "src/Makevars")
