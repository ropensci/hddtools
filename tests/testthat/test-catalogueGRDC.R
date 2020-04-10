context("catalogueGRDC")

test_that("Test full catalogue - cached version", {

  # Retrieve the whole catalogue
  x1a <- catalogueGRDC(useCachedData = TRUE)
  expect_equal("data.frame" %in% class(x1a), TRUE)
  expect_equal(dim(x1a), c(10124, 36))

})

test_that("Test full catalogue - live version", {
  
  if (curl::has_internet()){
    # Retrieve the whole catalogue
    x1b <- catalogueGRDC(useCachedData = FALSE)
    expect_equal("data.frame" %in% class(x1b), TRUE)
    expect_true(all(dim(x1b) >= c(10123, 36)))
  }
  
})

test_that("Test bounding box", {

  # Define a bounding box
  areaBox <- raster::extent(-4, -3, 52, 53)
  # Filter the catalogue based on bounding box
  x2 <- catalogueGRDC(areaBox = areaBox)

  expect_true(all(dim(x2) >= c(6, 36)))

})

test_that("Test area filter", {

  # Get only catchments with area above 5000 Km2
  x3 <- catalogueGRDC(columnName = "area", columnValue = ">= 5000")
  expect_true(all(dim(x3) >= c(3463, 36)))

})

test_that("Test river name", {

  # Get only catchments within river Thames
  x4 <- catalogueGRDC(columnName = "river", columnValue = "=='THAMES RIVER'")
  expect_true(all(dim(x4) >= c(2, 36)))

})
