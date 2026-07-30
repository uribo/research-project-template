# Known-answer cases for the guards in R/input_guards.R.
#
# These guards exist to convert quiet wrongness into loud failure, so they are
# only worth having if they themselves are correct. A guard that raises on the
# good case blocks real work; a guard that passes on the bad case is worse than
# no guard, because it certifies the result. Both directions are pinned below.

test_that("require_input_dir accepts an existing directory and returns it", {
  dir <- withr::local_tempdir()
  expect_identical(require_input_dir(dir), dir)
})

test_that("require_input_dir errors on a missing directory", {
  missing <- file.path(withr::local_tempdir(), "not-created")
  expect_error(require_input_dir(missing), "Missing input directory")
})

test_that("require_input_dir names the supplier-rename possibility", {
  # The message has to steer the reader away from a schema diagnosis, which is
  # what the downstream symptom (missing columns) suggests on its own.
  missing <- file.path(withr::local_tempdir(), "13.renamed-upstream")
  expect_error(require_input_dir(missing), "renamed the directory")
})

test_that("require_input_dir rejects non-scalar and empty paths", {
  expect_error(require_input_dir(character(0)), "single non-empty path")
  expect_error(require_input_dir(c("a", "b")), "single non-empty path")
  expect_error(require_input_dir(NA_character_), "single non-empty path")
  expect_error(require_input_dir(""), "single non-empty path")
})

test_that("list_input_files returns matching files", {
  dir <- withr::local_tempdir()
  file.create(file.path(dir, c("a.csv", "b.csv", "notes.txt")))
  expect_length(list_input_files(dir, pattern = "[.]csv$"), 2L)
  expect_length(list_input_files(dir), 3L)
})

test_that("list_input_files errors when the directory is missing", {
  # Distinct from the empty case: this one is a wrong path, not absent data.
  missing <- file.path(withr::local_tempdir(), "not-created")
  expect_error(list_input_files(missing), "Missing input directory")
})

test_that("list_input_files errors on an unexplained empty match", {
  dir <- withr::local_tempdir()
  file.create(file.path(dir, "notes.txt"))
  expect_error(
    list_input_files(dir, pattern = "[.]csv$"),
    "No files matched"
  )
})

test_that("list_input_files allows an empty match when the caller opts in", {
  dir <- withr::local_tempdir()
  expect_identical(
    list_input_files(dir, pattern = "[.]csv$", allow_empty = TRUE),
    character(0)
  )
})

test_that("new_fetch_result keeps a count for successful retrievals", {
  ok <- new_fetch_result("ok", n = 23L, source = "https://example.org")
  expect_identical(ok$status, "ok")
  expect_identical(ok$n, 23L)

  # A genuine zero is a measurement and must be representable as one.
  empty <- new_fetch_result("empty", n = 0L)
  expect_identical(empty$n, 0L)
})

test_that("new_fetch_result refuses to store a failure as a count", {
  # This is the case the whole taxonomy exists for: n = 0 on a failed fetch
  # later reads as evidence that the thing does not exist.
  expect_error(new_fetch_result("failed", n = 0L), "count is unknown")
  expect_error(new_fetch_result("absent", n = 0L), "count is unknown")
  expect_error(new_fetch_result("failed", n = 12L), "count is unknown")
})

test_that("new_fetch_result requires a count when retrieval succeeded", {
  expect_error(new_fetch_result("ok"), "n must be a number")
  expect_error(new_fetch_result("empty", n = NA_integer_), "n must be a number")
})

test_that("new_fetch_result rejects an unknown status", {
  expect_error(new_fetch_result("partial", n = 1L), "Invalid fetch status")
  expect_error(new_fetch_result(c("ok", "ok"), n = 1L), "Invalid fetch status")
})

test_that("summarise_fetch_results excludes unmeasured retrievals", {
  results <- dplyr::bind_rows(
    new_fetch_result("ok", n = 10L),
    new_fetch_result("ok", n = 5L),
    new_fetch_result("empty", n = 0L),
    new_fetch_result("absent"),
    new_fetch_result("failed"),
    new_fetch_result("failed")
  )
  summary <- summarise_fetch_results(results)

  expect_identical(summary$n_records, 15L)
  # Denominator is the retrievals that measured something, not the row count.
  expect_identical(summary$n_counted, 3L)
  expect_identical(summary$n_empty, 1L)
  expect_identical(summary$n_absent, 1L)
  expect_identical(summary$n_failed, 2L)
  # n_total is reported so the gap between it and n_counted stays visible.
  expect_identical(summary$n_total, 6L)
})

test_that("summarise_fetch_results does not fold failures into a zero", {
  # All retrievals failed: the record total must not come out as a confident 0
  # over 2 sources. n_counted = 0 is what makes the figure uninterpretable,
  # which is the correct reading.
  results <- dplyr::bind_rows(
    new_fetch_result("failed"),
    new_fetch_result("failed")
  )
  summary <- summarise_fetch_results(results)
  expect_identical(summary$n_counted, 0L)
  expect_identical(summary$n_failed, 2L)
})
