context("catalogueSEPA")

test_that("Test full catalogueSEPA", {

  # Retrieve the SEPA catalogue
  x1 <- catalogueSEPA()

  expect_that("data.frame" %in% class(x1), equals(TRUE))
  expect_that(all(dim(x1) == c(830, 8)), equals(TRUE))

})

test_that("Test area filter with catalogueSEPA", {

  # Get only catchments with area above 5000 Km2
  x2 <- catalogueSEPA(columnName = "CatchmentAreaKm2", columnValue = ">= 5000")

  expect_that(all(dim(x2) == c(12, 8)), equals(TRUE))

})

test_that("Test filter on the name of the river with catalogueSEPA", {

  # Get only catchments within river Avon
  x3 <- catalogueSEPA(columnName = "River", columnValue = "Avon")

  expect_that(all(dim(x3) == c(4, 8)), equals(TRUE))

})
