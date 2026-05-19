library(riot)

# valid matrix
pts <- matrix(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  ncol = 3,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
sl <- fiber::streamline(pts)
sl_pd <- fiber::streamline(pts, point_data = list(FA = c(0.1, 0.2, 0.3)))
sl_sld <- fiber::streamline(pts, streamline_data = list(weight = 0.5))
b_plain <- fiber::bundle(list(sl, sl))

# ---- flat_list_to_bundle ----------------------------------------------------

lst_multi <- list(
  X = c(0, 1, 2, 3, 4),
  Y = c(0, 0, 0, 0, 0),
  Z = c(0, 0, 0, 0, 0),
  PointId = c(1, 2, 1, 2, 3),
  StreamlineId = c(1, 1, 2, 2, 2)
)
result_multi <- riot:::flat_list_to_bundle(lst_multi)
expect_true(fiber::is_bundle(result_multi))
expect_equal(length(result_multi), 2L)
expect_equal(nrow(result_multi@streamlines[[1L]]@points), 2L)
expect_equal(nrow(result_multi@streamlines[[2L]]@points), 3L)

lst_single <- list(
  X = c(0, 1, 2),
  Y = c(0, 0, 0),
  Z = c(0, 0, 0),
  PointId = c(1, 2, 3),
  StreamlineId = c(1, 1, 1)
)
result_single <- riot:::flat_list_to_bundle(lst_single)
expect_true(fiber::is_streamline(result_single))
expect_equal(nrow(result_single@points), 3L)

lst_pd <- list(
  X = c(0, 1, 2, 3),
  Y = c(0, 0, 0, 0),
  Z = c(0, 0, 0, 0),
  PointId = c(1, 2, 1, 2),
  StreamlineId = c(1, 1, 2, 2),
  FA = c(0.5, 0.6, 0.7, 0.8)
)
result_pd <- riot:::flat_list_to_bundle(lst_pd)
expect_true(fiber::is_bundle(result_pd))
expect_true("FA" %in% names(result_pd@streamlines[[1L]]@point_data))

lst_sld <- list(
  X = c(0, 1, 2, 3),
  Y = c(0, 0, 0, 0),
  Z = c(0, 0, 0, 0),
  PointId = c(1, 2, 1, 2),
  StreamlineId = c(1, 1, 2, 2),
  weight = c(0.9, 0.9, 0.4, 0.4)
)
result_sld <- riot:::flat_list_to_bundle(lst_sld, streamline_cols = "weight")
expect_true(fiber::is_bundle(result_sld))
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

b_pd_rt <- fiber::bundle(list(sl_pd, sl_pd))
flat_pd <- riot:::bundle_to_flat_list(b_pd_rt)
expect_true("FA" %in% names(flat_pd))
expect_equal(length(flat_pd$FA), 2L * nrow(sl_pd@points))

b_sld_rt <- fiber::bundle(list(sl_sld, sl_sld))
flat_sld <- riot:::bundle_to_flat_list(b_sld_rt)
expect_true("weight" %in% names(flat_sld))
grp1 <- flat_sld$weight[flat_sld$StreamlineId == 1L]
expect_true(all(grp1 == grp1[1L]))
