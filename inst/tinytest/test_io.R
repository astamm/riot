library(riot)

vtk_file  <- system.file("extdata", "UF_left.vtk", package = "riot")
vtp_file  <- system.file("extdata", "UF_left.vtp", package = "riot")
fds_file  <- system.file("extdata", "UF_left.fds", package = "riot")
tck_file  <- system.file("extdata", "AF_left.tck", package = "riot")
trk_file  <- system.file("extdata", "CCMid.trk",   package = "riot")

# ---- read_tractogram: supported formats ------------------------------------

tr_vtk <- read_tractogram(vtk_file)
expect_inherits(tr_vtk, "bundle")
expect_equal(sum(vapply(tr_vtk, nrow, integer(1L))), 38697L)
expect_true(all(vapply(tr_vtk, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_vtk)))

tr_vtp <- read_tractogram(vtp_file)
expect_inherits(tr_vtp, "bundle")
expect_equal(sum(vapply(tr_vtp, nrow, integer(1L))), 38697L)
expect_true(all(vapply(tr_vtp, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_vtp)))

tr_fds <- read_tractogram(fds_file)
expect_inherits(tr_fds, "bundle")
expect_equal(sum(vapply(tr_fds, nrow, integer(1L))), 38697L)
expect_true(all(vapply(tr_fds, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_fds)))

tr_tck <- read_tractogram(tck_file)
expect_inherits(tr_tck, "bundle")
expect_equal(sum(vapply(tr_tck, nrow, integer(1L))), 140301L)
expect_true(all(vapply(tr_tck, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_tck)))

tr_trk <- read_tractogram(trk_file)
expect_inherits(tr_trk, "bundle")
expect_equal(sum(vapply(tr_trk, nrow, integer(1L))), 112675L)
expect_true(all(vapply(tr_trk, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_trk)))

# ---- read_tractogram: error paths ------------------------------------------

# unsupported extension
expect_error(read_tractogram(tempfile(fileext = ".csv")))

# dpy/trx/fib without a reference file
expect_error(read_tractogram(tempfile(fileext = ".dpy")))
expect_error(read_tractogram(tempfile(fileext = ".trx")))
expect_error(read_tractogram(tempfile(fileext = ".fib")))

# ---- write_tractogram: roundtrips ------------------------------------------

# VTK roundtrip
tf_vtk <- tempfile(fileext = ".vtk")
on.exit(unlink(tf_vtk), add = TRUE)
write_tractogram(tr_vtk, tf_vtk)
tr_vtk2 <- read_tractogram(tf_vtk)
expect_equal(tr_vtk2, tr_vtk)

# VTP roundtrip
tf_vtp <- tempfile(fileext = ".vtp")
on.exit(unlink(tf_vtp), add = TRUE)
write_tractogram(tr_vtp, tf_vtp)
tr_vtp2 <- read_tractogram(tf_vtp)
expect_equal(tr_vtp2, tr_vtp)

# FDS roundtrip
tf_fds <- tempfile(fileext = ".fds")
on.exit(unlink(tf_fds), add = TRUE)
write_tractogram(tr_fds, tf_fds)
tr_fds2 <- read_tractogram(tf_fds)
expect_equal(tr_fds2, tr_fds)

# ---- write_tractogram: error paths -----------------------------------------

# input is not a bundle
sl_lone <- tr_vtk[[1L]]
expect_error(write_tractogram(sl_lone, tempfile(fileext = ".vtk")))

# unsupported output extension
expect_error(write_tractogram(tr_vtk, tempfile(fileext = ".csv")))

# dpy/trx/fib without a reference file
expect_error(write_tractogram(tr_vtk, tempfile(fileext = ".dpy")))
expect_error(write_tractogram(tr_vtk, tempfile(fileext = ".trx")))
expect_error(write_tractogram(tr_vtk, tempfile(fileext = ".fib")))
