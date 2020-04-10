context("tsSEPA")

test_that("Test tsSEPA function", {

  if (FALSE) {

    skip("No internet connection")

    # Run this test only if there is internet connection
    if (FALSE) skip("No internet connection")

    # Retrieve sample data
    x <- tsSEPA("234253")

    expect_true("zoo" %in% class(x))

  }

})
