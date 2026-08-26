---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-08-26
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

> 別のエージェント（Codex 等）や次のセッションが**この欄だけ読めば再開できる**状態を保つ。残すのは今使っている判断だけで、検討しただけの案は書かない。方針を決めた時・試行を捨てた時・検証を実行した時・セッションを終える時に更新する。

- **現在採用している方針**: renv パッケージ版ドリフト対策は「2+3 戦略」の 3 層防御で継続（imports cue + rebuild 規律 + snapshot 前後検査）。加えてテンプレート → 下流プロジェクト（8 repo）への横断展開を進行中。運用方針：各変更は CI・ドキュメント整合の確認後に下流へ展開。追跡台帳は wm_patch#32。展開実績：2603_redlist-multiscale-bias（6045b0d、パイロット）・2607 系 3 repo 完了（2607_tokushima_tourism_flow fff65f5、2607_tu_carsharing 0d4bf92、2607_dc-siting-jp 982c16c）。各 repo に 4 つの変更（_targets.R imports 雛形・CLAUDE.md の imports 規約＋再ビルド規律＋gittargets 順序・renv-update.yaml PR 本文）を適用して push 済み。注意：prompts/ は gitignore 対象・force-add 禁止（031d8e9 で intentionally 無視、過去に amend で除去経験あり）。理由: テンプレート採用プロジェクトへの誤った伝播防止。
- **次に行う作業（1 つ）**: wm_patch#32 の残件 — 2509_tokushima_sss（フェーズ確認が先）、2603_vr-sickness-vibration（フェーズ確認 → 開発継続なら imports）、2602_biolingua（gittargets 順序ルールのみ）。各プロジェクトの次回セッション時でよい。
- **試して失敗したこと**: prompts/*.md を force-add してはいけない。本リポジトリで auto-committer が `git add -f` で追跡に入れてしまい、amend で除去した（2026-08-26）。auto-committer へ委任する際はプロンプトで prompts/ を対象外と明示する。
- **未確認の項目**: （なし）
- **最後に実行した検証と結果**: 2607 系 3 repo の push 完了。全 repo で `parse("_targets.R")` OK。`tar_validate()` は tourism_flow / dc-siting-jp でエラーなし。tu_carsharing はローカル renv 環境の既存問題（今回の変更と無関係）のため実行不可。wm_patch#32 台帳のチェックリスト・対象一覧も更新済み。

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照

**How to apply:** セッション終了時に進捗が変化したらこのファイルを更新する。「引き継ぎ（HANDOFF）」欄は方針を決めた時・試行を捨てた時・検証を実行した時にも更新し、Codex 等へ引き継ぐときはこの欄を先に読ませる（グローバル指示「Codex への委任と引き継ぎ」）。
