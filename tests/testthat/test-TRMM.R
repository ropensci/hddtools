context("TRMM")

test_that("Test TRMM function using dates in the past", {

  # Define a bounding box
  areaBox <- raster::extent(-4, -3.75, 48, 50)
  twindow <- seq(as.Date("2012-01-01"), as.Date("2012-01-31"), by = "months")

  x <- TRMM(product = "3B43",
            version = 7,
            type = "precipitation.accum",
            twindow = twindow,
            areaBox = areaBox)

  rasterExtent <- raster::extent(x)

  expect_that(class(x) == "try-error", equals(FALSE))

  expect_that(rasterExtent@xmin == -4, equals(TRUE))
  expect_that(rasterExtent@xmax == -3.75, equals(TRUE))
  expect_that(rasterExtent@ymin == 48, equals(TRUE))
  expect_that(rasterExtent@ymax == 50, equals(TRUE))

})

test_that("Test TRMM function using monthly dates in the future", {

  # Define a bounding box
  areaBox <- raster::extent(-4, -3.75, 48, 50)
  twindow <- seq(Sys.Date(), Sys.Date() + 32, by = "months")

  x <- TRMM(product = "3B43",
            version = 7,
            type = "precipitation.accum",
            twindow = twindow,
            areaBox = areaBox)

  expect_that(class(x) == "NULL", equals(TRUE))

})

test_that("Test TRMM function using 3-hourly dates in the past", {

  # Define a bounding box
  areaBox <- raster::extent(-4, -3.75, 48, 50)
  twindow <- seq(from = as.POSIXct("2012-1-1 0","%Y-%m-%d %H", tz="UTC"),
                 to = as.POSIXct("2012-1-1 23", "%Y-%m-%d %H", tz="UTC"),
                 by = 3*60*60)

  x <- TRMM(product = "3B42",
            version = 7,
            type = "precipitation.bin",
            twindow = twindow,
            areaBox = areaBox)

  rasterExtent <- raster::extent(x)

  expect_that(class(x) == "try-error", equals(FALSE))

  expect_that(rasterExtent@xmin == -4, equals(TRUE))
  expect_that(rasterExtent@xmax == -3.75, equals(TRUE))
  expect_that(rasterExtent@ymin == 48, equals(TRUE))
  expect_that(rasterExtent@ymax == 50, equals(TRUE))

})

