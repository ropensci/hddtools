context("catalogueData60UK")

test_that("Test catalogueData60UK function", {

  skip_on_cran()

  # Retrieve the whole catalogue
  x <- catalogueData60UK()
  expect_that("data.frame" %in% class(x), equals(TRUE))

  # Define a bounding box
  bbox <- list(lonMin=-4,latMin=52,lonMax=-3,latMax=53)
  # Filter the catalogue
  x <- catalogueData60UK(bbox)
  expect_that(all(dim(x) == c(2, 6)), equals(TRUE))

  # Filter the catalogue based on id
  x <- catalogueData60UK(columnName="id",columnValue="62001")
  expect_that(x$Location == "Glan Teifi", equals(TRUE))

})
