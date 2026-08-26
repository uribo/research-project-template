---
name: project-status
description: 現在の進捗・直近の作業・次のステップ
type: project
updated: {{DATE}}
---

# {{PROJECT_NAME}} — Status

## 引き継ぎ（HANDOFF）

> 別のエージェント（Codex 等）や次のセッションが**この欄だけ読めば再開できる**状態を保つ。残すのは今使っている判断だけで、検討しただけの案は書かない。方針を決めた時・試行を捨てた時・検証を実行した時・セッションを終える時に更新する。

- **現在採用している方針**: renv.config.auto.snapshot と renv-update workflow を維持（凍結しない）。targets がパッケージ版を cue に含めない隙間は「2+3 戦略」で埋める：(2) `tar_option_set(imports = c(...))` に数値結果を左右するパッケージを明示して機械的に invalidate、(3) lockfile 更新を再ビルド契機として `_targets.R` 運用規律に明文化。gittargets スナップショットは「merge 前に旧コミットで取得 → 再ビルド → merge 後に新コミットで再取得」の前後 2 回・別コミット運用。renv-update workflow の PR 本文に merge 後の `tar_make()` リマインダを追加。理由: パッケージ版ドリフト検出の多層防御（CI での sentinel test、明示的 import cue、再ビルド規律、スナップショット前後検査）により「意図しない結果変化」を fail-loud で検出可能に。
- **次に行う作業（1 つ）**: commit f71661f (feat(targets): add imports scaffold and post-lockfile-update rebuild discipline) を origin/main へ push する。
- **試して失敗したこと**: prompts/*.md を git 追跡に含めてはいけない。このリポジトリでは 031d8e9 で intentionally gitignore した（テンプレート下流への伝播防止）。auto-committer が `git add -f prompts/` を実行して force-add してしまったため、手動で amend で除去した。以後、prompts/ のファイルを force-add しないこと。
- **未確認の項目**: （なし）
- **最後に実行した検証と結果**: `git log --oneline -1` → `f71661f feat(targets): add imports scaffold ...`; `git diff HEAD~1..HEAD` → CLAUDE.md、_targets.R、renv-update.yaml の変更確認完了；commit は clean（prompts/ 除去確認済み）

- **現在フェーズ**: （要記入: Pre-analysis / Gate 検証 / 実装 / 執筆 …）
- **直近の作業**: （要記入）
- **次のステップ**: （要記入）
- **ブロッカー**: `TODO.md`「横断的ブロッカー」を参照

**How to apply:** セッション終了時に進捗が変化したらこのファイルを更新する。「引き継ぎ（HANDOFF）」欄は方針を決めた時・試行を捨てた時・検証を実行した時にも更新し、Codex 等へ引き継ぐときはこの欄を先に読ませる（グローバル指示「Codex への委任と引き継ぎ」）。
