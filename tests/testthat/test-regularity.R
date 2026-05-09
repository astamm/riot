test_that("riot correctly reads VTK format", {
  tr <- read_tractogram(system.file("extdata", "UF_left.vtk", package = "riot"))
  expect_true(is_bundle(tr))
  total_pts <- sum(vapply(tr, nrow, integer(1L)))
  expect_equal(total_pts, 38697)
  expect_true(all(vapply(tr, function(sl) ncol(sl) == 3L, logical(1L))))
  expect_false(anyNA(do.call(rbind, tr)))
})

test_that("riot correctly reads VTP format", {
  tr <- read_tractogram(system.file("extdata", "UF_left.vtp", package = "riot"))
  expect_true(is_bundle(tr))
  total_pts <- sum(vapply(tr, nrow, integer(1L)))
  expect_equal(total_pts, 38697)
  expect_true(all(vapply(tr, function(sl) ncol(sl) == 3L, logical(1L))))
  expect_false(anyNA(do.call(rbind, tr)))
})

test_that("riot correctly reads FDS format", {
  tr <- read_tractogram(system.file("extdata", "UF_left.fds", package = "riot"))
  expect_true(is_bundle(tr))
  total_pts <- sum(vapply(tr, nrow, integer(1L)))
  expect_equal(total_pts, 38697)
  expect_true(all(vapply(tr, function(sl) ncol(sl) == 3L, logical(1L))))
  expect_false(anyNA(do.call(rbind, tr)))
})

test_that("riot correctly reads MRtrix format", {
  tr <- read_tractogram(system.file("extdata", "AF_left.tck", package = "riot"))
  expect_true(is_bundle(tr))
  total_pts <- sum(vapply(tr, nrow, integer(1L)))
  expect_equal(total_pts, 140301)
  expect_true(all(vapply(tr, function(sl) ncol(sl) == 3L, logical(1L))))
  expect_false(anyNA(do.call(rbind, tr)))
})

test_that("riot correctly reads TrackVis format", {
  tr <- read_tractogram(system.file("extdata", "CCMid.trk", package = "riot"))
  expect_true(is_bundle(tr))
  total_pts <- sum(vapply(tr, nrow, integer(1L)))
  expect_equal(total_pts, 112675)
  expect_true(all(vapply(tr, function(sl) ncol(sl) == 3L, logical(1L))))
  expect_false(anyNA(do.call(rbind, tr)))
})

test_that("riot correctly writes VTK format", {
  tr1 <- read_tractogram(system.file(
    "extdata",
    "UF_left.vtk",
    package = "riot"
  ))
  withr::with_tempfile(
    "tf",
    {
      write_tractogram(tr1, tf)
      tr2 <- read_tractogram(tf)
      expect_equal(tr2, tr1)
    },
    fileext = ".vtk"
  )
})

test_that("riot correctly writes VTP format", {
  tr1 <- read_tractogram(system.file(
    "extdata",
    "UF_left.vtp",
    package = "riot"
  ))
  withr::with_tempfile(
    "tf",
    {
      write_tractogram(tr1, tf)
      tr2 <- read_tractogram(tf)
      expect_equal(tr2, tr1)
    },
    fileext = ".vtp"
  )
})

test_that("riot correctly writes FDS format", {
  tr1 <- read_tractogram(system.file(
    "extdata",
    "UF_left.fds",
    package = "riot"
  ))
  withr::with_tempfile(
    "tf",
    {
      write_tractogram(tr1, tf)
      tr2 <- read_tractogram(tf)
      expect_equal(tr2, tr1)
    },
    fileext = ".fds"
  )
})
