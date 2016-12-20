context("Data60UK")

test_that("Test full catalogueData60UK", {

  # Retrieve the whole catalogue
  x <- try(catalogueData60UK(), silent = TRUE)

  expect_that(class(x) != "try-error", equals(TRUE))
  expect_that(all(dim(x) == c(61, 6)), equals(TRUE))

})

test_that("Test catalogueData60UK bounding box", {

  # Define a bounding box
  areaBox <- raster::extent(c(-4, -2, +52, +53))
  # Filter the catalogue
  x <- catalogueData60UK(areaBox)

  expect_that(all(dim(x) == c(6, 6)), equals(TRUE))

})

test_that("Test catalogueData60UK id", {

  # Filter the catalogue based on id
  x <- catalogueData60UK(columnName="id",columnValue="62001")
  expect_that(x$Location == "Glan Teifi", equals(TRUE))

})

test_that("Test tsData60UK function", {

  # Retrieve sample data
  x <- tsData60UK(hydroRefNumber = 39015)
  expect_that(class(x) == "zoo", equals(TRUE))
  expect_that(all(names(x) == c("P", "Q")), equals(TRUE))

})

