context("TRMM")

test_that("Test TRMM function", {

  # Define a bounding box
  areaBox <- raster::extent(c(-3.82, -3.63, 48, 50))
  twindow <- seq(as.Date("2012-01-01"), as.Date("2012-01-31"), by = "months")

  x <- try(expr = TRMM(
    inputLocation="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
    product = "3B43",
    version = 7,
    type = "precipitation.accum",
    twindow = twindow,
    areaBox = areaBox,
    outputfileLocation = "."), silent = TRUE)

  rasterExtent <- raster::extent(raster::raster(x))

  expect_that(class(x) == "try-error", equals(FALSE))

  expect_that(rasterExtent@xmin == -4, equals(TRUE))
  expect_that(rasterExtent@xmax == -3.75, equals(TRUE))
  expect_that(rasterExtent@ymin == 48, equals(TRUE))
  expect_that(rasterExtent@ymax == 50, equals(TRUE))

})
