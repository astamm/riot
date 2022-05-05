#' Export fascicles from R
#'
#' @param x An object of class `maf_df` storing tractography data.
#' @param file Path to a file into which the tractography data should be saved.
#'   Currently supported files are `.vtk`, `.vtp` and
#'   [medInria](https://med.inria.fr) `.fds` file formats.
#'
#' @return The input tractography data (invisibly) so that the function can be
#'   used in pipes.
#' @export
#'
#' @examples
#' uf_left  <- read_fascicles(system.file("extdata", "UF_left.vtp",  package = "riot"))
#' \dontrun{
#' out <- fs::file_temp(ext = ".vtp")
#' write_fascicles(uf_left, file = out)
#' }
write_fascicles <- function(x, file) {
  xq <- rlang::enquo(x)
  if (!("maf_df" %in% class(x))) {
    cli::cli_abort("The input object {.code {rlang::as_name(xq)}} is not of class {.cls maf_df} but has class {.cls {class(x)}}.")
  }

  output_file <- fs::path_norm(file)
  ext <- fs::path_ext(output_file)
  if (!(ext %in% write_formats())) {
    cli::cli_abort("The extension {.file {ext}} is not yet supported. Currently supported formats for exporting are {.file {write_formats()}}.")
  }

  input_file <- fs::file_temp(ext = ".csv")
  readr::write_csv(x, file = input_file)
  if (ext == "vtk")
    WriteVTK(input_file, output_file)
  else if (ext == "vtp")
    WriteVTP(input_file, output_file)
  else if (ext == "fds")
    WriteFDS(input_file, output_file)
  fs::file_delete(input_file)
  cli::cli_alert_success("The fascicles stored in {.code {rlang::as_name(xq)}} have been successfully exported to {.file {output_file}}.")
  invisible(x)
}
