retrieve_trk_endianness <- function (input_file) {
  fh <- file(input_file, "rb")
  on.exit({
    close(fh)
  }, add = TRUE)
  seek(fh, where = 996L, origin = "start")
  endian <- "little"
  sizeof_hdr_little <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  if (sizeof_hdr_little == 1000L)
    return(endian)
  else {
    seek(fh, where = 996L, origin = "start")
    endian <- "big"
    sizeof_hdr_big <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
    if (sizeof_hdr_big == 1000L)
      return(endian)
    else
      cli::cli_abort("File {.file {input_file}} is not in TRK format (header
                     sizes {sizeof_hdr_little}/{sizeof_hdr_big} in little/big
                     endian mode while 1000 was expected).")
  }
}

read_trk <- function(input_file) {
  endian <- retrieve_trk_endianness(input_file)
  fh <- file(input_file, "rb")
  on.exit({
    close(fh)
  }, add = TRUE)
  header <- list()
  header$id_string <- read.fixed.char.binary(fh, 6L)
  header$dim <- readBin(fh, integer(), n = 3, size = 2, endian = endian)
  header$voxel_size <- readBin(fh, numeric(), n = 3, size = 4, endian = endian)
  header$origin <- readBin(fh, numeric(), n = 3, size = 4, endian = endian)
  header$n_scalars <- readBin(fh, integer(), n = 1, size = 2, endian = endian)
  header$scalar_names <- read.fixed.char.binary(fh, 200L)
  header$n_properties <- readBin(fh, integer(), n = 1, size = 2, endian = endian)
  header$property_names <- read.fixed.char.binary(fh, 200L)
  header$vox2ras <- matrix(
    readBin(fh, numeric(), n = 16, size = 4, endian = endian),
    ncol = 4,
    byrow = TRUE
  )
  header$reserved <- read.fixed.char.binary(fh, 444L)
  header$voxel_order <- read.fixed.char.binary(fh, 4L)
  header$pad2 <- read.fixed.char.binary(fh, 4L)
  header$image_orientation_patient <- readBin(fh, numeric(), n = 6, size = 4, endian = endian)
  header$pad1 <- read.fixed.char.binary(fh, 2L)
  header$invert_x <- readBin(fh, integer(), n = 1, size = 1, signed = FALSE, endian = endian)
  header$invert_y <- readBin(fh, integer(), n = 1, size = 1, signed = FALSE, endian = endian)
  header$invert_z <- readBin(fh, integer(), n = 1, size = 1, signed = FALSE, endian = endian)
  header$swap_xy <- readBin(fh, integer(), n = 1, size = 1, signed = FALSE, endian = endian)
  header$swap_yz <- readBin(fh, integer(), n = 1, size = 1, signed = FALSE, endian = endian)
  header$swap_zx <- readBin(fh, integer(), n = 1, size = 1, signed = FALSE, endian = endian)
  header$n_count <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  header$version <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  header$hdr_size <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  if (header$version != 2L)
    cli::cli_alert_warning("TRK file {.file {input_file}} has version {header$version}
                           while only version 2 is supported.")
  if (header$hdr_size != 1000L)
    cli::cli_alert_warning("TRK file {.file {input_file}} header field hdr_size is
                           {header$hdr_size}, must be 1000.")
  tracks <- list()
  if (header$n_count > 0L) {
    for (track_idx in 1L:header$n_count) {
      current_track <- list(scalars = NULL, properties = NULL, coords = NULL)
      current_track$num_points <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
      current_track$coords <- matrix(rep(NA, (current_track$num_points * 3L)), ncol = 3)
      if (header$n_scalars > 0L)
        current_track$scalars <- matrix(
          rep(NA, (current_track$num_points * header$n_scalars)),
          ncol = header$n_scalars
        )
      if (current_track$num_points > 0L) {
        for (track_point_idx in 1L:current_track$num_points) {
          current_track$coords[track_point_idx, ] <- readBin(
            fh, numeric(),
            n = 3,
            size = 4,
            endian = endian
          )
          if (header$n_scalars > 0L)
            current_track$scalars[track_point_idx, ] <- readBin(
              fh, numeric(),
              n = header$n_scalars,
              size = 4,
              endian = endian
            )
        }
      }
      if (header$n_properties > 0L)
        current_track$properties <- readBin(
          fh, numeric(),
          n = header$n_properties,
          size = 4,
          endian = endian
        )
      tracks[[track_idx]] <- current_track
    }
  }
  tracks
}
