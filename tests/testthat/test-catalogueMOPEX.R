context("catalogueMOPEX")

test_that("Test full catalogueMOPEX", {

  # Retrieve the MOPEX catalogue
  x1 <- catalogueMOPEX(useCachedData = FALSE)

  expect_that("data.frame" %in% class(x1), equals(TRUE))
  expect_that(all(dim(x1) == c(431, 12)), equals(TRUE))

})

test_that("Test bounding box with catalogueMOPEX", {

  # Define a bounding box
  areaBox <- raster::extent(-95, -92, 37, 41)
  # Filter the catalogue based on bounding box
  x2 <- catalogueMOPEX(areaBox = areaBox)

  expect_that(all(dim(x2) == c(8, 12)), equals(TRUE))

})

test_that("Test bounding box with catalogueMOPEX", {

  # Get only catchments within NC
  x3 <- catalogueMOPEX(columnName = "state", columnValue = "NC")

  expect_that(all(dim(x3) == c(16, 12)), equals(TRUE))

})
