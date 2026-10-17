# ggplot2 theme for analysis notes, matched to notes/_brand.yml.
#
# The HTML colors come from _brand.yml; figures are drawn by R and never see
# it, so the values are repeated here. tests/testthat/test-plot-theme.R checks
# that the two stay in sync. Use with `renderings: [light, dark]` so each color
# mode gets its own figure:
#
#   #| renderings: [light, dark]
#   p + theme_note("light")
#   p + theme_note("dark")
#
# Do not give such a chunk a `fig-` label: Quarto then numbers the two
# renderings as separate figures (Figure 1 and Figure 2; Quarto 1.10.19), so the
# figure cannot be cross-referenced with @fig-.

note_tokens <- list(
  light = list(
    ink = "#1a1a1a",
    paper = "#ffffff",
    accent = "#2c5a43",
    # Blue and vermilion first: they keep >= 3:1 against both grounds, and
    # most figures use only the first two or three colors. The last slot is a
    # neutral that swaps with the mode (near-black here, gray80 in dark mode).
    palette = c(
      "#0072B2",
      "#DD5129",
      "#43B284",
      "#FF9400",
      "#8C8984",
      "#030A10"
    )
  ),
  dark = list(
    ink = "#ffffff",
    paper = "#1a1a1a",
    accent = "#7db394",
    palette = c(
      "#0072B2",
      "#DD5129",
      "#43B284",
      "#FF9400",
      "#8C8984",
      "#CCCCCC"
    )
  )
)

theme_note <- function(mode = c("light", "dark"), base_size = 11) {
  mode <- match.arg(mode)
  tokens <- note_tokens[[mode]]
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
