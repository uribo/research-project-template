# Provenance verification for immutable raw data.
#
# Raw inputs under data-raw/ are frozen bytes whose checksums are recorded in
# data-raw/PROVENANCE.md. Verifying the checksum on load makes silent input
# drift a loud, fail-fast error instead of a quietly wrong result: if a
# collaborator holds a different copy of a license-restricted file (which the
# repo cannot ship), the pipeline stops here rather than producing numbers that
# do not match the manuscript.
#
# These are pure functions: they take a path and a hash, read the declared
# input, and return a value (or raise). Persisting is the job of _targets.R.

#' SHA-256 digest of a file
#'
#' Thin wrapper over base R's `tools::sha256sum()` (no extra dependency),
#' returning a plain unnamed lowercase hex string.
sha256_file <- function(path) {
  unname(tools::sha256sum(path))
}

#' Verify a raw file against its recorded SHA-256, fail loud on mismatch
#'
#' Returns `path` invisibly on success so it can be piped into a reader inside
#' a `targets` target, e.g. `read_example_data(verify_provenance(path, hash))`.
#' Raises an error (never a warning) when the file is missing or the digest
#' differs from `expected_sha256` — do not wrap this in `tryCatch()` to swallow
#' the failure.
verify_provenance <- function(path, expected_sha256) {
  if (!file.exists(path)) {
    stop("Provenance check failed: file not found: ", path, call. = FALSE)
  }
  actual <- sha256_file(path)
  if (!identical(actual, expected_sha256)) {
    stop(
      "Provenance check failed for ",
      path,
      "\n",
      "  expected sha256: ",
      expected_sha256,
      "\n",
      "  actual   sha256: ",
      actual,
      "\n",
      "The frozen input does not match data-raw/PROVENANCE.md. ",
      "Do not update the manifest to make this pass unless the change is ",
      "intended and re-derived from the canonical source.",
      call. = FALSE
    )
  }
  invisible(path)
}
