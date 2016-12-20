context("bboxSpatialPolygon")

test_that("Test bboxSpatialPolygon function", {

  boundingbox <- raster::extent(c(-180, +180, -50, +50))
  bbSP <- bboxSpatialPolygon(boundingbox = boundingbox)

  expect_that("SpatialPolygons" %in% class(bbSP), equals(TRUE))

})
