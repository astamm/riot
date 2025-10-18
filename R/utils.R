supported_formats <- function() {
  c("vtk", "vtp", "fds", "tck", "trk", "trx", "fib", "dpy")
}

#' Format and print methods for maf_df objects
#'
#' @param x A maf_df object
#' @param ... Additional arguments (not used)
#'
#' @return A formatted string summarizing the maf_df object
#'
#' @name print.maf_df
#' @keywords internal
#' @examples
#' # Create a sample maf_df object
#' sample_data <- tibble::tibble(
#'   X = rnorm(100),
#'   Y = rnorm(100),
#'   Z = rnorm(100),
#'   PointId = rep(1:10, each = 10),
#'   StreamlineId = rep(1:10, times = 10)
#' )
#' class(sample_data) <- c("maf_df", class(sample_data))
#' format(sample_data)
#' print(sample_data)
NULL

#' @export
#' @rdname print.maf_df
format.maf_df <- function(x, ...) {
  n <- length(unique(x$StreamlineId))
  cli::cli_alert_info("Tractogram with {n} streamlines.")
  dist_npts <- sapply(1:n, function(.x) sum(x$StreamlineId == .x))
  cli::cli_alert_info(
    "Distribution of the number of sampled points per streamline: {summary(dist_npts)}."
  )
}

#' @export
#' @rdname print.maf_df
print.maf_df <- function(x, ...) {
  cat(format(x, ...), "\n")
}
