io_stateful_tractogram <- NULL
io_streamline <- NULL

.onLoad <- function(libname, pkgname) {
  S7::methods_register()
}
