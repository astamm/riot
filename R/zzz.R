io_stateful_tractogram <- NULL
io_streamline <- NULL

.onLoad <- function(libname, pkgname) {
  # VTK is linked statically into riot.dll on Windows, so no DLL search path
  # registration is needed.  We load riot.dll manually here because useDynLib
  # is intentionally absent from NAMESPACE (so R does not auto-load the DLL
  # before this hook has a chance to run, which would be relevant if we ever
  # switch back to dynamic VTK linking).
  #
  # Load the native DLL.
  # During devtools::load_all() / pkgload, libname points to the source tree
  # parent rather than an installed library — library.dynam() would fail there.
  # An installed package always has a libs/ subdirectory; a source tree does not.
  pkg_libs_dir <- file.path(libname, pkgname, "libs")
  if (dir.exists(pkg_libs_dir) && is.null(getLoadedDLLs()[["riot"]])) {
    library.dynam("riot", pkgname, libname)
  }
  reticulate::py_require("fury")
  reticulate::py_require("dipy")
  io_stateful_tractogram <<- reticulate::import(
    "dipy.io.stateful_tractogram",
    delay_load = TRUE
  )
  io_streamline <<- reticulate::import("dipy.io.streamline", delay_load = TRUE)
}

.onUnload <- function(libpath) {
  library.dynam.unload("riot", libpath)
}
