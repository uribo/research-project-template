---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-09-01
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

> 別のエージェント（Codex 等）や次のセッションが**この欄だけ読めば再開できる**状態を保つ。残すのは今使っている判断だけで、検討しただけの案は書かない。方針を決めた時・試行を捨てた時・検証を実行した時・セッションを終える時に更新する。

- **現在採用している方針**: 委任ブリーフ `prompts/20260901-2231-fix-record-guidance-and-lctime-layer2.md` に従い、gittargets の renv 記録手順を明示参照 + `renv::install()` + `renv::snapshot()` に修正し、ロケール層 2 の `.claude/settings.json` と `.codex/config.toml` に `LC_TIME=C` を追加した。`_targets.R` の雛形は、gittargets 未導入のテンプレートで暗黙依存を発生させないため追加しない。
- **次に行う作業（1 つ）**: ユーザーが未コミット差分をレビューする。
- **試して失敗したこと**: `.codex/config.toml` への `apply_patch` は `writing outside of the project; rejected by user approval settings` で拒否された。`test -w .codex/config.toml` と `test -w .codex` はいずれも失敗し、他の許可対象ファイルとは異なり実行環境側で読み取り専用だった。制約を回避する書き込みは行っていない。Codex CLI が自身の設定ファイルを保護しているためであり、当該 1 ファイルは Claude Code 側が代行適用し、内容は Codex が現物で再検証した。
- **未確認の項目**: なし。
- **最後に実行した検証と結果**: 委任ブリーフ指定の検証一式を実行。JSON/TOML は構文正常、`LC_TIME` は層 1・2・3 に存在、`LC_ALL` は禁止・説明の既存記述と追加した禁止コメントだけ、`renv::record()` は使用禁止と「では直らない」の否定文だけ、R のロケールは `C C`、変更は許可された4ファイルだけだった（2026-09-01 JST）。

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照

**How to apply:** セッション終了時に進捗が変化したらこのファイルを更新する。「引き継ぎ（HANDOFF）」欄は方針を決めた時・試行を捨てた時・検証を実行した時にも更新し、Codex 等へ引き継ぐときはこの欄を先に読ませる（グローバル指示「Codex への委任と引き継ぎ」）。
