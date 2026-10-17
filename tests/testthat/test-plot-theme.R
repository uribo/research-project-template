brand_color <- function(brand, value) {
  # Resolve a palette name (e.g. "deep-green") to its hex value.
  palette <- brand$color$palette
  while (!is.null(palette[[value]])) {
    value <- palette[[value]]
  }
  tolower(value)
}

test_that("note_tokens match the colors in notes/_brand.yml", {
  brand <- yaml::read_yaml("../../notes/_brand.yml")
  for (mode in c("light", "dark")) {
    expect_identical(
      note_tokens(mode)$paper,
      brand_color(brand, brand$color$background[[mode]])
    )
    expect_identical(
      note_tokens(mode)$ink,
      brand_color(brand, brand$color$foreground[[mode]])
    )
    expect_identical(
      note_tokens(mode)$accent,
      brand_color(brand, brand$color$primary[[mode]])
    )
  }
})

test_that("theme_note sets the discrete palettes for each mode", {
  for (mode in c("light", "dark")) {
    theme <- theme_note(mode)
    expect_identical(theme$palette.colour.discrete, note_tokens(mode)$palette)
    expect_identical(theme$palette.fill.discrete, note_tokens(mode)$palette)
  }
  expect_error(theme_note("sepia"))
})

test_that("note_figure_pair returns a light and a dark figure", {
  p <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y))
  pair <- note_figure_pair(p)
  expect_named(pair, c("light", "dark"))
  expect_identical(
    pair$dark$theme$palette.fill.discrete,
    note_tokens("dark")$palette
  )
})
