context("catalogueGRDC")

test_that("Test full catalogue - cached version", {

  # Retrieve the whole catalogue
  x1a <- catalogueGRDC(useCachedData = TRUE)
  expect_equal("data.frame" %in% class(x1a), TRUE)
  expect_equal(dim(x1a), c(9520, 26))

})

test_that("Test bounding box", {

  # Define a bounding box
  areaBox <- raster::extent(-4, -3, 52, 53)
  # Filter the catalogue based on bounding box
  x2 <- catalogueGRDC(areaBox = areaBox)

  expect_equal(dim(x2), c(6, 26))

})

test_that("Test area filter", {

  # Get only catchments with area above 5000 Km2
  x3 <- catalogueGRDC(columnName = "area", columnValue = ">= 5000")

  expect_that(all(dim(x3) == c(3349, 26)), equals(TRUE))

})

test_that("Test river name", {

  # Get only catchments within river Thames
  x4 <- catalogueGRDC(columnName = "river", columnValue = "Thames")

  expect_that(all(dim(x4) == c(5, 26)), equals(TRUE))

})

test_that("Test full catalogue - live version", {

  # Run this test only if there is internet connection
  if (FALSE) {

    skip("No internet connection")

    # Retrieve the whole catalogue
    x1b <- catalogueGRDC(useCachedData = FALSE)
    expect_equal(dim(x1b)[1] >= 9520, TRUE)

  }

})