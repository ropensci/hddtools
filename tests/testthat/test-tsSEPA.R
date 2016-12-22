context("tsSEPA")

test_that("Test tsSEPA function", {

  # Retrieve sample data
  x <- tsSEPA("234253")

  expect_that("zoo" %in% class(x), equals(TRUE))

})
