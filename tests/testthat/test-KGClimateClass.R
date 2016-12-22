context("KGClimateClass")

test_that("Test KGClimateClass function", {

  # Define a bounding box
  areaBox <- raster::extent(-3.82, -3.63, 52.41, 52.52)
  # Get climate classes
  x <- try(KGClimateClass(areaBox = areaBox), silent = TRUE)

  expect_that(all(dim(x) == c(1, 3)), equals(TRUE))

})
