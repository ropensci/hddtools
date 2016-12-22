context("tsGRDC")

test_that("Test tsGRDC function", {

  # Retrieve sample data
  x <- tsGRDC(stationID = 1107700)

  expect_that("list" %in% class(x), equals(TRUE))
  expect_that(all(names(x) == c("mddPerYear", "mddAllPeriod", "mddPerMonth")),
              equals(TRUE))

})
