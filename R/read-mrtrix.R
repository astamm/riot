read_header <- function(file_path) {
  header <- list()
  all_lines <- suppressWarnings(readLines(file_path))
  ext <- fs::path_ext(file_path)
  if (length(all_lines) < 4L) {
    if (ext == "tck")
      cli::cli_abort("File {.file {file_path}} is not in TCK format: too few lines.")
    else {
      cli::cli_alert_warning("File {.file {file_path}} is not in TSF format: too few lines. Skipping file...")
      return(header)
    }
  }
  header$id <- all_lines[1]
  if (ext == "tck" && header$id != "mrtrix tracks")
    cli::cli_abort("File {.file {file_path}} is not in TCK format: invalid first line.")
  if (ext == "tsf" && header$id != "mrtrix track scalars") {
    cli::cli_alert_warning("File {.file {file_path}} is not in TSF format: invalid first line. Skipping file...")
    return(header)
  }
  for (line_idx in 2L:length(all_lines)) {
    current_line <- all_lines[line_idx]
    if (current_line == "END")
      break
    else {
      line_parts <- unlist(strsplit(current_line, ":"))
      lkey <- trimws(line_parts[1])
      lvalue <- trimws(line_parts[2])
      header[[lkey]] <- lvalue
      if (lkey == "file") {
        file_parts <- unlist(strsplit(lvalue, " "))
        header$derived$filename_part <- trimws(file_parts[1])
        if (header$derived$filename_part != ".")
          cli::cli_abort("Multi-file TCK/TSF files are not supported.")
        header$derived$data_offset <- as.integer(trimws(file_parts[2]))
      }
    }
  }
  all_lines <- NULL
  valid_datatypes <- c("Float32BE", "Float32LE", "Float64BE", "Float64LE")
  if (!header$datatype %in% valid_datatypes)
    cli::cli_abort("Invalid datatype in TCK/TSF file header")
  if (is.null(header$derived$data_offset))
    cli::cli_abort("Invalid TCK file, missing file offset header entry.")
  header$derived$endian <- "little"
  if (endsWith(header$datatype, "BE"))
    header$derived$endian <- "big"
  header$derived$dsize <- 4L
  if (startsWith(header$datatype, "Float64"))
    header$derived$dsize <- 8L
  header
}

read_tck <- function(file_path) {
  tck <- list()
  tck$header <- read_header(file_path)
  fs <- file.size(file_path)
  num_to_read <- (fs - tck$header$derived$data_offset) / tck$header$derived$dsize
  fh <- file(file_path, "rb")
  on.exit({
    close(fh)
  }, add = TRUE)
  seek(fh, where = tck$header$derived$data_offset)
  tracks_rawdata <- readBin(
    con = fh,
    what = numeric(),
    n = num_to_read,
    size = tck$header$derived$dsize,
    endian = tck$header$derived$endian
  )
  tracks_raw_matrix <- matrix(tracks_rawdata, ncol = 3, byrow = TRUE)
  tracks_raw_matrix <- tracks_raw_matrix[-nrow(tracks_raw_matrix), ]
  tck$tracks <- tibble::tibble(
    X = tracks_raw_matrix[, 1],
    Y = tracks_raw_matrix[, 2],
    Z = tracks_raw_matrix[, 3]
  )
  n <- nrow(tck$tracks)
  tck$tracks$PointId <- seq_len(n)
  tck$tracks$StreamlineId <- rep(1, n)
  nan_idx <- which(is.nan(tck$tracks$X))
  for (i in 1:length(nan_idx)) {
    idx <- nan_idx[i]
    tck$tracks$PointId[idx:n] <- 0:(n-idx)
    tck$tracks$StreamlineId[idx:n] <- i + 1
  }
  tck$tracks <- tck$tracks[tck$tracks$PointId != 0, ]
  tck
}

read_tsf <- function(file_path) {
  tsf <- list()
  tsf$header <- read_header(file_path)
  fs <- file.size(file_path)
  num_to_read <- (fs - tsf$header$derived$data_offset) / tsf$header$derived$dsize
  fh <- file(file_path, "rb")
  on.exit({
    close(fh)
  }, add = TRUE)
  seek(fh, where = tsf$header$derived$data_offset)
  scalar_rawdata <- readBin(
    con = fh,
    what = numeric(),
    n = num_to_read,
    size = tsf$header$derived$dsize,
    endian = tsf$header$derived$endian
  )
  data_indices <- which(!(is.nan(scalar_rawdata) | is.infinite(scalar_rawdata)))
  tsf$scalars$merged <- scalar_rawdata[data_indices]
  tsf$scalars$scalar_list <- list()
  current_track_idx <- 1L
  for (value_idx in 1L:length(scalar_rawdata)) {
    current_value <- scalar_rawdata[value_idx]
    if (is.nan(current_value) | is.infinite(current_value)) {
      current_track_idx<- current_track_idx + 1L
      next
    }
    else {
      if (length(tsf$scalars$scalar_list) < current_track_idx)
        tsf$scalars$scalar_list[[current_track_idx]] <- current_value
      else
        tsf$scalars$scalar_list[[current_track_idx]] <- c(
          tsf$scalars$scalar_list[[current_track_idx]],
          current_value
        )
    }
  }
  tsf
}

read_mrtrix <- function(input_file) {
  tck_data <- read_tck(input_file)
  df <- tck_data$tracks
  tsf_files <- fs::dir_ls(fs::path_dir(input_file), glob = "*.tsf")
  for (tsf_file in tsf_files)  {
    tsf_data <- read_tsf(tsf_file)
    if (is.null(tck_data$header$timestamp) || is.null(tsf_data$header$timestamp))
      cli::cli_alert_warning("The field {.field timestamp} is missing from either the TCK or the TSF file. Cannot verify file compatibility using time stamps.")
    else {
      if (tck_data$header$timestamp != tsf_data$header$timestamp) {
        cli::cli_alert_info("Skipping file {.file {tsf_file}} because time stamps do not match.")
        next
      }
    }
    if (is.null(tck_data$header$count) || is.null(tsf_data$header$count))
      cli::cli_alert_warning("The field {.field count} is missing from either the TCK or the TSF file. Cannot verify file compatibility using streamline counts.")
    else {
      if (tck_data$header$count != tsf_data$header$count) {
        cli::cli_alert_info("Skipping file {.file {tsf_file}} because streamline counts do not match.")
        next
      }
    }
    if (nrow(tck_data$tracks) != nrow(tsf_data$tracks)) {
      cli::cli_alert_info("Skipping file {.file {tsf_file}} because point counts do not match.")
      next
    }
    df <- tibble::tibble(merge(df, tsf_data$scalars))
  }
  df
}
