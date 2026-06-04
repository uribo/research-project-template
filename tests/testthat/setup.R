# Source project function definitions for this non-package project.
# testthat runs with the working directory set to tests/testthat/, so the
# project's R/ directory is two levels up.
local({
  r_files <- list.files("../../R", pattern = "[.][Rr]$", full.names = TRUE)
  invisible(lapply(r_files, source))
})
