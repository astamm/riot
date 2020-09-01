test_that("a tract object is a tibble", {
  tr <- read_tracts(system.file("extdata", "UF_left.vtp", package = "trio"))
  testthat::expect_true(tibble::is_tibble(tr))
})


test_that("a tract object has 5 columns", {
  tr <- read_tracts(system.file("extdata", "UF_left.vtp", package = "trio"))
  testthat::expect_equal(ncol(tr), 5)
})
