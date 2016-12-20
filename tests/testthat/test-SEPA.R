context("SEPA")

test_that("Test full catalogueSEPA", {

  # Retrieve the SEPA catalogue
  x <- catalogueSEPA()
  expect_that("data.frame" %in% class(x), equals(TRUE))
  expect_that(all(dim(x) == c(830, 8)), equals(TRUE))

})

test_that("Test area filter with catalogueSEPA", {

  # Get only catchments with area above 5000 Km2
  x <- catalogueSEPA(columnName = "CatchmentAreaKm2", columnValue = ">= 5000")
  expect_that(all(dim(x) == c(12, 8)), equals(TRUE))

})

test_that("Test filter on the name of the river with catalogueSEPA", {

  # Get only catchments within river Avon
  x <- catalogueSEPA(columnName = "River", columnValue = "Avon")
  expect_that(all(dim(x) == c(4, 8)), equals(TRUE))

})

test_that("Test tsSEPA function", {

  # Retrieve sample data
  x <- tsSEPA("234253")
  expect_that("zoo" %in% class(x), equals(TRUE))

})
