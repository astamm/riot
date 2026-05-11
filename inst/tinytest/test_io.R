library(riot)

vtk_file <- system.file("extdata", "UF_left.vtk", package = "riot")
vtp_file <- system.file("extdata", "UF_left.vtp", package = "riot")
fds_file <- system.file("extdata", "UF_left.fds", package = "riot")
tck_file <- system.file("extdata", "AF_left.tck", package = "riot")
trk_file <- system.file("extdata", "CCMid.trk", package = "riot")

# ---- read_bundle: supported formats ------------------------------------

tr_vtk <- read_bundle(vtk_file)
expect_true(is_bundle(tr_vtk))
expect_equal(
  sum(vapply(tr_vtk@streamlines, function(sl) nrow(sl@points), integer(1L))),
  38697L
)
expect_true(all(vapply(
  tr_vtk@streamlines,
  function(sl) ncol(sl@points) == 3L,
  logical(1L)
)))
expect_false(anyNA(do.call(
  rbind,
  lapply(tr_vtk@streamlines, function(sl) sl@points)
)))

tr_vtp <- read_bundle(vtp_file)
expect_true(is_bundle(tr_vtp))
expect_equal(
  sum(vapply(tr_vtp@streamlines, function(sl) nrow(sl@points), integer(1L))),
  38697L
)
expect_true(all(vapply(
  tr_vtp@streamlines,
  function(sl) ncol(sl@points) == 3L,
  logical(1L)
)))
expect_false(anyNA(do.call(
  rbind,
  lapply(tr_vtp@streamlines, function(sl) sl@points)
)))

tr_fds <- read_bundle(fds_file)
expect_true(is_bundle(tr_fds))
expect_equal(
  sum(vapply(tr_fds@streamlines, function(sl) nrow(sl@points), integer(1L))),
  38697L
)
expect_true(all(vapply(
  tr_fds@streamlines,
  function(sl) ncol(sl@points) == 3L,
  logical(1L)
)))
expect_false(anyNA(do.call(
  rbind,
  lapply(tr_fds@streamlines, function(sl) sl@points)
)))

tr_tck <- read_bundle(tck_file)
expect_true(is_bundle(tr_tck))
expect_equal(
  sum(vapply(tr_tck@streamlines, function(sl) nrow(sl@points), integer(1L))),
  140301L
)
expect_true(all(vapply(
  tr_tck@streamlines,
  function(sl) ncol(sl@points) == 3L,
  logical(1L)
)))
expect_false(anyNA(do.call(
  rbind,
  lapply(tr_tck@streamlines, function(sl) sl@points)
)))

tr_trk <- read_bundle(trk_file)
expect_true(is_bundle(tr_trk))
expect_equal(
  sum(vapply(tr_trk@streamlines, function(sl) nrow(sl@points), integer(1L))),
  112675L
)
expect_true(all(vapply(
  tr_trk@streamlines,
  function(sl) ncol(sl@points) == 3L,
  logical(1L)
)))
expect_false(anyNA(do.call(
  rbind,
  lapply(tr_trk@streamlines, function(sl) sl@points)
)))

# ---- read_bundle: error paths ------------------------------------------

# unsupported extension
expect_error(read_bundle(tempfile(fileext = ".csv")))

# dpy/trx/fib without a reference file
expect_error(read_bundle(tempfile(fileext = ".dpy")))
expect_error(read_bundle(tempfile(fileext = ".trx")))
expect_error(read_bundle(tempfile(fileext = ".fib")))

# ---- write_bundle: roundtrips ------------------------------------------

# VTK roundtrip
tf_vtk <- tempfile(fileext = ".vtk")
on.exit(unlink(tf_vtk), add = TRUE)
write_bundle(tr_vtk, tf_vtk)
tr_vtk2 <- read_bundle(tf_vtk)
expect_equal(
  sum(vapply(tr_vtk2@streamlines, function(sl) nrow(sl@points), integer(1L))),
  sum(vapply(tr_vtk@streamlines, function(sl) nrow(sl@points), integer(1L)))
)

# VTP roundtrip
tf_vtp <- tempfile(fileext = ".vtp")
on.exit(unlink(tf_vtp), add = TRUE)
write_bundle(tr_vtp, tf_vtp)
tr_vtp2 <- read_bundle(tf_vtp)
expect_equal(
  sum(vapply(tr_vtp2@streamlines, function(sl) nrow(sl@points), integer(1L))),
  sum(vapply(tr_vtp@streamlines, function(sl) nrow(sl@points), integer(1L)))
)

# FDS roundtrip
tf_fds <- tempfile(fileext = ".fds")
on.exit(unlink(tf_fds), add = TRUE)
write_bundle(tr_fds, tf_fds)
tr_fds2 <- read_bundle(tf_fds)
expect_equal(
  sum(vapply(tr_fds2@streamlines, function(sl) nrow(sl@points), integer(1L))),
  sum(vapply(tr_fds@streamlines, function(sl) nrow(sl@points), integer(1L)))
)

# ---- write_bundle: error paths -----------------------------------------

# input is not a bundle
sl_lone <- tr_vtk@streamlines[[1L]]
expect_error(write_bundle(sl_lone, tempfile(fileext = ".vtk")))

# unsupported output extension
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".csv")))

# dpy/trx/fib without a reference file
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".dpy")))
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".trx")))
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".fib")))
