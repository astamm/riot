#' @export
read_vtp <- function(file) {
  file <- normalizePath(file)
  res <- ReadVTP(file)
  tibble::as_tibble(res)
}
