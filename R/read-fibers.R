#' Import fibers into R
#'
#' @param file A path string to the file from tractography algorithm. Currently
#'   supported files are `.vtk` and `.vtp` files.
#'
#' @return A \code{\link[tibble]{tibble}} storing the set of tracts.
#' @export
#'
#' @examples
#' uf_left  <- fiberIO::read_tracts(system.file("extdata", "UF_left.vtp", package = "fiberIO"))
#' uf_right <- fiberIO::read_tracts(system.file("extdata", "UF_right.vtp", package = "fiberIO"))
read_fibers <- function(file) {
  input_file <- normalizePath(file)
  output_file <- tempfile(fileext = ".csv")
  ext <- tools::file_ext(file)
  if (ext == "vtk")
    ReadVTK(input_file, output_file)
  else if (ext == "vtp")
    ReadVTP(input_file, output_file)
  else
    stop(paste("The extension", ext, "is not yet supported."))
  df <- readr::read_csv(output_file)
  unlink(output_file)
  df
}
