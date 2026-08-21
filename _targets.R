library(targets)

targets::tar_option_set(
  packages = c(
    "dplyr",
    "readr",
    "tibble",
    "pointblank"
  ),
  format = "rds"
  # error = "stop" (the default): a failing target halts the pipeline. Do not
  # switch to "continue"; it hides failures and breaks the fail-loud principle.
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
    verify_provenance(
      "data-raw/example/penguins-sample.csv",
      "71653a432f48da60de096a74221e5db85bb68a5c3ff6bd9fabd19a1645e924a3"
    ),
    format = "file",
    description = "Example の生データ CSV パス（sha256 provenance 検証つき）"
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

# Quarto note targets. tar_quarto() inspects the .qmd via the Quarto CLI at
# pipeline-construction time, so these are only added when the CLI is
# available, which keeps tar_validate()/tar_make() working without Quarto
# installed. CI installs Quarto so that the full DAG is validated there; this
# guard is for local checkouts that do not have it.
quarto_notes <- c("notes/example-note.qmd")

quarto_available <- nzchar(Sys.which("quarto")) &&
  requireNamespace("quarto", quietly = TRUE)

if (quarto_available) {
  quarto_targets <- list(
    tarchetypes::tar_quarto(
      example_note,
      path = quarto_notes[[1]],
      description = "Example 分析ノート（Data Reference Policy 実演）"
    )
  )
} else {
  # Say what is being left out. A target that disappears from the DAG without
  # a word makes a green tar_validate() mean less than it appears to: the
  # pipeline that passed is not the pipeline the project has.
  message(
    "Quarto CLI or the quarto package is unavailable; excluding ",
    length(quarto_notes),
    " Quarto target(s) from the pipeline: ",
    paste(quarto_notes, collapse = ", ")
  )
  quarto_targets <- list()
}

c(core_targets, quarto_targets)
