# Prompt

renv-update workflow のレビュー継続。二点。

1. テンプレートから作った複数プロジェクトが同一 cron 時刻に一斉発火し、月曜朝に PR がまとまってレビュー・merge の手数が増える。→ 方針 A（発火タイミングの分散）を採用。
2. renv でパッケージバージョンが更新されると再現性検証が必要になるが、targets パイプラインはパッケージバージョンに関わらず当時のキャッシュでパイプラインを通すため、再現性の面でジレンマがある。

## 決定・実装

- **分散方式**: SETUP 時に cron へ焼き込むのではなく、リポジトリ名（`GITHUB_REPOSITORY`）のハッシュから曜日を導出するランタイム・ゲート方式を採用。cron を日次に変更し、`gate` ジョブが「今日がこのリポジトリの割当曜日か」を判定して `update` ジョブを条件実行する。ゼロ設定で各プロジェクトが別曜日に分散する。
- `workflow_dispatch`（手動起動）はゲートを常に通過。

## 再現性ジレンマの整理（分析・ドキュメント方針）

- `targets::tar_validate()` は DAG の妥当性のみ検査し、再実行も数値再現性検証もしない。
- targets はデフォルトでパッケージのバージョンをキュー（cue）に含めないため、renv のバージョン更新だけでは既存ターゲットが無効化されない。→「パイプラインが通る」≠「新バージョンで結果が再現する」。
- CI は `data-raw/`（gitignored）を持たないため、数値再現性の完全検証は CI 単独では不可能。
- ライフサイクルで解消: renv-update は開発フェーズの依存衛生ツール。原稿投稿後は freeze（グローバル CLAUDE.md「as-submitted 凍結」方針と整合）。
- 数値ドリフトを fail-loud 化したいなら、主要な導出値を testthat/pointblank のスナップショット/許容誤差テストとして commit し、workflow の tests ステップで走らせる。バージョン更新が結果を変えたら PR が赤くなる。

## 実装結果（(c) 採用）

- 「除外」ではなく「差し替え」が正解。テンプレートは既に `data-raw/example/**` を gitignore 例外として commit しており、core パイプラインは committed fixture で CI 完走できる。
- targets はパッケージ版を cue に含めないので、数値アサーションを testthat に置くことで cue 挙動と無関係に drift を捕捉する。
- 追加: `tests/testthat/test-reproducibility.R` — committed fixture（penguins 12 行）に対し `read → validate → summarise` を通し、種ごとの n_obs / mean を許容誤差 1e-8 でピン留め。`Rscript tests/testthat.R` で 17 PASS 確認。
- ドキュメント: SETUP.md 手順 8（sentinel を自プロジェクト版に置換する指示 + git rm 対象に追加）、CLAUDE.md 再現性セクション（sentinel パターン + 投稿後 freeze 運用）を追記。
- 分散（方針 A）: cron 日次化 + `gate` ジョブ（repo 名ハッシュで曜日割当）。手動 dispatch は常に通過。

## Codex レビュー反映（小修正 3 点）

1. 曜日 gate を JST に統一: `date -u +%w` → `TZ=Asia/Tokyo date +%w`。cron 19:17 UTC = 04:17 JST で日付が 1 日進むため、人間の JST レビュー感覚と曜日を揃えた。header/コメント/echo も JST 表記に。
2. sentinel の限界を明示: `test-reproducibility.R` 冒頭に「代表 fixture の drift 検出であり、通っても論文完全再現ではない（CI に本番データ無し）」を追記。CLAUDE.md にも同旨を追加。
3. 投稿後 freeze は「PR 無視」→「workflow disable 推奨」に変更（`gh workflow disable renv-update` / schedule コメントアウト）。再開は `workflow_dispatch`。CLAUDE.md 更新。
- `workflow_dispatch` の入力は追加せず（hash gate のゼロ設定価値を保つ）。
- 再確認: YAML OK / JST dow≠UTC dow を実機確認 / testthat 17 PASS。

## Notes

- JST timestamp: 2026-07-10 03:41
- External resources: not consulted.

作業終了: 2026-07-10 03:41
