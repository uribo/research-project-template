test_that("sha256_file returns a plain 64-char hex digest", {
  path <- withr::local_tempfile(fileext = ".txt")
  writeLines("hello provenance", path)
  digest <- sha256_file(path)
  expect_type(digest, "character")
  expect_null(names(digest))
  expect_match(digest, "^[0-9a-f]{64}$")
})

test_that("verify_provenance returns the path invisibly when the hash matches", {
  path <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", path)
  hash <- sha256_file(path)
  expect_identical(verify_provenance(path, hash), path)
})

test_that("verify_provenance errors on a hash mismatch", {
  path <- withr::local_tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", path)
  expect_error(
    verify_provenance(path, strrep("0", 64)),
    "Provenance check failed"
  )
})

test_that("verify_provenance errors on a missing file", {
  expect_error(
    verify_provenance("does-not-exist.csv", strrep("0", 64)),
    "file not found"
  )
})
