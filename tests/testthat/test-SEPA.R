context("SEPA")

test_that("Test catalogueSEPA function", {

  skip_on_cran()

  # Retrieve the SEPA catalogue
  x <- catalogueSEPA()
  expect_that("data.frame" %in% class(x), equals(TRUE))
  expect_that(all(dim(x) == c(830, 8)), equals(TRUE))

})

test_that("Test tsSEPA function", {

  skip_on_cran()

  # Retrieve sample data
  x <- tsSEPA("234253")
  expect_that("zoo" %in% class(x), equals(TRUE))

})
