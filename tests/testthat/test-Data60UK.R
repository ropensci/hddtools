context("Data60UK")

test_that("Test catalogueData60UK", {

  # Retrieve the whole catalogue
  x1 <- try(catalogueData60UK(), silent = TRUE)

  expect_that(class(x1) != "try-error", equals(TRUE))
  expect_that(all(dim(x1) == c(61, 6)), equals(TRUE))

})

test_that("Test catalogueData60UK bounding box", {

  # Define a bounding box
  areaBox <- raster::extent(c(-4, -2, +52, +53))
  # Filter the catalogue based on a bounding box
  x2 <- catalogueData60UK(areaBox)

  expect_that(all(dim(x2) == c(6, 6)), equals(TRUE))

})

test_that("Test tsData60UK function", {
  
  # Retrieve sample data
  x <- tsData60UK(id = 39015)
  
  expect_that(class(x) == "zoo", equals(TRUE))
  expect_that(all(names(x) == c("P", "Q")), equals(TRUE))
  
})
