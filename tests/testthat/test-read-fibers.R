test_that("a tract object is a tibble", {
  tr <- read_fibers(system.file("extdata", "UF_left.vtp", package = "fiberIO"))
  expect_true(tibble::is_tibble(tr))
})


test_that("a tract object has 5 columns", {
  tr <- read_fibers(system.file("extdata", "UF_left.vtp", package = "fiberIO"))
  expect_equal(ncol(tr), 5)
})
