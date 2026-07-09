# renv environment variables / configuration survey

## User prompt

> renvの環境変数や設定について、指定しておいたほうが良さそうな項目はないでしょうか。
> /context7-cli を用いて調査してください。なお、あなたは指示役として働き、調査はCodexに委任して実行してください。

## Context

- Target: research-project-template. The user has just added to `.Rprofile`
  (after renv activation):
  `options(renv.config.auto.snapshot = TRUE, renv.config.pak.enabled = TRUE)`
- Claude acts as director; the investigation runs on Codex (codex-rescue
  subagent) using the ctx7 CLI (`npx ctx7@latest library` / `docs`).

## Referenced external resources

- Context7 documentation index for renv (via ctx7 CLI) — **all queries failed**
  in the Codex sandbox (network blocked: ENOTFOUND registry.npmjs.org /
  fetch failed). Codex fell back to the official renv reference:
  - https://rstudio.github.io/renv/reference/config.html
  - https://rstudio.github.io/renv/reference/settings.html
  - https://rstudio.github.io/renv/reference/paths.html
  - https://rstudio.github.io/renv/reference/snapshot.html
  - https://rstudio.github.io/renv/reference/dependencies.html
  - https://rstudio.github.io/renv/articles/package-install.html

## Delegation trail

Codex delegation failed twice before succeeding, both environment issues:
(1) Codex CLI 0.46.0 too old for the backend model — replaced local Homebrew
formula with cask 0.143.0 (user-approved, user ran the brew commands);
(2) stale shared Codex broker from before the upgrade kept reporting
`loggedIn: false` even after `codex login` — killed the old broker +
app-server child; runtime respawned and a smoke task passed.

## Findings (verified locally against renv 1.2.3)

- Config resolution: R option > `RENV_CONFIG_*` env var > default; options in
  a project `.Rprofile` must be set BEFORE `source("renv/activate.R")`.
  The user's `options()` block was after activation — moved before.
- Defaults verified with `Rscript --vanilla`: `auto.snapshot=FALSE`,
  `pak.enabled=FALSE`, `dependency.errors="reported"`.
- `auto.snapshot=TRUE` tension with lockfile-as-source-of-truth was flagged;
  user chose to keep it (convenience; review lockfile diffs before commit).
- Added `renv.config.dependency.errors="fatal"` (no DESCRIPTION → the code
  scan is the only dependency declaration).
- **Correction to the doc-based advice, found by testing**: the config option
  does NOT change the default of a direct `renv::dependencies()` call
  (formals pin `errors = c("reported","fatal","ignored")`), and
  `quiet = TRUE` suppresses even an explicit fatal. The config applies to
  renv-internal implicit scans (snapshot/status). CI therefore switched from
  `quiet = TRUE` to `errors = "fatal", progress = FALSE`.
- Not adopted (defaults already correct; avoid cargo-culting):
  synchronized.check / install.transactional / sandbox.enabled / ppm.enabled
  (TRUE), updates.check (FALSE), `renv::settings$snapshot.type("implicit")`.
  `RENV_PATHS_CACHE` is machine/user scope — not set in the template.

作業終了: 2026-07-09 11:28
