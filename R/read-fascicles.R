#' Import fascicles into R
#'
#' @param file Path to the file containing the tractography data. Currently
#'   supported files are `.vtk`, `.vtp`, [medInria](https://med.inria.fr)
#'   `.fds`, `.tck/.tsf`
#'   [MRtrix](https://mrtrix.readthedocs.io/en/latest/getting_started/image_data.html),
#'   `.trk` [TrackVis](http://trackvis.org/docs/?subsect=fileformat) file
#'   formats.
#'
#' @return A \code{\link[tibble]{tibble}} storing the set of fascicles.
#' @export
#'
#' @examples
#' uf_left_vtk <- read_fascicles(system.file("extdata", "UF_left.vtk",  package = "riot"))
read_fascicles <- function(file) {
  input_file <- fs::path_expand(file)
  input_file <- fs::path_norm(input_file)
  ext <- fs::path_ext(input_file)
  if (!(ext %in% read_formats())) {
    cli::cli_abort("The extension {.file {ext}} is not yet supported. Currently supported formats for import are {.file {read_formats()}}.")
  }

  if (ext %in% c("vtk", "vtp", "fds")) {
    output_file <- fs::file_temp(ext = ".csv")
    if (ext == "vtk")
      ReadVTK(input_file, output_file)
    else if (ext == "vtp")
      ReadVTP(input_file, output_file)
    else if (ext == "fds")
      ReadFDS(input_file, output_file)
    df <- readr::read_csv(output_file, show_col_types = FALSE)
    fs::file_delete(output_file)
  } else if (ext == "tck") {
    df <- read_mrtrix(input_file)
  } else if (ext == "trk") {
    df <- read_trk(input_file)
  }

  cli::cli_alert_success("The fascicles stored in {.file {input_file}} have been successfully imported.")
  class(df) <- c("maf_df", class(df))
  df
}
