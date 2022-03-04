.onUnload <- function (libpath) {
  library.dynam.unload("riot", libpath)
}
