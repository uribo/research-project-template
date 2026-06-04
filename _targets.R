library(targets)

targets::tar_option_set(
  packages = c(
    "dplyr",
    "readr",
    "tibble",
    "pointblank"
  ),
  format = "rds",
  error = "continue"
  # Parallel execution with crew + mirai (uncomment when needed):
  # controller = crew::crew_controller_local(workers = 4)
)

# Auto-load every function defined under R/.
targets::tar_source("R")

# Core pipeline (no Quarto dependency). These targets are the ones exercised
# by CI and by template verification.
core_targets <- list(
  tar_target(
    example_raw_file,
    "data-raw/example/penguins-sample.csv",
    format = "file",
    description = "Example の生データ CSV パス（format=\"file\" で宣言）"
  ),
  tar_target(
    example_data,
    validate_example_data(read_example_data(example_raw_file)),
    description = "Example データの読み込みと意味的検証"
  ),
  tar_target(
    example_summary,
    summarise_example(example_data),
    description = "種ごとの観測数・平均値の集計"
  )
)

# Quarto note target. tar_quarto() inspects the .qmd via the Quarto CLI at
# pipeline-construction time, so it is only added when the CLI is available.
# This keeps tar_validate()/tar_make() working in environments without Quarto
# (e.g. CI). Render it locally with `quarto --version` installed.
quarto_available <- nzchar(Sys.which("quarto")) &&
  requireNamespace("quarto", quietly = TRUE)

if (quarto_available) {
  quarto_targets <- list(
    tarchetypes::tar_quarto(
      example_note,
      path = "notes/example-note.qmd",
      description = "Example 分析ノート（Data Reference Policy 実演）"
    )
  )
} else {
  quarto_targets <- list()
}

c(core_targets, quarto_targets)
