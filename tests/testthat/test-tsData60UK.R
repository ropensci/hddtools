context("tsData60UK")

test_that("Test tsData60UK function", {

    # Retrieve sample data
    x <- tsData60UK(stationID = 39015)

    expect_that(class(x) == "zoo", equals(TRUE))
    expect_that(all(names(x) == c("P", "Q")), equals(TRUE))

})

