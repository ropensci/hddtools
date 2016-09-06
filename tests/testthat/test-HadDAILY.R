context("HadDAILY")

test_that("Test HadDAILY function", {

  skip_on_cran()

  # Retrieve the full dataset (list of 11 time series)
  x <- HadDAILY()
  expect_that("list" %in% class(x), equals(TRUE))
  expect_that(length(x) == 11, equals(TRUE))
  expect_that(all(names(x) == c("EWP", "SEEP", "SWEP", "CEP", "NWEP", "NEEP",
                                "SP", "SSP", "NSP", "ESP", "NIP")),
              equals(TRUE))

})
