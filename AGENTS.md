# Codex project instructions

Read and follow `CLAUDE.md` as the primary source of project knowledge and conventions. The rules below add Codex-specific security constraints.

## Credential handling

- Never read, edit, print, search, summarize, or otherwise expose `.Renviron`, `.env`, credential JSON files, private keys, or files whose purpose is to store secrets.
- Safe templates such as `Renviron.example` may be read and edited, but must contain placeholders only.
- Do not bypass `.codex/config.toml` environment filtering or override `R_ENVIRON_USER` unless the user explicitly approves access for a specific task.
- If a task needs authenticated API access, explain which credential or environment variable is required and obtain approval before enabling it. Never include credential values in prompts, logs, command output, or commits.
