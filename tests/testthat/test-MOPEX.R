context("MOPEX")

test_that("Test catalogueMOPEX function", {

  skip_on_cran()

  # Retrieve the MOPEX catalogue
  x <- catalogueMOPEX()
  expect_that("data.frame" %in% class(x), equals(TRUE))
  expect_that(all(dim(x) == c(431, 12)), equals(TRUE))

})

test_that("Test tsMOPEX function", {

  skip_on_cran()

  # Retrieve sample data
  x <- tsMOPEX("14359000")
  expect_that("zoo" %in% class(x), equals(TRUE))
  expect_that(all(names(x) == c("P", "E", "Q", "Tmax", "Tmin")),
              equals(TRUE))

})
