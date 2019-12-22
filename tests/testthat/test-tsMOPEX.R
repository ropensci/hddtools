context("tsMOPEX")

test_that("Test tsMOPEX function", {

  if (curl::has_internet()){
    # Retrieve sample data
    x <- tsMOPEX("14359000")
    
    expect_that("zoo" %in% class(x), equals(TRUE))
    expect_that(all(names(x) == c("P", "E", "Q", "Tmax", "Tmin")),
                equals(TRUE))
  }

})
