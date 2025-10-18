#' Import tractograms into R
#'
#' This is the go-to function to import tractograms into R. Based on both VTK and DIPY, we currently
#' support eight different formats detailed in the documentation of input argument `file`.
#'
#' @param file Path to the file containing the tractography data. Currently
#'   supported files are:
#'   - standard [VTK](https://vtk.org) formats `.vtk` and `.vtp`,
#'   - [medInria](https://med.inria.fr) `.fds` format,
#'   - [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html) `.tck/.tsf` format,
#'   - [TrackVis](http://trackvis.org/docs/?subsect=fileformat) `.trk` and `.trx` formats,
#'   - [DIPY](https://docs.dipy.org/1.11.0/) `.dpy` format,
#'   - `.fib` format.
#'
#' @return A special [tibble][tibble::tibble] (of class `maf_df`) containing the
#' tractogram data with the following columns:
#'
#' - `X`: X coordinate of the point.
#' - `Y`: Y coordinate of the point.
#' - `Z`: Z coordinate of the point.
#' - `PointId`: Identifier of the point within its streamline.
#' - `StreamlineId`: Identifier of the streamline.
#'
#' The tractogram may contain additional columns that are attributes to either points or streamlines.
#'
#' @seealso [write_tractogram()] to export tractograms from R.
#' @export
#' @examples
#' uf_left_vtk <- read_tractogram(system.file("extdata", "UF_left.vtk",  package = "riot"))
read_tractogram <- function(file, reference_file = NULL) {
  input_file <- fs::path_expand(file)
  input_file <- fs::path_norm(input_file)
  ext <- fs::path_ext(input_file)
  if (!(ext %in% supported_formats())) {
    cli::cli_abort(
      "The extension {.file {ext}} is not yet supported. Currently supported formats for import are {.file {supported_formats()}}."
    )
  }

  if (ext %in% c("vtk", "vtp", "fds")) {
    output_file <- fs::file_temp(ext = ".csv")
    if (ext == "vtk") {
      ReadVTK(input_file, output_file)
    } else if (ext == "vtp") {
      ReadVTP(input_file, output_file)
    } else if (ext == "fds") {
      ReadFDS(input_file, output_file)
    }
    df <- readr::read_csv(output_file, show_col_types = FALSE)
    fs::file_delete(output_file)
  } else if (ext == "tck") {
    df <- read_mrtrix(input_file)
  } else if (ext == "trk") {
    df <- read_trk(input_file)
  } else if (ext %in% c("trx", "fib", "dpy")) {
    if (is.null(reference_file)) {
      cli::cli_abort(
        "For {.file {ext}} files, a reference image must be provided to load the tractogram."
      )
    }
    reference_file <- fs::path_expand(reference_file)
    reference_file <- fs::path_norm(reference_file)
    tgm <- io_streamline$load_tractogram(input_file, reference_file)
    df <- tgm$get_streamlines_copy()
    n_streamlines <- length(df)
    df <- lapply(0:(n_streamlines - 1), function(index) {
      n_points <- nrow(df[index])
      cbind(df[index], 1:n_points, rep(index + 1, length.out = n_points))
    })
    df <- do.call(rbind, df)
    colnames(df) <- c("X", "Y", "Z", "PointId", "StreamlineId")
    df <- tibble::as_tibble(df)
    streamline_attributes <- tgm$get_data_per_streamline_keys()
    if (length(streamline_attributes) > 0) {
      for (attr in streamline_attributes) {
        attr_values <- tgm$data_per_streamline[attr]
        df_attr <- lapply(1:n_streamlines, function(index) {
          n_points <- sum(df$StreamlineId == index)
          rep(attr_values[index], length.out = n_points)
        })
        df_attr <- do.call(c, df_attr)
        df[[attr]] <- df_attr
      }
    }
    point_attributes <- tgm$get_data_per_point_keys()
    if (length(point_attributes) > 0) {
      for (attr in point_attributes) {
        attr_values <- tgm$data_per_point[attr]
        df_attr <- lapply(1:n_streamlines, function(index) {
          n_points <- sum(df$StreamlineId == index)
          attr_streamline <- attr_values[[index]]
          attr_streamline[1:n_points]
        })
        df_attr <- do.call(c, df_attr)
        df[[attr]] <- df_attr
      }
    }
  }

  cli::cli_alert_success(
    "The tractogram stored in {.file {input_file}} has been successfully imported."
  )
  class(df) <- c("maf_df", class(df))
  df
}
