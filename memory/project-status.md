---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-09-11
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

**次に行う作業（1 つ）**: なし。commit `00aaf7e` のレビュー指摘を README「前提ツール」と SETUP 手順 0 に反映済み（jarl CLI の版指定導入・PATH と版の確認）。未コミット。

**現在の方針**: ロケール固定（`LC_COLLATE=C` / `LC_TIME=C`）、`gittargets` によるストア保全、`renv` 版管理。詳細は [CLAUDE.md#R-プロジェクト共通パターン](CLAUDE.md) を参照。

**試して失敗したこと**: `.codex/config.toml` への直接書き込みは Codex の読み取り専用保護で拒否。Claude Code 側が代行適用し、Codex で再検証済み。

**未確認の項目**: GitHub Actions 上の lint job 実行、新規環境での uv による CLI インストール。レビュー対象 commit `00aaf7e` と HEAD `2c21dbf` のコミット済みファイル内容は一致。

**最後に実行した検証**: 2026-09-11 手順追加後に `jarl --version` → 0.6.0、`jarl check .` → All checks passed、`git diff --check` → 問題なし。既存 CLI を使用し、端末への再インストールは行っていない。

---

## 現在の状態

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照
