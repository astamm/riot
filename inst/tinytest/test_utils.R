library(riot)

# ---- supported_formats / write_formats / read_formats -----------------------

fmts <- supported_formats()
expect_true(is.character(fmts))
expect_true(length(fmts) > 0L)
expect_true("vtk" %in% fmts)
expect_true("vtp" %in% fmts)
expect_true("fds" %in% fmts)
expect_true("tck" %in% fmts)
expect_true("trk" %in% fmts)
