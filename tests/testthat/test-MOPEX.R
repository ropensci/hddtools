context("MOPEX")

test_that("Test catalogueMOPEX - MAP = FALSE", {

  testthat::skip_on_cran()

  # Retrieve the MOPEX catalogue
  x1 <- catalogueMOPEX(MAP = FALSE)
  
  expect_true("data.frame" %in% class(x1))
  expect_true(all(dim(x1) == c(1861, 12)))
  expect_true(is.na(x1$State[x1$USGS_ID == "08167000"]))

})

test_that("Test catalogueMOPEX - MAP = TRUE", {

  testthat::skip_on_cran()

  # Retrieve the MOPEX catalogue
  x2 <- catalogueMOPEX(MAP = TRUE)
  
  expect_true("data.frame" %in% class(x2))
  expect_true(all(dim(x2) == c(438, 12)))
  expect_true(x2$State[x2$USGS_ID == "01048000"] == "ME")
  
})

test_that("Test tsMOPEX - MAP = FALSE", {

  testthat::skip_on_cran()

  # Retrieve data
  x3 <- tsMOPEX(id = "01010000", MAP = FALSE)
  
  expect_true("zoo" %in% class(x3))
  expect_true(all(names(x3) == "Q"))
  expect_true(as.numeric(x3$Q[1]) == 13.45)
  
})

test_that("Test tsMOPEX - MAP = TRUE", {

  testthat::skip_on_cran()

  # Retrieve data
  x4 <- tsMOPEX(id = "01048000", MAP = TRUE)
  
  expect_true("zoo" %in% class(x4))
  expect_true(all(names(x4) == c("P", "E", "Q", "T_max", "T_min")))
  expect_true(as.numeric(x4$T_min[1]) == -10.8444)
  
})
