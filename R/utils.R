write_formats <- function() {
  c("vtk", "vtp", "fds")
}

read_formats <- function() {
  c(write_formats(), "tck", "trk")
}

format.maf_df <- function(x, ...) {
  n <- length(unique(x$StreamlineId))
  cli::cli_alert_info("Set of {n} fascicles.")
  dist_npts <- sapply(1:n, function(.x) sum(x$StreamlineId == .x))
  cli::cli_alert_info("Distribution of the number of sampled points per fascicles: {summary(dist_npts)}.")
}

print.maf_df <- function(x, ...) {
  cat(format(x, ...), "\n")
}
