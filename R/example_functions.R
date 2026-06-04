# Example pure functions illustrating the project conventions:
#   - no side effects (no library()/source()/tar_load()/file I/O beyond the
#     declared input), explicit arguments, namespace-prefixed calls,
#     native pipe, and modern tidyverse (`.by`).
# Replace these with your project's functions and delete the example data
# (see SETUP.md, step 8).

#' Read the example raw CSV
#'
#' Pure reader: takes a file path, returns a tibble. Persisting outputs is the
#' job of `_targets.R`, not of this function.
read_example_data <- function(path) {
  readr::read_csv(path, show_col_types = FALSE)
}

#' Validate the example data
#'
#' Semantic-integrity checks via pointblank in pipeline (data-in/data-out)
#' mode. With `action_levels(stop_at = 1)` any failing unit raises an error,
#' so the pipeline stops on bad data. On success the input is returned
#' unchanged so it can be piped onward.
validate_example_data <- function(data) {
  al <- pointblank::action_levels(stop_at = 1)
  data |>
    pointblank::col_vals_not_null(
      columns = c(species, island, bill_length_mm, body_mass_g, year),
      actions = al
    ) |>
    pointblank::col_vals_gt(
      columns = bill_length_mm,
      value = 0,
      actions = al
    ) |>
    pointblank::col_vals_gt(columns = body_mass_g, value = 0, actions = al)
}

#' Summarise the example data by species
#'
#' Modern tidyverse: `.by` instead of group_by()/ungroup().
summarise_example <- function(data) {
  data |>
    dplyr::summarise(
      n_obs = dplyr::n(),
      mean_bill_length_mm = mean(bill_length_mm),
      mean_body_mass_g = mean(body_mass_g),
      .by = species
    ) |>
    dplyr::arrange(species)
}
