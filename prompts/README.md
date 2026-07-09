# prompts/

Claude Code の作業ログ。1 セッション = 1 ファイルを目安に、最初のプロンプトを保存してから作業を始める（`CLAUDE.md`「Prompt Logging Rule」）。

- 命名: `YYYYMMDD-HHMM-task-name.md`（JST）
    - `TZ=Asia/Tokyo date '+%Y%m%d-%H%M'`
- 冒頭にユーザーのプロンプト全文、参照した URL・タイトル・要約を記録
- 末尾に `作業終了: YYYY-MM-DD HH:MM` を記述

各セッションログ（`*.md`）は `.gitignore` でローカルのプロセス記録として扱い、既定では **git 管理しない**（この README のみ追跡）。ログもバージョン管理したい場合は `.gitignore` の `prompts/*.md` 行を外す。
