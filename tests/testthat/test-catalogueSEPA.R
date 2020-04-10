context("catalogueSEPA")

test_that("Test full catalogueSEPA", {

  # Retrieve the SEPA catalogue
  x1 <- catalogueSEPA(useCachedData = FALSE)

  expect_that("data.frame" %in% class(x1), equals(TRUE))
  expect_that(all(dim(x1) >= c(366, 20)), equals(TRUE))

})

test_that("Test area filter with catalogueSEPA", {

  # Get only catchments with area above 5000 Km2
  x2 <- catalogueSEPA(columnName = "CATCHMENT_AREA", columnValue = ">= 500",
                      useCachedData = TRUE)

  expect_that(all(dim(x2) == c(60, 20)), equals(TRUE))

})

test_that("Test filter on the name of the river with catalogueSEPA", {

  # Get only catchments within river Spey
  x3 <- catalogueSEPA(columnName = "RIVER_NAME", columnValue = "Spey",
                      useCachedData = TRUE)

  expect_that(all(dim(x3) == c(8, 20)), equals(TRUE))

})
