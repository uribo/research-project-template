---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: 2026-08-26
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

> 別のエージェント（Codex 等）や次のセッションが**この欄だけ読めば再開できる**状態を保つ。残すのは今使っている判断だけで、検討しただけの案は書かない。方針を決めた時・試行を捨てた時・検証を実行した時・セッションを終える時に更新する。

- **現在採用している方針**: renv パッケージ版ドリフト対策は「版ピン留めターゲット + rebuild 規律 + snapshot 前後検査」。**imports の脚は撤回**（2026-08-26: `pkg::fun()` スタイルでは `tar_option_set(imports)` が不活性 — `tar_deps(coxme::coxme(x))` は関数シンボルを返さない実測。survival / glmmTMB / emmeans は名前空間単体で DAG 循環。修正は template 0d2030d、詳細は wm_patch#32 のコメント）。代替は `tar_target(model_pkg_versions, ...)` を結果直結ターゲットへブレース参照で配線する版ピン。加えてテンプレート → 下流プロジェクト（8 repo）への横断展開を進行中。運用方針：各変更は CI・ドキュメント整合の確認後に下流へ展開。追跡台帳は wm_patch#32。展開実績（初回＋版ピン修正）：template（f71661f→0d2030d）・2603_redlist（6045b0d→d6b9a15）・2607_tokushima_tourism_flow（fff65f5→886316c）・2607_tu_carsharing（0d4bf92→f85e96f）・2607_dc-siting-jp（982c16c→ba10b07）・2509_tokushima_sss（81eeb4e、雛形のみ・配線は報告書フェーズ明け）・2603_vr-sickness-vibration（cafe3ee、model_pkg_versions ターゲット能動追加・配線は段階的）。注意：prompts/ は gitignore 対象・force-add 禁止（031d8e9 で intentionally 無視、過去に amend で除去経験あり）。理由: テンプレート採用プロジェクトへの誤った伝播防止。
- **次に行う作業（1 つ）**: 修正コミット群（template 0d2030d ほか 6 repo）の push（ユーザー確認待ち）。その後の残件は wm_patch#32 の 2602_biolingua（gittargets 順序ルールのみ）だけ。
- **試して失敗したこと**: prompts/*.md を force-add してはいけない。本リポジトリで auto-committer が `git add -f` で追跡に入れてしまい、amend で除去した（2026-08-26）。auto-committer へ委任する際はプロンプトで prompts/ を対象外と明示する。
- **未確認の項目**: （なし）
- **最後に実行した検証と結果**: 版ピン修正後、全対象 repo で `parse("_targets.R")` OK。vr は `tar_outdated()` が復旧し（imports 有効化時は DAG 循環でエラーだった）、outdated は既存の fig_cop_video_onset_panels と新設 model_pkg_versions のみ＝モデルターゲットの invalidate なし。2509 は `tar_validate()` OK。wm_patch#32 に発見コメント・解決コメント・チェックリスト更新済み。

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照

**How to apply:** セッション終了時に進捗が変化したらこのファイルを更新する。「引き継ぎ（HANDOFF）」欄は方針を決めた時・試行を捨てた時・検証を実行した時にも更新し、Codex 等へ引き継ぐときはこの欄を先に読ませる（グローバル指示「Codex への委任と引き継ぎ」）。
