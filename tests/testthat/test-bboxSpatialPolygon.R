context("bboxSpatialPolygon")

test_that("Test bboxSpatialPolygon function", {

  boundingbox <- terra::ext(c(-180, +180, -50, +50))
  bbSP <- bboxSpatialPolygon(boundingbox = boundingbox)

  expect_that("sfc_POLYGON" %in% class(bbSP), equals(TRUE))

})
