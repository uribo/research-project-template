# ggplot2 theme for analysis notes, matched to notes/_brand.yml.
#
# The HTML colors come from _brand.yml; figures are drawn by R and never see
# it, so the values are repeated here. tests/testthat/test-plot-theme.R checks
# that the two stay in sync. Requires ggplot2 >= 4.0 (`ink`/`paper`/`accent`
# and the `palette.*` theme elements).
#
# Build figures in the pipeline with note_figure_pair() and print both halves
# from the note under `renderings: [light, dark]`, so each color mode shows its
# own version (see notes/example-note.qmd). Do not give that chunk a `fig-`
# label: Quarto then numbers the two renderings as separate figures (Figure 1
# and Figure 2; Quarto 1.10.19), so it cannot be cross-referenced with @fig-.

#' Colors for one color mode of the notes
#'
#' Palette order: blue and vermilion first, since they keep >= 3:1 against
#' both grounds and most figures use only the first two or three colors. Green
#' and orange fall below 3:1 on white (2.6 and 2.2). The last slot is a neutral
#' that swaps with the mode (near-black on light, gray80 on dark).
note_tokens <- function(mode = c("light", "dark")) {
  mode <- match.arg(mode)
  palette <- c("#0072B2", "#DD5129", "#43B284", "#FF9400", "#8C8984")
  switch(
    mode,
    light = list(
      ink = "#1a1a1a",
      paper = "#ffffff",
      accent = "#2c5a43",
      palette = c(palette, "#030A10")
    ),
    dark = list(
      ink = "#ffffff",
      paper = "#1a1a1a",
      accent = "#7db394",
      palette = c(palette, "#CCCCCC")
    )
  )
}

theme_note <- function(mode = c("light", "dark"), base_size = 11) {
  mode <- match.arg(mode)
  tokens <- note_tokens(mode)
  ggplot2::theme_minimal(
    base_size = base_size,
    ink = tokens$ink,
    paper = tokens$paper,
    accent = tokens$accent
  ) +
    ggplot2::theme(
      palette.colour.discrete = tokens$palette,
      palette.fill.discrete = tokens$palette
    )
}

#' Light and dark versions of one figure, for `renderings: [light, dark]`
note_figure_pair <- function(plot) {
  list(
    light = plot + theme_note("light"),
    dark = plot + theme_note("dark")
  )
}
