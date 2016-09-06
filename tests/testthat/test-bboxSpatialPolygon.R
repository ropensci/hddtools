# context("bboxSpatialPolygon")
#
# test_that("Test bboxSpatialPolygon function", {
#
#   skip_on_cran()
#
#   bbox <- list(lonMin=-180,latMin=-50,lonMax=+180,latMax=+50)
#   bbSP <- bboxSpatialPolygon(bbox)
#
#   expect_that("SpatialPolygons" %in% class(bbSP), equals(TRUE))
#
# })
