context("tsGRDC")

test_that("Test tsGRDC function", {

  skip("Skip temporarily, function should be adapted to new changes on the ftp")

  # Retrieve sample data
  x <- tsGRDC(stationID = 1107700)

  expect_that("list" %in% class(x), equals(TRUE))
  expect_that(all(names(x) == c("LTVD", "LTVM", "PVD", "PVM", "YVD", "YVM")),
              equals(TRUE))

})
