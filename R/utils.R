supported_formats <- function() {
  c("vtk", "vtp", "fds", "tck", "trk", "trx", "fib", "dpy")
}

# Internal helper: declare the optional DIPY Python dependency and lazily
# initialise the two module-level globals used by the DIPY code
# paths in read_bundle() and write_bundle().
check_dipy <- function() {
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg reticulate} package is required to read/write this format.",
      "i" = "Install it with {.run install.packages('reticulate')}."
    ))
  }
  # Declare DIPY as an optional Python requirement; reticulate >= 1.41
  # will provision it automatically in an ephemeral virtual environment.
  reticulate::py_require("dipy")
  if (is.null(io_stateful_tractogram)) {
    io_stateful_tractogram <<- reticulate::import("dipy.io.stateful_tractogram")
    io_streamline <<- reticulate::import("dipy.io.streamline")
  }
  invisible(NULL)
}
