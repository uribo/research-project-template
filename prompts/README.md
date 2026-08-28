# prompts/

Claude → Codex の**委任ブリーフ**置き場（`CLAUDE.md`「Delegation Brief Rule」）。通常作業のプロンプトログは保存しない。現在の状態は `memory/project-status.md` の HANDOFF、問題・捨てた方法は Issue / `TODO.md`、変更理由は commit message に書く。

- 命名: `YYYYMMDD-HHMM-<topic>.md`（JST: `TZ=Asia/Tokyo date '+%Y%m%d-%H%M'`）
- 内容: 元の依頼、スコープと除外、受け入れ条件、既知の制約、検証すべき既存判断、参照 URL、要求する検証手順
- 作成したら HANDOFF にパスを書く。Codex はこのディレクトリを自動では読まない

`*.md` は `.gitignore` でローカルのプロセス記録として扱い、既定では **git 管理しない**（この README のみ追跡）。ブリーフもバージョン管理したい場合は `.gitignore` の `prompts/*.md` 行を外す。
