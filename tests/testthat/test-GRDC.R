context("GRDC")

test_that("Test catalogueGRDC", {

  # Retrieve the whole catalogue
  x1 <- catalogueGRDC()
  expect_true("data.frame" %in% class(x1))
  expect_true(all(dim(x1) >= c(9922, 24)))
  expect_true(x1$river[x1$grdc_no == "1159900"] == "KLIPRIVIER")

})
