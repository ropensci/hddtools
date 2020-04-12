context("SEPA")

test_that("Test catalogueSEPA", {

  # Retrieve the SEPA catalogue
  x1 <- catalogueSEPA()

  expect_that("data.frame" %in% class(x1), equals(TRUE))
  expect_that(all(dim(x1) >= c(366, 20)), equals(TRUE))

})

test_that("Test tsSEPA function", {
  
  # Retrieve sample data
  x <- tsSEPA(id = "234253")
  
  expect_true("zoo" %in% class(x))
  
})
