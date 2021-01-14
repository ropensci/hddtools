context("SEPA")

test_that("Test catalogueSEPA", {

  # Retrieve the SEPA catalogue
  x1 <- catalogueSEPA()
  
  # If the service/website is up and running, x1 should be not NULL
  if (!is.null(x1)){
    expect_that("data.frame" %in% class(x1), equals(TRUE))
    expect_that(all(dim(x1) >= c(366, 20)), equals(TRUE))
  }

})

test_that("Test tsSEPA function", {
  
  # Retrieve sample data
  x2 <- tsSEPA(id = "234253")
  
  # If the service/website is up and running, x2 should be not NULL
  if (!is.null(x2)){
    
    expect_true("zoo" %in% class(x2))
    
  }
  
})
