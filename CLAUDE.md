@AGENTS.md

## Claude Code 固有の設定

> プロジェクトの規約は [AGENTS.md](AGENTS.md) が正典で、上の 1 行の import で全文が読み込まれる。**このファイルに書いた内容は Codex には届かない**ので、両方のエージェントに効かせたい規約は AGENTS.md 側に書く。規約を足す場所を迷ったら AGENTS.md を選ぶ。

### Skills

R コード記述・レビュー時、原稿作成時、文献検索時などにスキルを活用する。プロジェクトで利用するものをここに列挙する（例）:

- `/r-modern-tidyverse`: R コード記述時。superseded パターンの回避を徹底
- `/r-rlang-programming`: tidyverse 関数をラップする関数を書く際
- `/sciwrite`: 英語原稿・Abstract・rebuttal の作成・レビュー
- `/openalex`: DOI・著者・キーワードから書誌情報を取得
- `/commit-msg`: Conventional Commits 形式のコミットメッセージ起案

### サブエージェント

- `auto-committer`: 作業単位の完了時に自律的にコミット（Conventional Commits 準拠）
- `memory-updater`: 方針を決めた時・試行を捨てた時・検証を実行した時・PR を作成した時・セッションを終える時に `memory/project-status.md` の HANDOFF 欄を更新

### hook（`.claude/settings.json`）

Claude Code 経由の操作にだけ効く層。ターミナルからの操作には `.githooks/pre-commit` が対応する二層構成になっている。

- **PreToolUse（Bash）**: `renv.lock` を含むコミットでパッケージ差分を示して承認を求める / `AGENTS.md` が Codex の 32 KiB 上限を超えていないか検査する
- **PostToolUse（Edit・Write）**: `.R` / `.qmd` を `air format` で整形
- **Stop**: `renv::status()` の drift を報告

### `.claude/rules/`

パス指定（`paths:` frontmatter）で必要なときだけ読み込むルールを置ける。**Codex には対応する機構が無い**ため、ここに置いた内容は Claude Code 限定になる。作者の環境では R プロジェクト共通の規約をユーザースコープ（`~/.claude/rules/`）に置いているので、それと重複する内容をプロジェクト側で持たない。
