.onUnload <- function (libpath) {
  library.dynam.unload("fiberIO", libpath)
}
