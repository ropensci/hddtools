context("TRMM")

test_that("Test TRMM function", {

  # Define a bounding box
  areaBox <- raster::extent(-4, -3.75, 48, 50)
  twindow <- seq(as.Date("2012-01-01"), as.Date("2012-01-31"), by = "months")

  x <- TRMM(product = "3B43",
            version = 7,
            type = "precipitation.accum",
            twindow = twindow,
            areaBox = areaBox,
            outputfileLocation = ".")

  rasterExtent <- raster::extent(x)

  expect_that(class(x) == "try-error", equals(FALSE))

  expect_that(rasterExtent@xmin == -4, equals(TRUE))
  expect_that(rasterExtent@xmax == -3.75, equals(TRUE))
  expect_that(rasterExtent@ymin == 48, equals(TRUE))
  expect_that(rasterExtent@ymax == 50, equals(TRUE))

})
