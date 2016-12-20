context("MOPEX")

test_that("Test full catalogueMOPEX", {

  # Retrieve the MOPEX catalogue
  x <- catalogueMOPEX()
  expect_that("data.frame" %in% class(x), equals(TRUE))
  expect_that(all(dim(x) == c(431, 12)), equals(TRUE))

})

test_that("Test bounding box with catalogueMOPEX", {

  # Define a bounding box
  areaBox <- raster::extent(c(-95, -92, 37, 41))
  # Filter the catalogue based on bounding box
  x <- catalogueMOPEX(areaBox = areaBox)

  expect_that(all(dim(x) == c(8, 12)), equals(TRUE))

})

test_that("Test bounding box with catalogueMOPEX", {

  # Get only catchments within NC
  x <- catalogueMOPEX(columnName = "state", columnValue = "NC")

  expect_that(all(dim(x) == c(16, 12)), equals(TRUE))

})

test_that("Test tsMOPEX function", {

  # Retrieve sample data
  x <- tsMOPEX("14359000")
  expect_that("zoo" %in% class(x), equals(TRUE))
  expect_that(all(names(x) == c("P", "E", "Q", "Tmax", "Tmin")),
              equals(TRUE))

})
