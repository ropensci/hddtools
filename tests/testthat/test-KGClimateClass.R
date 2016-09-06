context("KGClimateClass")

test_that("Test KGClimateClass function", {

  skip_on_cran()
  skip_on_travis()

  # Define a bounding box
  bbox <- list(lonMin=-3.82,latMin=52.41,lonMax=-3.63,latMax=52.52)
  # Get climate classes
  x <- try(KGClimateClass(bbox), silent = TRUE)

  expect_that(class(x) != "try-error", equals(TRUE))
  expect_that(all(dim(x) == c(1, 3)), equals(TRUE))
  expect_that(all(x$ID == 15, x$Class == "Cfb", x$Frequency == 2), equals(TRUE))

})
