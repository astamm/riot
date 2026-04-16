# src/install.libs.R -- called by R CMD INSTALL instead of the default
# shared-object copy step.  It copies riot.dll and, on Windows, records the
# VTK bin directory so that .onLoad() can register it as a DLL search path.
# The VTK DLLs themselves are NOT bundled; they are resolved at runtime from
# the Rtools45/MSYS2 installation, exactly as on macOS and Linux.
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

# 2. On Windows, install vtk_config so .onLoad() can register the VTK bin dir
if (WINDOWS) {
  cfg_src <- file.path(R_PACKAGE_SOURCE, "src", "vtk_config")
  if (!file.exists(cfg_src)) {
    stop("src/vtk_config not found -- was configure.win run?")
  }
  cfg_dst <- file.path(dest, "vtk_config")
  file.copy(cfg_src, cfg_dst, overwrite = TRUE)
  message("Installed: vtk_config")
}
