library(riot)

vtk_file <- system.file("extdata", "UF_left.vtk", package = "riot")
vtp_file <- system.file("extdata", "UF_left.vtp", package = "riot")
fds_file <- system.file("extdata", "UF_left.fds", package = "riot")
tck_file <- system.file("extdata", "AF_left.tck", package = "riot")
trk_file <- system.file("extdata", "CCMid.trk", package = "riot")

# ---- read_bundle: supported formats ------------------------------------

tr_vtk <- read_bundle(vtk_file)
expect_inherits(tr_vtk, "bundle")
expect_equal(sum(vapply(tr_vtk, nrow, integer(1L))), 38697L)
expect_true(all(vapply(tr_vtk, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_vtk)))

tr_vtp <- read_bundle(vtp_file)
expect_inherits(tr_vtp, "bundle")
expect_equal(sum(vapply(tr_vtp, nrow, integer(1L))), 38697L)
expect_true(all(vapply(tr_vtp, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_vtp)))

tr_fds <- read_bundle(fds_file)
expect_inherits(tr_fds, "bundle")
expect_equal(sum(vapply(tr_fds, nrow, integer(1L))), 38697L)
expect_true(all(vapply(tr_fds, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_fds)))

tr_tck <- read_bundle(tck_file)
expect_inherits(tr_tck, "bundle")
expect_equal(sum(vapply(tr_tck, nrow, integer(1L))), 140301L)
expect_true(all(vapply(tr_tck, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_tck)))

tr_trk <- read_bundle(trk_file)
expect_inherits(tr_trk, "bundle")
expect_equal(sum(vapply(tr_trk, nrow, integer(1L))), 112675L)
expect_true(all(vapply(tr_trk, function(sl) ncol(sl) == 3L, logical(1L))))
expect_false(anyNA(do.call(rbind, tr_trk)))

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
expect_equal(tr_vtk2, tr_vtk)

# VTP roundtrip
tf_vtp <- tempfile(fileext = ".vtp")
on.exit(unlink(tf_vtp), add = TRUE)
write_bundle(tr_vtp, tf_vtp)
tr_vtp2 <- read_bundle(tf_vtp)
expect_equal(tr_vtp2, tr_vtp)

# FDS roundtrip
tf_fds <- tempfile(fileext = ".fds")
on.exit(unlink(tf_fds), add = TRUE)
write_bundle(tr_fds, tf_fds)
tr_fds2 <- read_bundle(tf_fds)
expect_equal(tr_fds2, tr_fds)

# ---- write_bundle: error paths -----------------------------------------

# input is not a bundle
sl_lone <- tr_vtk[[1L]]
expect_error(write_bundle(sl_lone, tempfile(fileext = ".vtk")))

# unsupported output extension
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".csv")))

# dpy/trx/fib without a reference file
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".dpy")))
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".trx")))
expect_error(write_bundle(tr_vtk, tempfile(fileext = ".fib")))
