supported_formats <- function() {
  c("vtk", "vtp", "fds", "tck", "trk", "trx", "fib", "dpy")
}

# Internal helper: check that the optional dipy Python package is available,
# then lazily initialise the two module-level globals used by the DIPY code
# paths in read_tractogram() and write_tractogram().
check_dipy <- function() {
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg reticulate} package is required to read/write this format.",
      "i" = "Install it with {.run install.packages('reticulate')}."
    ))
  }
  if (!reticulate::py_module_available("dipy")) {
    cli::cli_abort(c(
      "The Python {.pkg dipy} package is required to read/write this format.",
      "i" = "Install it with {.run reticulate::py_install('dipy')}."
    ))
  }
  if (is.null(io_stateful_tractogram)) {
    io_stateful_tractogram <<- reticulate::import("dipy.io.stateful_tractogram")
    io_streamline         <<- reticulate::import("dipy.io.streamline")
  }
  invisible(NULL)
}
