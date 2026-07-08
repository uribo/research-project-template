# Repository refactoring

## User prompt

> このリポジトリのリファクタリング

## Context

- Target: research-project-template (the template repository itself, not a generated project)
- Scope to be clarified with the user via AskUserQuestion before making changes.

## Referenced external resources

(none)

## Scope decided with the user (AskUserQuestion)

- A: deduplicate docs (README / SETUP / CLAUDE.md single-source) + B: quality fixes
- Drop DESCRIPTION-based dependency management entirely; rely on renv implicit
  discovery (`renv::dependencies()` code scan)

## Changes

- Deleted: `DESCRIPTION`, `.Rbuildignore`, `.claude/.gitkeep`
- CI (`R-check.yaml`): install dependencies via `renv::dependencies()` code scan
  instead of DESCRIPTION + setup-r-dependencies
- `_targets.R`: removed `error = "continue"` (fail-loud; keep default "stop")
- `.gitignore`: `renv/lock/` -> `renv/lock` (it is a file, not a directory)
- Docs single-sourced: commands -> README, directory tree -> CLAUDE.md,
  prerequisite tools -> README (SETUP links); removed `{{AUTHOR}}` placeholder
  (only used by DESCRIPTION)
- CLAUDE.md / SETUP.md rewritten for implicit dependency discovery

## Notes / caveats surfaced

- Packages not appearing in code (interactive-only `gittargets`, commented-out
  `crew`/`mirai`) are no longer auto-tracked; documented in CLAUDE.md
- Local R lacks `targets` (renv not initialized in the template checkout), so
  `tar_validate()`/tests could not run locally; verified by `parse()` on all R
  files, YAML load of the workflow, and `renv::dependencies()` scan
  (discovers all 11 required packages incl. rmarkdown from the qmd). Full
  pipeline validation is delegated to CI.

作業終了: 2026-07-08 12:22
