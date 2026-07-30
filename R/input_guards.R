# Guards that stop an absent input from masquerading as an empty result.
#
# Why this file exists: two different failures produce the same downstream
# value -- zero rows -- and neither raises on its own.
#
#   (1) A local input directory that is not where the code expects it.
#       `list.files()` on a wrong path returns character(0), the read step then
#       builds a data frame with zero rows AND zero columns, and the semantic
#       validator reports every key column as missing. That error names the
#       columns, so it reads as header drift in the supplied data, while the
#       real cause is a directory renamed upstream. Check `dir.exists()` before
#       trusting a "missing column" diagnosis.
#
#   (2) A retrieval that failed. A network error and a query that legitimately
#       matched nothing both leave you holding zero records. Recorded as
#       `n = 0`, the failure later reads as positive evidence that the thing
#       does not exist -- the most expensive kind of wrong, because nothing
#       about it looks broken.
#
# Both are the same mistake: treating "I could not look" as "I looked and there
# was nothing". Both are cheap to make loud at the boundary, and impossible to
# recover from once the zero has been aggregated.
#
# These are pure functions: they take values, return values or raise. Keep
# them that way -- a guard that writes files or reads global state cannot be
# unit-tested against known-answer cases, and an untested guard is worse than
# none (it converts a loud failure into a quiet one).

#' Require that an input directory exists, fail loud when it does not
#'
#' A missing directory is always a code or configuration error, never data:
#' the analysis declared where the input lives and it is not there. Raises
#' rather than returning a value so the pipeline cannot continue on an empty
#' read. Returns `path` invisibly so it can be piped into a lister or reader.
require_input_dir <- function(path, what = "input directory") {
  if (length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop(
      "Invalid ",
      what,
      ": expected a single non-empty path, got ",
      deparse(path),
      call. = FALSE
    )
  }
  if (!dir.exists(path)) {
    stop(
      "Missing ",
      what,
      ": ",
      path,
      "\n",
      "  The path does not exist, so any read from it yields zero rows and a ",
      "downstream validator will report missing columns instead. Check ",
      "whether the supplier renamed the directory before treating this as a ",
      "schema problem.",
      call. = FALSE
    )
  }
  invisible(path)
}

#' List input files, refusing to return an unexplained empty set
#'
#' Wraps `list.files()` so that the two failure modes stay distinguishable: a
#' missing directory raises via [require_input_dir()], and a directory that
#' exists but matches nothing raises unless the caller opts in with
#' `allow_empty = TRUE`. Opting in is the point -- "there are legitimately no
#' files yet" is a claim about the data that belongs at the call site, not a
#' default the pipeline slides into silently.
list_input_files <- function(
  dir,
  pattern = NULL,
  allow_empty = FALSE,
  what = "input directory"
) {
  require_input_dir(dir, what = what)
  files <- list.files(dir, pattern = pattern, full.names = TRUE)
  if (length(files) == 0L && !allow_empty) {
    stop(
      "No files matched in ",
      what,
      ": ",
      dir,
      "\n",
      "  pattern: ",
      if (is.null(pattern)) "<none>" else pattern,
      "\n",
      "  The directory exists but is empty for this pattern. If that is ",
      "expected, pass allow_empty = TRUE at the call site to record the ",
      "claim explicitly.",
      call. = FALSE
    )
  }
  files
}

# Retrieval outcomes. `n` is trustworthy only for "ok" and "empty"; for
# "absent" and "failed" the count is unknown and must never be written as 0.
#
#   ok      retrieved, one or more records
#   empty   retrieved successfully, genuinely zero records
#   absent  the resource itself is not there (e.g. HTTP 404, no such table)
#   failed  could not retrieve (network, timeout, parse error) -- n is UNKNOWN
FETCH_STATUS <- c("ok", "empty", "absent", "failed")

# Statuses whose record count is a measurement. Anything else contributes to
# neither the numerator nor the denominator of a coverage figure.
FETCH_STATUS_COUNTED <- c("ok", "empty")

#' Record one retrieval outcome with its count invariant enforced
#'
#' The invariant is the whole point: `n` must be a number when the retrieval
#' succeeded and must be `NA` when it did not. Enforcing it here makes it
#' impossible to store a failed fetch as `n = 0`, which is the form that later
#' reads as evidence of absence.
new_fetch_result <- function(
  status,
  n = NA_integer_,
  source = NA_character_,
  note = NA_character_
) {
  if (length(status) != 1L || !status %in% FETCH_STATUS) {
    stop(
      "Invalid fetch status: ",
      deparse(status),
      "\n  must be one of: ",
      paste(FETCH_STATUS, collapse = ", "),
      call. = FALSE
    )
  }
  counted <- status %in% FETCH_STATUS_COUNTED
  if (counted && (length(n) != 1L || is.na(n))) {
    stop(
      "Status '",
      status,
      "' means the retrieval succeeded, so n must be a number, got ",
      deparse(n),
      call. = FALSE
    )
  }
  if (!counted && !(length(n) == 1L && is.na(n))) {
    stop(
      "Status '",
      status,
      "' means the count is unknown, so n must be NA, got ",
      deparse(n),
      "\n  Recording an unknown count as a number (especially 0) turns a ",
      "retrieval failure into false evidence of absence.",
      call. = FALSE
    )
  }
  tibble::tibble(
    status = status,
    n = as.integer(n),
    source = as.character(source),
    note = as.character(note)
  )
}

#' Summarise retrieval outcomes, keeping failures out of the denominator
#'
#' Returns one row: the totals over the retrievals that actually measured
#' something, plus the number that did not. Report `n_failed` and `n_absent`
#' alongside any coverage figure -- a rate computed over successful retrievals
#' only is not wrong, but it is not a rate over the population either, and the
#' difference is invisible unless the excluded count travels with it.
summarise_fetch_results <- function(results) {
  stopifnot(is.data.frame(results), all(c("status", "n") %in% names(results)))
  counted <- results$status %in% FETCH_STATUS_COUNTED
  tibble::tibble(
    n_records = sum(results$n[counted], na.rm = TRUE),
    n_counted = sum(counted),
    n_empty = sum(results$status == "empty"),
    n_absent = sum(results$status == "absent"),
    n_failed = sum(results$status == "failed"),
    n_total = nrow(results)
  )
}
