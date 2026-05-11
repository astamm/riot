#' Import bundles into R
#'
#' This is the go-to function to import bundles into R. Based on both VTK and DIPY, we currently
#' support eight different formats detailed in the documentation of input argument `file`.
#'
#' @param file A string specifying the path to the file containing the tractography data. Currently
#'   supported files are:
#'   - standard [VTK](https://vtk.org) formats `.vtk` and `.vtp`,
#'   - [medInria](https://med.inria.fr) `.fds` format,
#'   - [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html) `.tck/.tsf` format,
#'   - [TrackVis](https://trackvis.org/docs/?subsect=fileformat) `.trk` and `.trx` formats,
#'   - [DIPY](https://docs.dipy.org/1.11.0/) `.dpy` format,
#'   - `.fib` format.
#' @param reference_file A string specifying the path to a reference image file. This is only required
#' when importing `.trx`, `.fib`, or `.dpy` files, as these formats do not contain spatial
#' information about the image space. The reference image is used to correctly position the
#' bundle in the appropriate space. Default is `NULL`.
#'
#' @return A [bundle][new_bundle] object when the file contains multiple
#'   streamlines, or a [streamline][new_streamline] object when it contains
#'   exactly one. Each `streamline` is a numeric matrix with at least three
#'   named columns `"X"`, `"Y"`, and `"Z"` (one row per point along the
#'   tract). Additional per-point scalar attributes, when present in the source
#'   file, appear as extra named columns.
#'
#' @seealso [write_bundle()] to export bundles from R.
#' @export
#' @examples
#' uf_left_vtk <- read_bundle(system.file("extdata", "UF_left.vtk",  package = "riot"))
read_bundle <- function(file, reference_file = NULL) {
  input_file <- fs::path_expand(file)
  input_file <- fs::path_norm(input_file)
  ext <- fs::path_ext(input_file)
  if (!(ext %in% supported_formats())) {
    cli::cli_abort(
      "The extension {.file {ext}} is not yet supported. Currently supported formats for import are {.file {supported_formats()}}."
    )
  }

  if (ext %in% c("vtk", "vtp", "fds")) {
    if (ext == "vtk") {
      result <- flat_list_to_bundle(ReadVTK(input_file))
    } else if (ext == "vtp") {
      result <- flat_list_to_bundle(ReadVTP(input_file))
    } else if (ext == "fds") {
      result <- flat_list_to_bundle(ReadFDS(input_file))
    }
  } else if (ext == "tck") {
    result <- read_mrtrix(input_file)
  } else if (ext == "trk") {
    result <- read_trk(input_file)
  } else if (ext %in% c("trx", "fib", "dpy")) {
    if (is.null(reference_file)) {
      cli::cli_abort(
        "For {.file {ext}} files, a reference image must be provided to load the bundle."
      )
    }
    # nocov start
    check_dipy()
    reference_file <- fs::path_expand(reference_file)
    reference_file <- fs::path_norm(reference_file)
    tgm <- io_streamline$load_tractogram(input_file, reference_file)
    raw_streamlines <- tgm$get_streamlines_copy()
    n_streamlines <- length(raw_streamlines)

    streamline_attributes <- tgm$get_data_per_streamline_keys()
    point_attributes <- tgm$get_data_per_point_keys()

    streamlines <- lapply(0:(n_streamlines - 1), function(index) {
      sl_mat <- raw_streamlines[index] # n_pts x 3 matrix
      n_pts <- nrow(sl_mat)
      pts <- cbind(X = sl_mat[, 1], Y = sl_mat[, 2], Z = sl_mat[, 3])

      # Per-point attributes
      pd <- if (length(point_attributes) > 0L) {
        setNames(
          lapply(point_attributes, function(attr) {
            tgm$data_per_point[attr][[index + 1]][seq_len(n_pts)]
          }),
          point_attributes
        )
      } else {
        list()
      }

      # Per-streamline attributes (one scalar per streamline)
      sld <- if (length(streamline_attributes) > 0L) {
        setNames(
          lapply(streamline_attributes, function(attr) {
            tgm$data_per_streamline[attr][index + 1]
          }),
          streamline_attributes
        )
      } else {
        list()
      }

      new_streamline(pts, point_data = pd, streamline_data = sld)
    })

    result <- new_bundle(streamlines)
    # nocov end
  }

  cli::cli_alert_success(
    "The bundle stored in {.file {input_file}} has been successfully imported."
  )
  result
}
