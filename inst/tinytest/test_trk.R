library(riot)

# ---- TRK binary writer helper -----------------------------------------------

write_trk_file <- function(
  path,
  streamlines,
  endian = "little",
  n_scalars = 0L,
  scalar_names = character(0),
  n_properties = 0L,
  property_names = character(0),
  vox2ras = diag(4),
  version = 2L,
  n_count = NULL
) {
  if (is.null(n_count)) {
    n_count <- length(streamlines)
  }
  fh <- file(path, "wb")
  on.exit(close(fh))

  # id_string: "TRACK\0" (6 bytes)
  id_raw <- raw(6L)
  tc <- charToRaw("TRACK")
  id_raw[seq_along(tc)] <- tc
  writeBin(id_raw, fh)

  # dim (3 × int16 = 6 bytes)
  writeBin(as.integer(c(256L, 256L, 128L)), fh, size = 2L, endian = endian)

  # voxel_size (3 × float32 = 12 bytes)
  writeBin(as.double(c(1, 1, 1)), fh, size = 4L, endian = endian)

  # origin (3 × float32 = 12 bytes)
  writeBin(as.double(c(0, 0, 0)), fh, size = 4L, endian = endian)

  # n_scalars (int16 = 2 bytes)
  writeBin(as.integer(n_scalars), fh, size = 2L, endian = endian)

  # scalar_names (200 bytes, null-padded)
  sn <- raw(200L)
  if (length(scalar_names) > 0L) {
    sn_c <- charToRaw(paste(scalar_names, collapse = rawToChar(as.raw(0L))))
    n <- min(length(sn_c), 199L)
    sn[seq_len(n)] <- sn_c[seq_len(n)]
  }
  writeBin(sn, fh)

  # n_properties (int16 = 2 bytes)
  writeBin(as.integer(n_properties), fh, size = 2L, endian = endian)

  # property_names (200 bytes, null-padded)
  pn <- raw(200L)
  if (length(property_names) > 0L) {
    pn_c <- charToRaw(paste(property_names, collapse = rawToChar(as.raw(0L))))
    n <- min(length(pn_c), 199L)
    pn[seq_len(n)] <- pn_c[seq_len(n)]
  }
  writeBin(pn, fh)

  # vox2ras (16 × float32 = 64 bytes, row-major)
  writeBin(as.double(as.vector(t(vox2ras))), fh, size = 4L, endian = endian)

  # reserved (444 bytes)
  writeBin(raw(444L), fh)

  # voxel_order (4 bytes "LAS\0")
  vo <- raw(4L)
  vo_c <- charToRaw("LAS")
  vo[seq_along(vo_c)] <- vo_c
  writeBin(vo, fh)

  # pad2 (4 bytes)
  writeBin(raw(4L), fh)

  # image_orientation_patient (6 × float32 = 24 bytes)
  writeBin(as.double(c(1, 0, 0, 0, 1, 0)), fh, size = 4L, endian = endian)

  # pad1 (2 bytes)
  writeBin(raw(2L), fh)

  # invert_x .. swap_zx (6 × uint8 = 6 bytes as raw zeros)
  writeBin(raw(6L), fh)

  # n_count (int32 = 4 bytes)
  writeBin(as.integer(n_count), fh, size = 4L, endian = endian)

  # version (int32 = 4 bytes)
  writeBin(as.integer(version), fh, size = 4L, endian = endian)

  # hdr_size (int32 = 4 bytes) — always 1000 so retrieve_trk_endianness passes
  writeBin(1000L, fh, size = 4L, endian = endian)

  # Streamline data
  for (i in seq_along(streamlines)) {
    sl <- streamlines[[i]]
    n_pts <- nrow(sl)
    writeBin(as.integer(n_pts), fh, size = 4L, endian = endian)
    for (pt in seq_len(n_pts)) {
      writeBin(as.double(sl[pt, 1L]), fh, size = 4L, endian = endian)
      writeBin(as.double(sl[pt, 2L]), fh, size = 4L, endian = endian)
      writeBin(as.double(sl[pt, 3L]), fh, size = 4L, endian = endian)
      for (sc in seq_len(n_scalars)) {
        v <- if (ncol(sl) >= 3L + sc) sl[pt, 3L + sc] else 0.0
        writeBin(as.double(v), fh, size = 4L, endian = endian)
      }
    }
    for (pr in seq_len(n_properties)) {
      writeBin(as.double(1.0), fh, size = 4L, endian = endian)
    }
  }
}

# Minimal streamline for synthetic TRK tests
sl_mat <- matrix(
  c(1, 0, 0, 2, 0, 0, 3, 0, 0),
  ncol = 3,
  byrow = TRUE,
  dimnames = list(NULL, c("X", "Y", "Z"))
)

# ---- retrieve_trk_endianness: big-endian path --------------------------------

# Write a big-endian TRK file; hdr_size = big-endian 1000 at position 996
f_be <- tempfile(fileext = ".trk")
write_trk_file(f_be, list(sl_mat), endian = "big")
expect_equal(riot:::retrieve_trk_endianness(f_be), "big")
unlink(f_be)

# ---- retrieve_trk_endianness: abort (neither endian gives 1000) --------------

f_bad <- tempfile(fileext = ".trk")
con_bad <- file(f_bad, "wb")
writeBin(raw(1000L), con_bad)
close(con_bad)
expect_error(riot:::retrieve_trk_endianness(f_bad))
unlink(f_bad)

# ---- read_trk: version != 2 warning -----------------------------------------

f_v1 <- tempfile(fileext = ".trk")
write_trk_file(f_v1, list(sl_mat), version = 1L)
# Should succeed but issue a cli_alert_warning (not an error)
tr_v1 <- riot:::read_trk(f_v1)
expect_true(fiber::is_streamline(tr_v1))
unlink(f_v1)

# ---- read_trk: n_scalars > 0 ------------------------------------------------

sl_with_scalar <- cbind(sl_mat, FA = c(0.5, 0.6, 0.7))

f_sc <- tempfile(fileext = ".trk")
write_trk_file(f_sc, list(sl_with_scalar), n_scalars = 1L, scalar_names = "FA")
tr_sc <- riot:::read_trk(f_sc)
expect_true(fiber::is_streamline(tr_sc))
expect_true("FA" %in% names(tr_sc@point_data))
expect_equal(nrow(tr_sc@points), 3L)
unlink(f_sc)

# ---- read_trk: n_properties > 0 ---------------------------------------------

f_pr <- tempfile(fileext = ".trk")
write_trk_file(f_pr, list(sl_mat), n_properties = 1L, property_names = "length")
tr_pr <- riot:::read_trk(f_pr)
expect_true(fiber::is_streamline(tr_pr))
expect_true("length" %in% names(tr_pr@streamline_data))
unlink(f_pr)

# ---- read_trk: non-identity vox2ras → coordinate transformation applied -----

# Translation: voxel coords shifted by (10, 20, 30)
vox2ras_t <- diag(4)
vox2ras_t[1:3, 4] <- c(10, 20, 30)

f_vr <- tempfile(fileext = ".trk")
write_trk_file(f_vr, list(sl_mat), vox2ras = vox2ras_t)
tr_vr <- riot:::read_trk(f_vr)
expect_true(fiber::is_streamline(tr_vr))
# X coordinates should be shifted by 10, Y by 20, Z by 30
expect_equal(tr_vr@points[1L, "X"], sl_mat[1L, "X"] + 10, tolerance = 1e-4)
expect_equal(tr_vr@points[1L, "Y"], sl_mat[1L, "Y"] + 20, tolerance = 1e-4)
expect_equal(tr_vr@points[1L, "Z"], sl_mat[1L, "Z"] + 30, tolerance = 1e-4)
unlink(f_vr)
