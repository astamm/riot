# src/install.libs.R -- called by R CMD INSTALL instead of the default
# shared-object copy step.  It copies riot.dll and all required VTK DLLs
# into the final installation directory.
#
# Environment variables provided by R CMD INSTALL:
#   R_PACKAGE_NAME   - "riot"
#   R_PACKAGE_SOURCE - path to the package source
#   R_PACKAGE_DIR    - path to the target installation directory
#   R_ARCH           - arch suffix, e.g. "/x64" on 64-bit Windows
#   SHLIB_EXT        - shared library extension, e.g. ".dll"
#   WINDOWS          - TRUE on Windows

# 1. Copy the package DLL itself (the default behaviour we must replicate)
dest <- file.path(R_PACKAGE_DIR, paste0("libs", R_ARCH))
dir.create(dest, recursive = TRUE, showWarnings = FALSE)

dll <- paste0(R_PACKAGE_NAME, SHLIB_EXT)
file.copy(dll, dest, overwrite = TRUE)
message("Installed: ", dll)

# 2. On Windows, also copy VTK DLLs so they are found at runtime
if (WINDOWS) {
  # Read VTK version and bin dir written by configure.win
  cfg_file <- file.path(R_PACKAGE_SOURCE, "src", "vtk_config")
  if (!file.exists(cfg_file)) {
    stop("src/vtk_config not found -- was configure.win run?")
  }

  cfg <- read.dcf(cfg_file) # key=value pairs, one per line
  # read.dcf doesn't suit shell key=value; parse manually
  lines <- readLines(cfg_file)
  cfg <- setNames(
    sub("^[^=]+=", "", lines),
    sub("=.*$", "", lines)
  )

  vtk_bin_dir <- cfg[["VTK_BIN_DIR"]]

  vtk_dlls <- paste0(
    c(
      "libvtkIOLegacy",
      "libvtkIOXML",
      #"libvtkIOCore",
      "libvtkCommonCore",
      "libvtkCommonDataModel",
      "libvtkCommonMath",
      "libvtkCommonMisc",
      "libvtkCommonSystem",
      "libvtkCommonTransforms",
      "libvtkIOXMLParser",
      "libvtksys",
      "libvtkexpat",
      "libvtklz4",
      "libvtklzma",
      "libvtkzlib"
    ),
    ".dll"
  )

  for (dll in vtk_dlls) {
    src <- file.path(vtk_bin_dir, dll)
    if (file.exists(src)) {
      file.copy(src, dest, overwrite = TRUE)
      message("Installed VTK DLL: ", dll)
    } else {
      message("Skipped (not found): ", dll)
    }
  }
}
