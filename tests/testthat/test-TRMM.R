context("TRMM")

test_that("Test TRMM function", {

  skip_on_cran()

  # Define a bounding box
  bbox <- list(lonMin=-3.82, latMin=48,lonMax=-3.63, latMax=50)
  twindow <- seq(as.Date("2012-01-01"), as.Date("2012-01-31"), by="months")

  x <- try(expr = TRMM(
    inputLocation="ftp://disc2.nascom.nasa.gov/data/TRMM/Gridded/",
    product = "3B43",
    version = 7,
    type = "precipitation.accum",
    timeExtent = twindow,
    bbox = bbox,
    outputfileLocation = "."), silent = TRUE)

  expect_that(is.null(x), equals(TRUE))

})
