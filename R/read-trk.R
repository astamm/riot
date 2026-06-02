read_fixed_char_binary <- function(fh, n, to = "UTF-8") {
  txt <- readBin(fh, "raw", n)
  iconv(rawToChar(txt[txt != as.raw(0)]), to = to)
}

retrieve_trk_endianness <- function(input_file) {
  fh <- file(input_file, "rb")
  on.exit(
    {
      close(fh)
    },
    add = TRUE
  )
  seek(fh, where = 996L, origin = "start")
  endian <- "little"
  sizeof_hdr_little <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  if (sizeof_hdr_little == 1000L) {
    return(endian)
  } else {
    seek(fh, where = 996L, origin = "start")
    endian <- "big"
    sizeof_hdr_big <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
    if (sizeof_hdr_big == 1000L) {
      return(endian)
    } else {
      cli::cli_abort(
        "File {.file {input_file}} is not in TRK format (header
                     sizes {sizeof_hdr_little}/{sizeof_hdr_big} in little/big
                     endian mode while 1000 was expected)."
      )
    }
  }
}

read_trk <- function(input_file) {
  endian <- retrieve_trk_endianness(input_file)
  fh <- file(input_file, "rb")
  on.exit(
    {
      close(fh)
    },
    add = TRUE
  )
  header <- list()
  header$id_string <- read_fixed_char_binary(fh, 6L)
  header$dim <- readBin(fh, integer(), n = 3, size = 2, endian = endian)
  header$voxel_size <- readBin(fh, numeric(), n = 3, size = 4, endian = endian)
  header$origin <- readBin(fh, numeric(), n = 3, size = 4, endian = endian)
  header$n_scalars <- readBin(fh, integer(), n = 1, size = 2, endian = endian)
  # scalar_names: 10 slots × 20 bytes each (null-terminated per slot)
  scalar_raw <- readBin(fh, "raw", 200L)
  header$scalar_names <- vapply(
    seq_len(10L),
    function(i) {
      chunk <- scalar_raw[((i - 1L) * 20L + 1L):(i * 20L)]
      iconv(rawToChar(chunk[chunk != as.raw(0L)]), to = "UTF-8")
    },
    character(1L)
  )
  header$n_properties <- readBin(
    fh,
    integer(),
    n = 1,
    size = 2,
    endian = endian
  )
  # property_names: 10 slots × 20 bytes each (null-terminated per slot)
  prop_raw <- readBin(fh, "raw", 200L)
  header$property_names <- vapply(
    seq_len(10L),
    function(i) {
      chunk <- prop_raw[((i - 1L) * 20L + 1L):(i * 20L)]
      iconv(rawToChar(chunk[chunk != as.raw(0L)]), to = "UTF-8")
    },
    character(1L)
  )
  header$vox2ras <- matrix(
    readBin(fh, numeric(), n = 16, size = 4, endian = endian),
    ncol = 4,
    byrow = TRUE
  )
  header$reserved <- read_fixed_char_binary(fh, 444L)
  header$voxel_order <- read_fixed_char_binary(fh, 4L)
  header$pad2 <- read_fixed_char_binary(fh, 4L)
  header$image_orientation_patient <- readBin(
    fh,
    numeric(),
    n = 6,
    size = 4,
    endian = endian
  )
  header$pad1 <- read_fixed_char_binary(fh, 2L)
  header$invert_x <- readBin(
    fh,
    integer(),
    n = 1,
    size = 1,
    signed = FALSE,
    endian = endian
  )
  header$invert_y <- readBin(
    fh,
    integer(),
    n = 1,
    size = 1,
    signed = FALSE,
    endian = endian
  )
  header$invert_z <- readBin(
    fh,
    integer(),
    n = 1,
    size = 1,
    signed = FALSE,
    endian = endian
  )
  header$swap_xy <- readBin(
    fh,
    integer(),
    n = 1,
    size = 1,
    signed = FALSE,
    endian = endian
  )
  header$swap_yz <- readBin(
    fh,
    integer(),
    n = 1,
    size = 1,
    signed = FALSE,
    endian = endian
  )
  header$swap_zx <- readBin(
    fh,
    integer(),
    n = 1,
    size = 1,
    signed = FALSE,
    endian = endian
  )
  header$n_count <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  header$version <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  header$hdr_size <- readBin(fh, integer(), n = 1, size = 4, endian = endian)
  if (header$version != 2L) {
    cli::cli_alert_warning(
      "TRK file {.file {input_file}} has version {header$version}
                           while only version 2 is supported."
    )
  }
  if (header$hdr_size != 1000L) {
    # nocov start
    cli::cli_alert_warning(
      "TRK file {.file {input_file}} header field hdr_size is
                           {header$hdr_size}, must be 1000."
    )
  } # nocov end
  scalar_names <- utils::head(header$scalar_names, max(header$n_scalars, 0L))
  property_names <- utils::head(
    header$property_names,
    max(header$n_properties, 0L)
  )

  flat <- ReadTRK(
    inputFile = input_file,
    n_scalars = header$n_scalars,
    n_properties = header$n_properties,
    n_count = header$n_count,
    little_endian = (endian == "little"),
    scalar_names = scalar_names,
    property_names = property_names
  )

  A <- header$vox2ras[1:3, 1:3]
  b <- header$vox2ras[1:3, 4]
  if (sum((A - diag(rep(1, 3)))^2) != 0 || sum((b - rep(0, 3))^2) != 0) {
    cli::cli_alert_info(
      "Transforming voxel to real coordinates using rotation matrix {A} and translation vector {b}..."
    )
    coords <- A %*% rbind(flat$X, flat$Y, flat$Z) + b
    flat$X <- coords[1, ]
    flat$Y <- coords[2, ]
    flat$Z <- coords[3, ]
  }

  # Property names (per-streamline) to be stored in @streamline_data
  sl_cols <- utils::head(header$property_names, header$n_properties)
  sl_cols <- sl_cols[nchar(sl_cols) > 0L]

  flat_list_to_bundle(flat, streamline_cols = sl_cols)
}
