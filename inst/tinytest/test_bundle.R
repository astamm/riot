library(riot)

# ---- new_streamline ---------------------------------------------------------

# valid matrix
mat <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), ncol = 3,
              dimnames = list(NULL, c("X", "Y", "Z")))
sl <- new_streamline(mat)
expect_inherits(sl, "streamline")
expect_true(is.matrix(sl))

# not a matrix → error
expect_error(new_streamline("not a matrix"))

# numeric vector (not matrix) → error
expect_error(new_streamline(c(1, 2, 3)))

# missing required column names → error
bad <- matrix(1:9, ncol = 3, dimnames = list(NULL, c("A", "B", "C")))
expect_error(new_streamline(bad))

# no colnames at all → error
expect_error(new_streamline(matrix(1:9, ncol = 3)))

# ---- is_streamline ----------------------------------------------------------

expect_true(is_streamline(sl))
expect_false(is_streamline(mat))        # plain matrix, no class
expect_false(is_streamline(list()))

# ---- format.streamline ------------------------------------------------------

# without extra columns
f <- format(sl)
expect_true(grepl("streamline", f))
expect_true(grepl("3 points", f))

# with extra columns
mat2 <- cbind(mat, FA = c(0.1, 0.2, 0.3))
sl2 <- new_streamline(mat2)
f2 <- format(sl2)
expect_true(grepl("attributes: FA", f2))

# ---- print.streamline -------------------------------------------------------

expect_stdout(print(sl), "streamline")

# ---- new_bundle -------------------------------------------------------------

b <- new_bundle(list(sl, sl2))
expect_inherits(b, "bundle")
expect_true(is.list(b))

# non-list → error
expect_error(new_bundle(sl))

# list with non-streamline element → error
expect_error(new_bundle(list(sl, "not a streamline")))

# empty list is allowed (zero-streamline bundle)
b0 <- new_bundle(list())
expect_inherits(b0, "bundle")

# ---- is_bundle --------------------------------------------------------------

expect_true(is_bundle(b))
expect_false(is_bundle(sl))
expect_false(is_bundle(list(sl)))     # plain list, not bundle

# ---- format.bundle ----------------------------------------------------------

# empty bundle
f0 <- format(b0)
expect_true(grepl("0 streamlines", f0))

# non-empty bundle, no extra columns
b_plain <- new_bundle(list(sl, sl))
fp <- format(b_plain)
expect_true(grepl("streamlines", fp))

# non-empty bundle with extra columns (both streamlines must carry the column
# since format.bundle inspects colnames of x[[1L]])
b_extra <- new_bundle(list(sl2, sl2))
f_extra <- format(b_extra)
expect_true(grepl("attributes: FA", f_extra))

# ---- print.bundle -----------------------------------------------------------

expect_stdout(print(b_plain), "streamlines")

# ---- length.bundle ----------------------------------------------------------

expect_equal(length(b), 2L)
expect_equal(length(b0), 0L)

# ---- flat_list_to_bundle ----------------------------------------------------

# Multiple streamlines → bundle
lst_multi <- list(
  X           = c(0, 1, 2, 3, 4),
  Y           = c(0, 0, 0, 0, 0),
  Z           = c(0, 0, 0, 0, 0),
  PointId     = c(1, 2, 1, 2, 3),
  StreamlineId = c(1, 1, 2, 2, 2)
)
result_multi <- flat_list_to_bundle(lst_multi)
expect_inherits(result_multi, "bundle")
expect_equal(length(result_multi), 2L)
expect_equal(nrow(result_multi[[1L]]), 2L)
expect_equal(nrow(result_multi[[2L]]), 3L)

# Single streamline → streamline (not bundle)
lst_single <- list(
  X           = c(0, 1, 2),
  Y           = c(0, 0, 0),
  Z           = c(0, 0, 0),
  PointId     = c(1, 2, 3),
  StreamlineId = c(1, 1, 1)
)
result_single <- flat_list_to_bundle(lst_single)
expect_inherits(result_single, "streamline")
expect_equal(nrow(result_single), 3L)

# Extra attribute columns are preserved
lst_attr <- list(
  X           = c(0, 1, 2, 3),
  Y           = c(0, 0, 0, 0),
  Z           = c(0, 0, 0, 0),
  PointId     = c(1, 2, 1, 2),
  StreamlineId = c(1, 1, 2, 2),
  FA          = c(0.5, 0.6, 0.7, 0.8)
)
result_attr <- flat_list_to_bundle(lst_attr)
expect_inherits(result_attr, "bundle")
expect_true("FA" %in% colnames(result_attr[[1L]]))

# ---- bundle_to_flat_list ----------------------------------------------------

flat <- bundle_to_flat_list(b_plain)
expect_equal(sort(names(flat)), sort(c("X", "Y", "Z", "PointId", "StreamlineId")))
expect_equal(length(unique(flat$StreamlineId)), 2L)

# Lone streamline is wrapped automatically
flat_single <- bundle_to_flat_list(sl)
expect_equal(unique(flat_single$StreamlineId), 1L)
expect_equal(nrow(sl), length(flat_single$X))

# Extra attribute columns round-trip
b_attr <- new_bundle(list(sl2, sl2))
flat_attr <- bundle_to_flat_list(b_attr)
expect_true("FA" %in% names(flat_attr))
expect_equal(length(flat_attr$FA), 2L * nrow(sl2))
