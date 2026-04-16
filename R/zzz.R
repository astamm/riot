io_stateful_tractogram <- NULL
io_streamline <- NULL

.onLoad <- function(libname, pkgname) {
  # On Windows, register the package libs directory as a DLL search path so
  # that the bundled VTK DLLs (and their transitive runtime dependencies) are
  # findable when this package and any subsequently loaded code call back into
  # the native library.
  if (.Platform$OS.type == "windows") {
    lib_dir <- file.path(libname, pkgname, "libs", .Platform$r_arch)
    if (dir.exists(lib_dir)) {
      add_dll_dir <- get("addDLLDirectory", envir = baseenv(), inherits = FALSE)
      tryCatch(add_dll_dir(lib_dir), error = function(e) NULL)
    }
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
