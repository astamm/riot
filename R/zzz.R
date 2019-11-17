.onUnload <- function (libpath) {
  library.dynam.unload("trio", libpath)
}
