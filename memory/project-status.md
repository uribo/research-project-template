---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-09-11
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

**次に行う作業（1 つ）**: PR #9 の CI（lint job 含む）が通ることを確認し、merge する。詳細は https://github.com/uribo/research-project-template/pull/9

**最後に実行した検証**: chore/adopt-jarl-lint ブランチで jarl 0.6.0 `jarl check .` → All checks passed。依存宣言スコープ抑制と到達不能コード検出を確認。PR 作成後は CI 実行待ち。

**現在採用している方針**: jarl v0.6.0 による lint（air フォーマットと併用）、ロケール固定（`LC_COLLATE=C` / `LC_TIME=C`）、`gittargets` によるストア保全。詳細は CLAUDE.md「R コード記述」と「R プロジェクト共通パターン」。

**試して失敗したこと**: `.codex/config.toml` への直接書き込みは Codex の読み取り専用保護で拒否。Claude Code 側が代行適用し、Codex で再検証済み（既解決）。

**未確認の項目**: GitHub Actions 上の新設 lint job の実行結果、新規環境での jarl CLI インストール手順。

---

## 現在の状態

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照
