context("Data60UK")

test_that("Test catalogueData60UK function", {

  skip_on_cran()

  # Retrieve the whole catalogue
  expect_that(class(catalogueData60UK()) == "data.frame", equals(TRUE))

  # Define a bounding box
  bbox <- list(lonMin=-4,latMin=52,lonMax=-3,latMax=53)
  # Filter the catalogue
  x <- catalogueData60UK(bbox)
  expect_that(all(dim(x) == c(2, 6)), equals(TRUE))

  # Filter the catalogue based on id
  x <- catalogueData60UK(columnName="id",columnValue="62001")
  expect_that(x$Location == "Glan Teifi", equals(TRUE))

})

test_that("Test tsData60UK function", {

  skip_on_cran()

  # Retrieve sample data
  x <- tsData60UK(hydroRefNumber = 39015)
  expect_that(class(x) == "zoo", equals(TRUE))
  expect_that(all(names(x) == c("P", "Q")),
              equals(TRUE))

})

