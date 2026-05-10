#' Export tractograms from R
#'
#' This function exports a tractogram stored as a [bundle][new_bundle] object
#' to a file in one of the supported formats. Supported formats include VTK
#' (`.vtk`), VTP (`.vtp`), FDS (`.fds`), TRK (`.trk`), TCK (`.tck`), TRX
#' (`.trx`), FIB (`.fib`), and DPY (`.dpy`). For formats that require a
#' reference image (such as TRX, FIB, and DPY), the user must provide the path
#' to a reference image file.
#'
#' Warning: we rely on DIPY to provide support to save tractograms in `.trk`, `.trx`, `.tck`, `.dpy`
#' and `.fib` formats. Among these formats, only `.trk` and `.trx` formats are able to keep track of
#' additional attributes assigned to either streamlines or points.
#'
#' @param x A [bundle][new_bundle] object storing a tractogram.
#' @inheritParams read_tractogram
#'
#' @return The input tractogram (invisibly) so that the function can be
#'   used in pipes.
#'
#' @seealso [read_tractogram()] to import tractograms into R.
#' @export
#' @examples
#' uf_left  <- read_tractogram(system.file("extdata", "UF_left.vtp",  package = "riot"))
#' \dontrun{
#' out <- fs::file_temp(ext = ".vtp")
#' write_tractogram(uf_left, file = out)
#' }
write_tractogram <- function(x, file, reference_file = NULL) {
  xq <- rlang::enquo(x)
  if (!is_bundle(x)) {
    cli::cli_abort(
      "The input object {.code {rlang::as_name(xq)}} is not of class {.cls bundle}."
    )
  }

  output_file <- fs::path_expand(file)
  output_file <- fs::path_norm(output_file)
  ext <- fs::path_ext(output_file)
  if (!(ext %in% supported_formats())) {
    cli::cli_abort(
      "The extension {.file {ext}} is not yet supported. Currently supported formats for exporting are {.file {supported_formats()}}."
    )
  }

  if (ext %in% c("vtk", "vtp", "fds")) {
    flat <- bundle_to_flat_list(x)
    if (ext == "vtk") {
      WriteVTK(flat, output_file)
    } else if (ext == "vtp") {
      WriteVTP(flat, output_file)
    } else if (ext == "fds") {
      WriteFDS(flat, output_file)
    }
  } else {
    if (is.null(reference_file)) {
      cli::cli_abort(
        "For {.file {ext}} files, a reference image must be provided to save the tractogram."
      )
    }
    # nocov start
    reference_file <- fs::path_expand(reference_file)
    reference_file <- fs::path_norm(reference_file)
    n_streamlines <- length(x)
    # Each streamline is a matrix; pass only the X/Y/Z columns
    streamlines <- lapply(x, function(sl) sl[, c("X", "Y", "Z"), drop = FALSE])

    # Extra per-point attribute columns
    extra_cols <- setdiff(colnames(x[[1L]]), c("X", "Y", "Z"))
    extra_data <- lapply(extra_cols, function(col) {
      lapply(x, function(sl) sl[, col])
    })
    names(extra_data) <- extra_cols
    tgm <- io_stateful_tractogram$StatefulTractogram(
      streamlines = streamlines,
      reference = reference_file,
      space = io_stateful_tractogram$Space("rasmm"),
      data_per_point = extra_data
    )
    io_streamline$save_tractogram(tgm, output_file)
    # nocov end
  }

  cli::cli_alert_success(
    "The tractogram stored in {.code {rlang::as_name(xq)}} has been successfully exported to {.file {output_file}}."
  )
  invisible(x)
}
