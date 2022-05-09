test_that("riot correctly reads VTK format", {
  tr <- read_fascicles(system.file("extdata", "UF_left.vtk", package = "riot"))
  expect_true(tibble::is_tibble(tr))
  expect_true(nrow(tr) == 38697)
  expect_equal(ncol(tr), 5)
  expect_false(anyNA(tr))
})

test_that("riot correctly reads VTP format", {
  tr <- read_fascicles(system.file("extdata", "UF_left.vtp", package = "riot"))
  expect_true(tibble::is_tibble(tr))
  expect_true(nrow(tr) == 38697)
  expect_equal(ncol(tr), 5)
  expect_false(anyNA(tr))
})

test_that("riot correctly reads FDS format", {
  tr <- read_fascicles(system.file("extdata", "UF_left.fds", package = "riot"))
  expect_true(tibble::is_tibble(tr))
  expect_true(nrow(tr) == 38697)
  expect_equal(ncol(tr), 5)
  expect_false(anyNA(tr))
})

test_that("riot correctly reads MRtrix format", {
  tr <- read_fascicles(system.file("extdata", "AF_left.tck", package = "riot"))
  expect_true(tibble::is_tibble(tr))
  expect_true(nrow(tr) == 140301)
  expect_equal(ncol(tr), 5)
  expect_false(anyNA(tr))
})

test_that("riot correctly reads TrackVis format", {
  tr <- read_fascicles(system.file("extdata", "CCMid.trk", package = "riot"))
  expect_true(tibble::is_tibble(tr))
  expect_true(nrow(tr) == 112675)
  expect_equal(ncol(tr), 5)
  expect_false(anyNA(tr))
})

test_that("riot correctly writes VTK format", {
  tr1 <- read_fascicles(system.file("extdata", "UF_left.vtk", package = "riot"))
  withr::with_tempfile("tf", {
    write_fascicles(tr1, tf)
    tr2 <- read_fascicles(tf)
    expect_equal(tr2, tr1)
  }, fileext = ".vtk")
})

test_that("riot correctly writes VTP format", {
  tr1 <- read_fascicles(system.file("extdata", "UF_left.vtp", package = "riot"))
  withr::with_tempfile("tf", {
    write_fascicles(tr1, tf)
    tr2 <- read_fascicles(tf)
    expect_equal(tr2, tr1)
  }, fileext = ".vtp")
})

test_that("riot correctly writes FDS format", {
  tr1 <- read_fascicles(system.file("extdata", "UF_left.fds", package = "riot"))
  withr::with_tempfile("tf", {
    write_fascicles(tr1, tf)
    tr2 <- read_fascicles(tf)
    expect_equal(tr2, tr1)
  }, fileext = ".fds")
})
