library(testthat)

# Non-package project: function definitions in R/ are sourced by
# tests/testthat/setup.R. `stop_on_failure = TRUE` yields a non-zero exit
# code on failure so CI fails appropriately.
testthat::test_dir("tests/testthat", stop_on_failure = TRUE)
