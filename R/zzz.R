io_stateful_tractogram <- NULL
io_streamline <- NULL

.onLoad <- function(libname, pkgname) {
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
