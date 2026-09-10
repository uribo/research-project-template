---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-09-10
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

**次に行う作業（1 つ）**: なし（テンプレート整備は完了。生成済みプロジェクトの HANDOFF 圧縮は任意タイミングで、handoff-guard hook が編集時に超過を警告する）。

**現在の方針**: ロケール固定（`LC_COLLATE=C` / `LC_TIME=C`）、`gittargets` によるストア保全、`renv` 版管理。詳細は [CLAUDE.md#R-プロジェクト共通パターン](CLAUDE.md) を参照。

**試して失敗したこと**: `.codex/config.toml` への直接書き込みは Codex の読み取り専用保護で拒否。Claude Code 側が代行適用し、Codex で再検証済み。

**未確認の項目**: （なし）

**最後に実行した検証**: 2026-09-01 全設定検証（commit 539bfe8）、2026-09-10 に HANDOFF を 40 行以内のポインタ運用へ改訂（CLAUDE.md「引き継ぎ（HANDOFF）欄の運用」節、commit 7374be3）。handoff-guard.sh は 4 ケースの自己テストで期待どおり。

---

## 現在の状態

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照
