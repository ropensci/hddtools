context("tsGRDC")

test_that("Test tsGRDC function", {

  if (FALSE) {

    skip("No internet connection")

    # Retrieve sample data
    x <- tsGRDC(stationID = "1107700")

    expect_equal("list" %in% class(x), TRUE)
    expect_equal(all(names(x) == c("LTVD", "LTVM", "PVD", "PVM", "YVD", "YVM")),
                 TRUE)

  }

})
