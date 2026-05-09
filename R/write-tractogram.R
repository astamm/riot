#' Export tractograms from R
#'
#' This function exports a tractogram stored as a `maf_df` object to a
#' file in one of the supported formats. Supported formats include VTK (`.vtk`),
#' VTP (`.vtp`), FDS (`.fds`), TRK (`.trk`), TCK (`.tck`), TRX (`.trx`),
#' FIB (`.fib`), and DPY (`.dpy`). For formats that require a reference image
#' (such as TRX, FIB, and DPY), the user must provide the path to a reference
#' image file.
#'
#' Warning: we rely on DIPY to provide support to save tractograms in `.trk`, `.trx`, `.tck`, `.dpy`
#' and `.fib` formats. Among these formats, only `.trk` and `.trx` formats are able to keep track of
#' additional attributes assigned to either streamlines or points.
#'
#' @param x An object of class `maf_df` storing a tractogram.
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
  if (!("maf_df" %in% class(x))) {
    cli::cli_abort(
      "The input object {.code {rlang::as_name(xq)}} is not of class {.cls maf_df} but has class {.cls {class(x)}}."
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
    if (ext == "vtk") {
      WriteVTK(x, output_file)
    } else if (ext == "vtp") {
      WriteVTP(x, output_file)
    } else if (ext == "fds") {
      WriteFDS(x, output_file)
    }
  } else {
    if (is.null(reference_file)) {
      cli::cli_abort(
        "For {.file {ext}} files, a reference image must be provided to save the tractogram."
      )
    }
    reference_file <- fs::path_expand(reference_file)
    reference_file <- fs::path_norm(reference_file)
    # Extract streamline as a list of 3-column matrices from x
    n_streamlines <- length(unique(x$StreamlineId))
    streamlines <- lapply(1:n_streamlines, function(streamline_index) {
      as.matrix(subset(
        x,
        x$StreamlineId == streamline_index,
        select = c(x$X, x$Y, x$Z)
      ))
    })
    # Extract additional data per point if any
    extra_cols <- names(x)[
      !names(x) %in% c("X", "Y", "Z", "PointId", "StreamlineId")
    ]
    extra_data <- lapply(extra_cols, function(col) {
      lapply(1:n_streamlines, function(streamline_index) {
        subset(
          x,
          x$StreamlineId == streamline_index,
          select = col
        )[[col]]
      })
    })
    names(extra_data) <- extra_cols
    tgm <- io_stateful_tractogram$StatefulTractogram(
      streamlines = streamlines,
      reference = reference_file,
      space = io_stateful_tractogram$Space("rasmm"),
      data_per_point = extra_data
    )
    io_streamline$save_tractogram(tgm, output_file)
  }

  cli::cli_alert_success(
    "The tractogram stored in {.code {rlang::as_name(xq)}} has been successfully exported to {.file {output_file}}."
  )
  invisible(x)
}
