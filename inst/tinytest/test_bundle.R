library(riot)

# ---- new_streamline ---------------------------------------------------------

# valid matrix
pts <- matrix(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  ncol = 3,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl <- new_streamline(pts)
expect_true(is_streamline(sl))
expect_true(is.matrix(sl@points))

# not a matrix -> error
expect_error(new_streamline("not a matrix"))

# no colnames -> error
expect_error(new_streamline(matrix(1:9, ncol = 3)))

# missing required column names -> error
bad <- matrix(1:9, ncol = 3, dimnames = list(NULL, c("A", "B", "C")))
expect_error(new_streamline(bad))

# point_data length mismatch -> error
expect_error(new_streamline(pts, point_data = list(FA = c(0.1, 0.2))))

# streamline_data non-scalar -> error
expect_error(new_streamline(pts, streamline_data = list(weight = c(1, 2))))

# ---- with point_data and streamline_data ------------------------------------

sl_pd  <- new_streamline(pts, point_data = list(FA = c(0.1, 0.2, 0.3)))
sl_sld <- new_streamline(pts, streamline_data = list(weight = 0.5))
sl_all <- new_streamline(
  pts,
  point_data      = list(FA = c(0.1, 0.2, 0.3)),
  streamline_data = list(weight = 0.5)
)

expect_true(is_streamline(sl_pd))
expect_equal(sl_pd@point_data[["FA"]], c(0.1, 0.2, 0.3))
expect_equal(sl_sld@streamline_data[["weight"]], 0.5)
expect_equal(names(sl_all@point_data), "FA")
expect_equal(names(sl_all@streamline_data), "weight")

# ---- is_streamline ----------------------------------------------------------

expect_true(is_streamline(sl))
expect_false(is_streamline(pts))
expect_false(is_streamline(list()))

# ---- format.streamline ------------------------------------------------------

f <- format(sl)
expect_true(grepl("streamline", f))
expect_true(grepl("3 pts", f))

f_pd <- format(sl_pd)
expect_true(grepl("point: FA", f_pd))

f_all <- format(sl_all)
expect_true(grepl("point: FA", f_all))
expect_true(grepl("streamline: weight", f_all))

# ---- print.streamline -------------------------------------------------------

expect_stdout(print(sl), "streamline")

# ---- new_bundle -------------------------------------------------------------

b <- new_bundle(list(sl, sl_pd))
expect_true(is_bundle(b))

# non-list -> error
expect_error(new_bundle(sl))

# list with non-streamline element -> error
expect_error(new_bundle(list(sl, "not a streamline")))

# empty list is allowed (zero-streamline bundle)
b0 <- new_bundle(list())
expect_true(is_bundle(b0))

# bundle_data is stored
b_meta <- new_bundle(list(sl), bundle_data = list(origin = "phantom"))
expect_equal(b_meta@bundle_data[["origin"]], "phantom")

# ---- is_bundle --------------------------------------------------------------

expect_true(is_bundle(b))
expect_false(is_bundle(sl))
expect_false(is_bundle(list(sl)))

# ---- format.bundle ----------------------------------------------------------

f0 <- format(b0)
expect_true(grepl("0 streamlines", f0))

b_plain <- new_bundle(list(sl, sl))
fp <- format(b_plain)
expect_true(grepl("streamlines", fp))

b_pd <- new_bundle(list(sl_pd, sl_pd))
fp_pd <- format(b_pd)
expect_true(grepl("point: FA", fp_pd))

b_all <- new_bundle(list(sl_all, sl_all))
fp_all <- format(b_all)
expect_true(grepl("point: FA", fp_all))
expect_true(grepl("streamline: weight", fp_all))

# ---- print.bundle -----------------------------------------------------------

expect_stdout(print(b_plain), "streamlines")

# ---- length.bundle ----------------------------------------------------------

expect_equal(length(b), 2L)
expect_equal(length(b0), 0L)

# ---- indexing ---------------------------------------------------------------

expect_true(is_streamline(b@streamlines[[1L]]))

# ---- flat_list_to_bundle ----------------------------------------------------

lst_multi <- list(
  X            = c(0, 1, 2, 3, 4),
  Y            = c(0, 0, 0, 0, 0),
  Z            = c(0, 0, 0, 0, 0),
  PointId      = c(1, 2, 1, 2, 3),
  StreamlineId = c(1, 1, 2, 2, 2)
)
result_multi <- riot:::flat_list_to_bundle(lst_multi)
expect_true(is_bundle(result_multi))
expect_equal(length(result_multi), 2L)
expect_equal(nrow(result_multi@streamlines[[1L]]@points), 2L)
expect_equal(nrow(result_multi@streamlines[[2L]]@points), 3L)

lst_single <- list(
  X            = c(0, 1, 2),
  Y            = c(0, 0, 0),
  Z            = c(0, 0, 0),
  PointId      = c(1, 2, 3),
  StreamlineId = c(1, 1, 1)
)
result_single <- riot:::flat_list_to_bundle(lst_single)
expect_true(is_streamline(result_single))
expect_equal(nrow(result_single@points), 3L)

lst_pd <- list(
  X            = c(0, 1, 2, 3),
  Y            = c(0, 0, 0, 0),
  Z            = c(0, 0, 0, 0),
  PointId      = c(1, 2, 1, 2),
  StreamlineId = c(1, 1, 2, 2),
  FA           = c(0.5, 0.6, 0.7, 0.8)
)
result_pd <- riot:::flat_list_to_bundle(lst_pd)
expect_true(is_bundle(result_pd))
expect_true("FA" %in% names(result_pd@streamlines[[1L]]@point_data))

lst_sld <- list(
  X            = c(0, 1, 2, 3),
  Y            = c(0, 0, 0, 0),
  Z            = c(0, 0, 0, 0),
  PointId      = c(1, 2, 1, 2),
  StreamlineId = c(1, 1, 2, 2),
  weight       = c(0.9, 0.9, 0.4, 0.4)
)
result_sld <- riot:::flat_list_to_bundle(lst_sld, streamline_cols = "weight")
expect_true(is_bundle(result_sld))
expect_equal(result_sld@streamlines[[1L]]@streamline_data[["weight"]], 0.9)
expect_equal(result_sld@streamlines[[2L]]@streamline_data[["weight"]], 0.4)
expect_false("weight" %in% names(result_sld@streamlines[[1L]]@point_data))

# ---- bundle_to_flat_list ----------------------------------------------------

flat <- riot:::bundle_to_flat_list(b_plain)
expect_equal(
  sort(names(flat)),
  sort(c("X", "Y", "Z", "PointId", "StreamlineId"))
)
expect_equal(length(unique(flat$StreamlineId)), 2L)

flat_single <- riot:::bundle_to_flat_list(sl)
expect_equal(unique(flat_single$StreamlineId), 1L)
expect_equal(nrow(sl@points), length(flat_single$X))

b_pd_rt <- new_bundle(list(sl_pd, sl_pd))
flat_pd  <- riot:::bundle_to_flat_list(b_pd_rt)
expect_true("FA" %in% names(flat_pd))
expect_equal(length(flat_pd$FA), 2L * nrow(sl_pd@points))

b_sld_rt <- new_bundle(list(sl_sld, sl_sld))
flat_sld  <- riot:::bundle_to_flat_list(b_sld_rt)
expect_true("weight" %in% names(flat_sld))
grp1 <- flat_sld$weight[flat_sld$StreamlineId == 1L]
expect_true(all(grp1 == grp1[1L]))
