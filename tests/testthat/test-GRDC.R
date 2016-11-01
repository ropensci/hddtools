context("GRDC")

test_that("Test catalogueGRDC function", {

  skip_on_cran()

  # Retrieve the whole catalogue
  x <- catalogueGRDC()
  expect_that("data.frame" %in% class(x), equals(TRUE))

  # Define a bounding box
  bbox <- list(lonMin=-3.82,latMin=52.41,lonMax=-3.63,latMax=52.52)
  # Filter the catalogue
  x <- catalogueGRDC(bbox)
  expect_that(all(dim(x) == c(2, 46)), equals(TRUE))

})

test_that("Test tsGRDC function", {

  skip_on_cran()

  # Retrieve sample data
  x <- tsGRDC(stationID = 1107700)
  expect_that("list" %in% class(x), equals(TRUE))
  expect_that(all(names(x) == c("mddPerYear", "mddAllPeriod", "mddPerMonth")),
              equals(TRUE))

})
