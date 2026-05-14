#' Export bundles from R
#'
#' This function exports a bundle stored as a [bundle][new_bundle] object
#' to a file in one of the supported formats. Supported formats include VTK
#' (`.vtk`), VTP (`.vtp`), FDS (`.fds`), TRK (`.trk`), TCK (`.tck`), TRX
#' (`.trx`), FIB (`.fib`), and DPY (`.dpy`). For formats that require a
#' reference image (such as TRX, FIB, and DPY), the user must provide the path
#' to a reference image file.
#'
#' Warning: we rely on DIPY to provide support to save bundles in `.trk`, `.trx`, `.tck`, `.dpy`
#' and `.fib` formats. Among these formats, only `.trk` and `.trx` formats are able to keep track of
#' additional attributes assigned to either streamlines or points.
#'
#' @param x A [bundle][new_bundle] object.
#' @inheritParams read_bundle
#'
#' @return The input bundle (invisibly) so that the function can be
#'   used in pipes.
#'
#' @seealso [read_bundle()] to import bundles into R.
#' @export
#' @examples
#' uf_left  <- read_bundle(system.file("extdata", "UF_left.vtp",  package = "riot"))
#' \dontrun{
#' out <- fs::file_temp(ext = ".vtp")
#' write_bundle(uf_left, file = out)
#' }
write_bundle <- function(x, file, reference_file = NULL) {
  xq <- rlang::enquo(x)
  if (!fiber::is_bundle(x)) {
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
        "For {.file {ext}} files, a reference image must be provided to save the bundle."
      )
    }
    # nocov start
    check_dipy()
    reference_file <- fs::path_expand(reference_file)
    reference_file <- fs::path_norm(reference_file)
    n_streamlines <- length(x@streamlines)

    # Coordinate matrices (n_pts × 3) for each streamline
    streamlines_xyz <- lapply(x@streamlines, function(sl) sl@points)

    # Per-point attributes: named list of lists (one inner list per streamline)
    all_pd_keys <- unique(unlist(lapply(x@streamlines, function(sl) {
      names(sl@point_data)
    })))
    extra_data <- if (length(all_pd_keys) > 0L) {
      stats::setNames(
        lapply(all_pd_keys, function(nm) {
          lapply(x@streamlines, function(sl) sl@point_data[[nm]])
        }),
        all_pd_keys
      )
    } else {
      list()
    }

    # Per-streamline attributes: named numeric matrix (n_streamlines × 1)
    all_sld_keys <- unique(unlist(lapply(x@streamlines, function(sl) {
      names(sl@streamline_data)
    })))
    sl_data <- if (length(all_sld_keys) > 0L) {
      stats::setNames(
        lapply(all_sld_keys, function(nm) {
          unlist(lapply(x@streamlines, function(sl) sl@streamline_data[[nm]]))
        }),
        all_sld_keys
      )
    } else {
      list()
    }

    tgm <- io_stateful_tractogram$StatefulTractogram(
      streamlines = streamlines_xyz,
      reference = reference_file,
      space = io_stateful_tractogram$Space("rasmm"),
      data_per_point = extra_data,
      data_per_streamline = sl_data
    )
    io_streamline$save_tractogram(tgm, output_file)
    # nocov end
  }

  cli::cli_alert_success(
    "The bundle stored in {.code {rlang::as_name(xq)}} has been successfully exported to {.file {output_file}}."
  )
  invisible(x)
}
