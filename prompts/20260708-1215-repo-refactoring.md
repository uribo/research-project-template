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

## Follow-up: reproducibility enhancements (referencing ~/Documents/1_Projects/2606_llm-repro)

User asked for ideas to further raise analysis reproducibility, then pointed to
the in-progress `2606_llm-repro` project (a paper whose topic IS reproducibility
of LLM-assisted research) as a reference. Extracted its proven patterns and,
via AskUserQuestion, adopted 3 of 4 proposed scaffolds (devcontainer deferred):

1. **Provenance verification for frozen raw data** (mirrors llm-repro's
   `data-raw/PROVENANCE.md` with per-file md5):
   - `data-raw/PROVENANCE.md`: manifest table (file / sha256 / rows / source /
     retrieved / license / re-derivation) with a real, verified entry for the
     example CSV.
   - `R/data_provenance.R`: `sha256_file()` (base `tools::sha256sum()`, no new
     dependency) + `verify_provenance(path, sha256)` — fail-loud on mismatch or
     missing file, returns path invisibly for piping into a reader.
   - Wired into `_targets.R` `example_raw_file` target.
   - `tests/testthat/test-data-provenance.R` (4 cases).
   - `.gitignore`: allowlist `data-raw/PROVENANCE.md` (was ignored by data-raw/**).
2. **Reproducibility hierarchy in CLAUDE.md** (pin > pin-ref > freeze; freeze =
   last resort; always keep a re-derivation script) + provenance-verification
   subsection. Makes the template self-contained (previously only in global
   CLAUDE.md).
3. **Environment pinning**: `.Rprofile` sets `LC_COLLATE=C` (wrapped in
   invisible() to avoid stray startup output) and `TZ=Asia/Tokyo`;
   `notes/example-note.qmd` gains a `sessioninfo::session_info()` appendix.

Verified: all R/qmd/.Rprofile parse; provenance helper logic checked in base R
(hash match/mismatch/missing all behave); `renv::dependencies()` now also
discovers `sessioninfo`; air format clean; `.Rprofile` applies TZ/collate with
no stray output. Full `tar_make()` still delegated to CI (targets not installed
locally in the template checkout).

作業終了: 2026-07-08 12:22
再現性強化 追記: 2026-07-08 12:38
