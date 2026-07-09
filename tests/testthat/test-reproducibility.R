# Numeric reproducibility sentinel.
#
# Why this file exists: `targets::tar_validate()` only checks that the pipeline
# graph is well-formed, and targets does not track package *versions* in its
# cues -- so a `renv` update can silently change a package's numeric behavior
# without invalidating any cached target. This test closes that gap by running
# the core pipeline's pure functions end-to-end against a committed fixture and
# pinning the key derived quantities with tolerance. It runs on every
# `tests/testthat.R` invocation, including the renv-update workflow's test step,
# so a package bump that shifts a result turns the update PR red (fail-loud).
#
# Scope and limits: this is a *representative-fixture drift detector*, not a
# proof of full reproducibility. A green sentinel means the pinned quantities
# are stable on the committed fixture -- it does NOT mean the manuscript's
# numbers reproduce, because CI has no access to the production data. Full
# numeric reproduction is verified locally (re-run `tar_make()` on the real
# data and compare against the recorded paper values).
#
# We do not need the gitignored production data here: the example raw CSV under
# data-raw/example/ is committed as a .gitignore exception, so CI can run the
# whole read -> validate -> summarise chain on it. When you replace the example
# with your project's (often gitignored) data, keep a small committed fixture
# -- synthetic if the real data cannot be shared -- and pin YOUR project's key
# derived values (sample sizes, coefficients, summary statistics) below.

# Resolve the committed fixture relative to the test directory. This mirrors the
# `example_raw_file` target in _targets.R (sans the sha256 provenance guard,
# which test-data-provenance.R covers separately).
fixture_path <- testthat::test_path(
  "..",
  "..",
  "data-raw",
  "example",
  "penguins-sample.csv"
)

test_that("core pipeline reproduces the committed fixture summary", {
  summary <- fixture_path |>
    read_example_data() |>
    validate_example_data() |>
    summarise_example()

  # summarise_example() arranges by species, so rows are Adelie, Chinstrap,
  # Gentoo. Expected values are derived from the 12-row committed fixture.
  expect_identical(summary$species, c("Adelie", "Chinstrap", "Gentoo"))
  expect_identical(summary$n_obs, c(5L, 3L, 4L))
  expect_equal(
    summary$mean_bill_length_mm,
    c(39.04, 48.5666666667, 48.5),
    tolerance = 1e-8
  )
  expect_equal(
    summary$mean_body_mass_g,
    c(3660, 3733.3333333333, 5200),
    tolerance = 1e-8
  )
})
