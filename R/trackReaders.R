#' Read tracts in .VTP format
#'
#' @param file A path string to the `.vtp` file.
#'
#' @return A \code{\link[tibble]{tibble}} storing the set of tracts.
#' @export
#'
#' @examples
read_vtp <- function(file) {
  file <- normalizePath(file)
  res <- ReadVTP(file)
  tibble::as_tibble(res)
}
