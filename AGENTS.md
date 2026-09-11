# Codex project instructions

Read and follow `CLAUDE.md` as the primary source of project knowledge and conventions. The rules below add Codex-specific security constraints.

## Credential handling

- Never read, edit, print, search, summarize, or otherwise expose `.Renviron`, `.env`, credential JSON files, private keys, or files whose purpose is to store secrets.
- Safe templates such as `Renviron.example` may be read and edited, but must contain placeholders only.
- Do not bypass `.codex/config.toml` environment filtering or override `R_ENVIRON_USER` unless the user explicitly approves access for a specific task.
- If a task needs authenticated API access, explain which credential or environment variable is required and obtain approval before enabling it. Never include credential values in prompts, logs, command output, or commits.

## Handoff from Claude Code

> **Template maintainers only — delete this note in generated projects.** While this repository *is* the template, `memory/*.md` is shipped rather than private: SETUP.md step 2 replaces its placeholders on generation, so whatever stands in the HANDOFF block becomes the opening state of every generated project. Record this repository's own development state in a GitHub Issue and leave the HANDOFF block as the `（要記入）` skeleton — the rules below then apply to reading it, not to writing it. The maintainer note at the top of `CLAUDE.md` states the same rule for Claude Code. In a generated project this note is gone and the rules below apply as written.

- Before starting, read the "引き継ぎ（HANDOFF）" block at the top of `memory/project-status.md`, then check `git status` and `git diff`. Do not discard existing changes.
- Treat recorded decisions as claims: confirm them against the code and test results before building on them.
- When you finish or stop, update the HANDOFF block (current approach, the single next task, failed attempts, unverified items, last verification command and result).
