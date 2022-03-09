#' Import fascicles into R
#'
#' @param file Path to the file containing the tractography data. Currently
#'   supported files are `.vtk`, `.vtp` and [medInria](https://med.inria.fr)
#'   `.fds` file formats.
#'
#' @return A \code{\link[tibble]{tibble}} storing the set of fascicles.
#' @export
#'
#' @examples
#' uf_left <- read_fascicles(system.file("extdata", "UF_left.vtp",  package = "riot"))
read_fascicles <- function(file) {
  input_file <- fs::path_norm(file)
  ext <- fs::path_ext(input_file)
  if (!(ext %in% supported_formats())) {
    cli::cli_alert_danger("The extension {.file {ext}} is not yet supported. Currently supported formats are {.file {supported_formats()}}.")
    return()
  }

  output_file <- fs::file_temp(ext = ".csv")
  if (ext == "vtk")
    ReadVTK(input_file, output_file)
  else if (ext == "vtp")
    ReadVTP(input_file, output_file)
  else if (ext == "fds")
    ReadFDS(input_file, output_file)

  df <- readr::read_csv(output_file, show_col_types = FALSE)
  fs::file_delete(output_file)
  cli::cli_alert_success("The fascicles stored in {.file {input_file}} have been successfully imported.")
  class(df) <- c("maf_df", class(df))
  df
}
