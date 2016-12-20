context("GRDC")

test_that("Test full catalogue", {

  # Retrieve the whole catalogue
  x <- catalogueGRDC()
  expect_that("data.frame" %in% class(x), equals(TRUE))

})

test_that("Test bounding box", {

  # Define a bounding box
  areaBox <- raster::extent(c(-3.82, -3.63, 52.41, 52.52))
  # Filter the catalogue based on bounding box
  x <- catalogueGRDC(areaBox = areaBox)

  expect_that(all(dim(x) == c(2, 46)), equals(TRUE))

})

test_that("Test area filter", {

  # Get only catchments with area above 5000 Km2
  x <- catalogueGRDC(columnName = "area", columnValue = ">= 5000")

  expect_that(all(dim(x) == c(3314, 46)), equals(TRUE))

})

test_that("Test river name", {

  # Get only catchments within river Thames
  x <- catalogueGRDC(columnName = "river", columnValue = "Thames")

  expect_that(all(dim(x) == c(6, 46)), equals(TRUE))

})

test_that("Test tsGRDC function", {

  # Retrieve sample data
  x <- tsGRDC(stationID = 1107700)
  expect_that("list" %in% class(x), equals(TRUE))
  expect_that(all(names(x) == c("mddPerYear", "mddAllPeriod", "mddPerMonth")),
              equals(TRUE))

})
