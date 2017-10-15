context("catalogueGRDC")

test_that("Test full catalogue", {

  # Retrieve the whole catalogue
  x1 <- catalogueGRDC()
  expect_that("data.frame" %in% class(x1), equals(TRUE))

})

test_that("Test bounding box", {

  # Define a bounding box
  areaBox <- raster::extent(-3.82, -3.63, 52.41, 52.52)
  # Filter the catalogue based on bounding box
  x2 <- catalogueGRDC(areaBox = areaBox)

  expect_that(all(dim(x2) == c(2, 26)), equals(TRUE))

})

test_that("Test area filter", {

  # Get only catchments with area above 5000 Km2
  x3 <- catalogueGRDC(columnName = "area", columnValue = ">= 5000")

  expect_that(all(dim(x3) == c(3323, 26)), equals(TRUE))

})

test_that("Test river name", {

  # Get only catchments within river Thames
  x4 <- catalogueGRDC(columnName = "river", columnValue = "Thames")

  expect_that(all(dim(x4) == c(5, 26)), equals(TRUE))

})
