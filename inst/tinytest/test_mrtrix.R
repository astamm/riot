library(riot)

# ---- helpers ----------------------------------------------------------------

# Build a text header with a correct "file: . OFFSET" line.
# Returns list(text = character(1), offset = integer(1)).
make_header_text <- function(lines) {
  pre <- paste(paste0(lines, "\n"), collapse = "")
  pre_bytes <- nchar(pre, type = "bytes")
  # offset = pre_bytes + nchar("file: . X\nEND\n") = pre_bytes + 13 + ndigits(X)
  for (d in 1:10) {
    candidate <- pre_bytes + 13L + d
    if (nchar(as.character(candidate)) == d) {
      file_end <- paste0("file: . ", candidate, "\nEND\n")
      return(list(text = paste0(pre, file_end), offset = candidate))
    }
  }
  stop("could not find stable offset")
}

# Write a minimal valid TCK binary file.
make_tck_file <- function(
  path,
  streamlines,
  datatype = "Float32LE",
  timestamp = NULL,
  count = NULL
) {
  endian <- if (endsWith(datatype, "LE")) "little" else "big"
  dsize <- if (startsWith(datatype, "Float64")) 8L else 4L

  # Binary payload: XYZ triples per point, NaN separator, Inf terminator
  payload <- raw(0)
  for (sl in streamlines) {
    for (i in seq_len(nrow(sl))) {
      for (j in 1:3) {
        payload <- c(
          payload,
          writeBin(as.double(sl[i, j]), raw(), size = dsize, endian = endian)
        )
      }
    }
    for (j in 1:3) {
      payload <- c(payload, writeBin(NaN, raw(), size = dsize, endian = endian))
    }
  }
  for (j in 1:3) {
    payload <- c(payload, writeBin(Inf, raw(), size = dsize, endian = endian))
  }

  hdr_lines <- c("mrtrix tracks", paste0("datatype: ", datatype))
  if (!is.null(count)) {
    hdr_lines <- c(hdr_lines, paste0("count: ", count))
  }
  if (!is.null(timestamp)) {
    hdr_lines <- c(hdr_lines, paste0("timestamp: ", timestamp))
  }
  h <- make_header_text(hdr_lines)

  fh <- file(path, "wb")
  writeBin(charToRaw(h$text), fh)
  writeBin(payload, fh)
  close(fh)
}

# Write a minimal valid TSF binary file.
make_tsf_file <- function(
  path,
  scalars_list,
  datatype = "Float32LE",
  timestamp = NULL,
  count = NULL
) {
  endian <- if (endsWith(datatype, "LE")) "little" else "big"
  dsize <- if (startsWith(datatype, "Float64")) 8L else 4L

  payload <- raw(0)
  for (sc in scalars_list) {
    for (v in sc) {
      payload <- c(
        payload,
        writeBin(as.double(v), raw(), size = dsize, endian = endian)
      )
    }
    payload <- c(payload, writeBin(NaN, raw(), size = dsize, endian = endian))
  }
  payload <- c(payload, writeBin(Inf, raw(), size = dsize, endian = endian))

  hdr_lines <- c("mrtrix track scalars", paste0("datatype: ", datatype))
  if (!is.null(count)) {
    hdr_lines <- c(hdr_lines, paste0("count: ", count))
  }
  if (!is.null(timestamp)) {
    hdr_lines <- c(hdr_lines, paste0("timestamp: ", timestamp))
  }
  h <- make_header_text(hdr_lines)

  fh <- file(path, "wb")
  writeBin(charToRaw(h$text), fh)
  writeBin(payload, fh)
  close(fh)
}

# ---- read_header: too-few-lines branches ------------------------------------

# TCK with < 4 lines → error
f <- tempfile(fileext = ".tck")
writeLines(c("mrtrix tracks", "datatype: Float32LE"), f)
expect_error(riot:::read_header(f))
unlink(f)

# TSF with < 4 lines → warning + return empty list (no error)
f <- tempfile(fileext = ".tsf")
writeLines(c("mrtrix track scalars", "datatype: Float32LE"), f)
h <- riot:::read_header(f)
expect_true(is.list(h))
expect_equal(length(h), 0L)
unlink(f)

# ---- read_header: invalid first-line branches -------------------------------

# TCK wrong magic → error
f <- tempfile(fileext = ".tck")
writeLines(
  c("wrong magic", "datatype: Float32LE", "count: 1", "file: . 0", "END"),
  f
)
expect_error(riot:::read_header(f))
unlink(f)

# TSF wrong magic → warning + return list with just id field set
f <- tempfile(fileext = ".tsf")
writeLines(
  c("wrong magic", "datatype: Float32LE", "count: 1", "file: . 0", "END"),
  f
)
h <- riot:::read_header(f)
expect_true(is.list(h))
expect_equal(length(h), 1L) # only h$id is set before the early return
unlink(f)

# ---- read_header: multi-file → error ----------------------------------------

f <- tempfile(fileext = ".tck")
writeLines(
  c(
    "mrtrix tracks",
    "datatype: Float32LE",
    "count: 1",
    "file: external.tck 1024",
    "END"
  ),
  f
)
expect_error(riot:::read_header(f))
unlink(f)

# ---- read_header: invalid datatype → error ----------------------------------

f <- tempfile(fileext = ".tck")
writeLines(
  c("mrtrix tracks", "datatype: Int32LE", "count: 1", "file: . 0", "END"),
  f
)
expect_error(riot:::read_header(f))
unlink(f)

# ---- read_header: missing file offset → error --------------------------------

f <- tempfile(fileext = ".tck")
writeLines(c("mrtrix tracks", "datatype: Float32LE", "count: 1", "END"), f)
expect_error(riot:::read_header(f))
unlink(f)

# ---- read_header: Float32BE → big-endian path --------------------------------

f <- tempfile(fileext = ".tck")
h_info <- make_header_text(c(
  "mrtrix tracks",
  "datatype: Float32BE",
  "count: 1"
))
fh <- file(f, "wb")
writeBin(charToRaw(h_info$text), fh)
close(fh)
h <- riot:::read_header(f)
expect_equal(h$derived$endian, "big")
expect_equal(h$derived$dsize, 4L)
unlink(f)

# ---- read_header: Float64LE → 8-byte float path -----------------------------

f <- tempfile(fileext = ".tck")
h_info <- make_header_text(c(
  "mrtrix tracks",
  "datatype: Float64LE",
  "count: 1"
))
fh <- file(f, "wb")
writeBin(charToRaw(h_info$text), fh)
close(fh)
h <- riot:::read_header(f)
expect_equal(h$derived$endian, "little")
expect_equal(h$derived$dsize, 8L)
unlink(f)

# ---- read_tsf: synthetic TSF file -------------------------------------------

pts <- list(c(0.1, 0.2, 0.3), c(0.4, 0.5)) # 2 streamlines, 3 and 2 scalars
tsf_f <- tempfile(fileext = ".tsf")
make_tsf_file(tsf_f, pts, timestamp = "99999", count = "2")
tsf <- riot:::read_tsf(tsf_f)
expect_true(is.list(tsf))
expect_equal(length(tsf$scalars$merged), 5L)
expect_equal(length(tsf$scalars$scalar_list), 2L)
expect_equal(length(tsf$scalars$scalar_list[[1L]]), 3L)
expect_equal(length(tsf$scalars$scalar_list[[2L]]), 2L)
unlink(tsf_f)

# ---- read_mrtrix: TSF timestamp mismatch → skip -----------------------------

td <- tempdir()
tck_f <- file.path(td, "test_ts.tck")
tsf_f <- file.path(td, "test_ts.tsf")

sl1 <- matrix(
  c(1, 0, 0, 2, 0, 0, 3, 0, 0),
  ncol = 3,
  byrow = TRUE,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl2 <- matrix(
  c(4, 0, 0, 5, 0, 0),
  ncol = 3,
  byrow = TRUE,
  dimnames = list(NULL, c("X", "Y", "Z"))
)

make_tck_file(tck_f, list(sl1, sl2), timestamp = "111", count = "2")
make_tsf_file(
  tsf_f,
  list(c(0.1, 0.2, 0.3), c(0.4, 0.5)),
  timestamp = "999",
  count = "2"
)

tr <- riot:::read_mrtrix(tck_f)
# TSF should be skipped (timestamp mismatch), no scalar columns
expect_equal(ncol(tr[[1L]]), 3L)
unlink(c(tck_f, tsf_f))

# ---- read_mrtrix: TSF count mismatch → skip ---------------------------------

td <- tempdir()
tck_f <- file.path(td, "test_cnt.tck")
tsf_f <- file.path(td, "test_cnt.tsf")

make_tck_file(tck_f, list(sl1, sl2), timestamp = "222", count = "2")
make_tsf_file(
  tsf_f,
  list(c(0.1, 0.2, 0.3), c(0.4, 0.5)),
  timestamp = "222",
  count = "99"
)

tr <- riot:::read_mrtrix(tck_f)
expect_equal(ncol(tr[[1L]]), 3L)
unlink(c(tck_f, tsf_f))

# ---- read_mrtrix: TSF point-count mismatch → skip ---------------------------

td <- tempdir()
tck_f <- file.path(td, "test_pts.tck")
tsf_f <- file.path(td, "test_pts.tsf")

make_tck_file(tck_f, list(sl1, sl2), timestamp = "333", count = "2")
# TSF has wrong number of scalars (should be 5 = 3+2 points total)
make_tsf_file(tsf_f, list(c(0.1)), timestamp = "333", count = "2")

tr <- riot:::read_mrtrix(tck_f)
expect_equal(ncol(tr[[1L]]), 3L)
unlink(c(tck_f, tsf_f))

# ---- read_mrtrix: missing timestamps → warning + continue to count check ----

td <- tempdir()
tck_f <- file.path(td, "test_nots.tck")
tsf_f <- file.path(td, "test_nots.tsf")

# No timestamp in either → warning issued but code continues; count also
# missing → second warning; point counts match → scalar appended
make_tck_file(tck_f, list(sl1, sl2)) # no timestamp, no count
make_tsf_file(tsf_f, list(c(0.1, 0.2, 0.3), c(0.4, 0.5))) # no timestamp, no count

tr <- riot:::read_mrtrix(tck_f)
# Point counts match (5 scalars for 5 points) → scalar column appended
expect_equal(ncol(tr[[1L]]), 4L) # X,Y,Z + test_nots scalar
unlink(c(tck_f, tsf_f))

# ---- read_mrtrix: valid TSF match -------------------------------------------

td <- tempdir()
tck_f <- file.path(td, "test_ok.tck")
tsf_f <- file.path(td, "test_ok.tsf")

make_tck_file(tck_f, list(sl1, sl2), timestamp = "555", count = "2")
make_tsf_file(
  tsf_f,
  list(c(0.1, 0.2, 0.3), c(0.4, 0.5)),
  timestamp = "555",
  count = "2"
)

tr <- riot:::read_mrtrix(tck_f)
# Scalar column should be appended
expect_equal(ncol(tr[[1L]]), 4L)
expect_true("test_ok" %in% colnames(tr[[1L]]))
unlink(c(tck_f, tsf_f))
