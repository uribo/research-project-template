test_that("validate_example_data returns valid data unchanged", {
  good <- tibble::tibble(
    species = c("Adelie", "Gentoo"),
    island = c("Torgersen", "Biscoe"),
    bill_length_mm = c(39.1, 46.1),
    body_mass_g = c(3750, 5000),
    year = c(2007L, 2008L)
  )
  expect_identical(validate_example_data(good), good)
})

test_that("validate_example_data stops on invalid data", {
  # NA in a not-null column and a non-positive bill length both must fail.
  bad <- tibble::tibble(
    species = c("Adelie", NA_character_),
    island = c("Torgersen", "Biscoe"),
    bill_length_mm = c(39.1, -1),
    body_mass_g = c(3750, 5000),
    year = c(2007L, 2008L)
  )
  expect_error(validate_example_data(bad))
})

test_that("summarise_example returns one row per species with expected schema", {
  data <- tibble::tibble(
    species = c("Adelie", "Adelie", "Gentoo"),
    island = c("Torgersen", "Torgersen", "Biscoe"),
    bill_length_mm = c(39.1, 38.5, 46.1),
    body_mass_g = c(3750, 3800, 5000),
    year = c(2007L, 2007L, 2008L)
  )
  result <- summarise_example(data)
  expect_named(
    result,
    c("species", "n_obs", "mean_bill_length_mm", "mean_body_mass_g")
  )
  expect_setequal(result$species, c("Adelie", "Gentoo"))
  expect_equal(result$n_obs[result$species == "Adelie"], 2L)
})

test_that("read_example_data reads a CSV into a tibble", {
  path <- withr::local_tempfile(fileext = ".csv")
  readr::write_csv(
    tibble::tibble(
      species = "Adelie",
      island = "Torgersen",
      bill_length_mm = 39.1,
      body_mass_g = 3750,
      year = 2007L
    ),
    path
  )
  out <- read_example_data(path)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 1L)
})
