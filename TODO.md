# {{PROJECT_NAME}} — TODO / マイルストーン

> 申請戦略・マイルストーン・横断的ブロッカーの単一ソース。日次の細かい作業ログはここではなく作業ログ（`prompts/` または外部 vault）に残し、本ファイルは「意思決定・到達点・残作業」を集約する。

## ステータス概要

| 項目 | 状態 |
|---|---|
| 現在フェーズ | （Pre-analysis / Gate 検証 / 実装 / 執筆 …） |
| 直近の成果 | （要記入） |
| 残作業 | （要記入） |
| ブロッカー | （要記入。詳細は末尾「横断的ブロッカー」） |

## Go / No-go ゲート（実装着手前の前提検証）

本格的な実装に進む前に以下を確認する。**いずれかが通らなければ実装を停止し、設計を改訂する。** 各ゲートの検証結果は `notes/` に短い QMD として記録し、GitHub Issue で進捗管理する。

各ゲートは固定欄（`Threshold` / `Decision` / `Evidence` / `Owner` / `Date` / `Next action`）で意思決定を残す。後から研究ログとして辿れることを優先する。

### Gate 0 — データ取得可否

対象データが実際に取得・利用可能か（ライセンス・カバレッジ・粒度を含む）を確認する。

- **Threshold**: 主解析に必要なデータが対象期間・対象範囲で取得可能であること
- **Decision**: ⬜ Go / ⬜ No-go / ⬜ 未判定
- **Evidence**: （`notes/gate0_*.qmd`、取得スクリプト、サンプルデータの確認結果）
- **Owner**: 
- **Date**: 
- **Next action**: 

### Gate 1 — 検出力・サンプルサイズ

期待効果量・有意水準・分散の前提下で、検出可能な最小効果（MDE）が目標を満たすサンプルサイズを確保できるか。

- **Threshold**: power ≥ 0.80 / α = 0.05 で MDE ≤（目標効果量）
- **Decision**: ⬜ Go / ⬜ No-go / ⬜ 未判定
- **Evidence**: （`notes/gate1_power.qmd` のシミュレーション結果）
- **Owner**: 
- **Date**: 
- **Next action**: 

### Gate 2 — 測定の十分性

主アウトカム・主説明変数の観測量（カバレッジ・観測努力量）が、目的の推定単位・解像度で十分か。

- **Threshold**: （推定単位 × 時点での最小観測数などを記入）
- **Decision**: ⬜ Go / ⬜ No-go / ⬜ 未判定
- **Evidence**: （`notes/gate2_*.qmd`）
- **Owner**: 
- **Date**: 
- **Next action**: 

### Gate 3 — 妥当性・頑健性

同定戦略の前提（並行トレンド・無交絡・測定誤差など）が成り立つか、感度分析で頑健性が確認できるか。

- **Threshold**: （pre-trend test、閾値感度、代替仕様で主結論が反転しないこと等）
- **Decision**: ⬜ Go / ⬜ No-go / ⬜ 未判定
- **Evidence**: （`notes/gate3_*.qmd`）
- **Owner**: 
- **Date**: 
- **Next action**: 

## Phase とマイルストーン

| Phase | スコープ | 完了タグ | 状態 |
|---|---|---|---|
| Phase 1 | （preliminary / 最小実証） | `v1.0-*` | ⬜ |
| Phase 2 | （拡張） | `v2.0-*` | ⬜ |
| Phase 3 | （一般化 / 方法論） | `v3.0-*` | ⬜ |

## タスク

### 最優先（Go/No-go ゲート）

- [ ] Gate 0: データ取得可否の確認
- [ ] Gate 1: 検出力シミュレーション
- [ ] Gate 2: 測定の十分性評価
- [ ] Gate 3: 妥当性・頑健性チェック

### Phase 1 実装

- [ ] （要記入）

## GitHub Issues

- Issue 番号体系: `[Phase-Gate/Task]` プレフィックス（例: `[1-G1] 検出力シミュレーション`）
- ゲート検証タスクは `notes/` に QMD として記録し Issue で管理

## 横断的ブロッカー

- [ ] （データ・分担者・計算資源・倫理審査などの横断的ブロッカーを記入）

---

## テンプレート保守メモ（テンプレート専用 — 生成先では本節ごと削除する）

> ここから下はテンプレートリポジトリ自身の残作業。生成したプロジェクトには関係しないので、SETUP.md 手順 8 でこの節を削除する。規約そのものは `AGENTS.md` に成文化済みで、ここに置くのは「下流へ配り終えたか」の台帳だけ。

### 版タグと下流への追従（バッジの運用）

- 下流に波及させたい変更が入ったら、テンプレートに `vYYYY.MM.DD` 形式のタグを打ち、Release Notes に「何が変わったか・どう当てるか」を書く。**適用手順は Release Notes 側に置き、この節に台帳を増やさない**
- 生成先は `.template-version` に生成元のタグを持ち、README の `template` バッジがその値と `compare/<tag>...main` へのリンクを表示する（手順は `SETUP.md` 手順 2 と `README.md`）。取り込みは任意で、義務ではない
- 手元の生成先の適用状況は一覧できる（repo は `~/Documents/<PARA>/<repo>` の 2 階層目にある。`grep` はテンプレート自身の未置換行を除く）:

```bash
for d in ~/Documents/*/*/; do
  [ -f "$d/.template-version" ] && printf '%s\t%s\n' "$(basename "$d")" "$(cat "$d/.template-version")"
done | grep -v '{{'
```

- 既存の生成先への適用は Issue #15 で完了した（2026-09-18 クローズ。4 件適用、`aratame` は対象外）。作業単位と値の決め方（初回コミットとテンプレート履歴の突き合わせ）は #15 に残してある。今後生成する repo には `SETUP.md` 手順 2 で入るので、台帳は持たない
- バッジは自分では赤くならない。「記録した版より新しいタグがある」を検知させるなら workflow を足して status badge にするが、現時点では作らない

### Delegation Brief Rule の下流波及

- **波及は任意**（2026-08-28 ユーザー判断）。生成済みプロジェクトは旧「Prompt Logging Rule」のままでも許容する。テンプレート側の切り替えは `81692ea` で完了している
- 波及するときの作業単位: 対象 repo の `AGENTS.md`（旧 `CLAUDE.md`）「Prompt Logging Rule」節と `prompts/README.md` をテンプレート `81692ea` に合わせ、`.gitignore` に `prompts/*.md` と `!prompts/README.md` を足し、既に追跡済みのログを `git rm --cached` で外す（ローカルのファイルは残す）
- 適用状況: `2607_tu_carsharing` が 2026-09-01 に採用済み（既存ログ 3 本も追跡解除）。他の生成先は未適用・未追跡

### AGENTS.md 正典化と 32 KiB 上限の下流波及

- テンプレート側は 2026-09-17 に切り替え済み（`ec1adad`）。詳細は `AGENTS.md`「指示ファイルの構成」
- **下流の適用状況・作業単位・確認コマンドは Issue #12 が台帳**（このファイルには写さない）

### ロケール層 2（`LC_TIME`）の下流波及

- `419c3eb` で層 1・3 に `LC_TIME=C` を入れたとき層 2（`.claude/settings.json` の `env`、`.codex/config.toml` の `set`）が漏れていた。テンプレート側は 2026-09-01 に修正済み
- **同じ漏れは、`419c3eb` 以降に生成した下流と、層 1・3 だけを手で同期した下流に残る**。層 2 はエージェントセッションで層 1 が届かない（`R_ENVIRON_USER=/dev/null`）ときの唯一の固定なので、Claude / Codex 経由で走る R だけ `LC_TIME` が未固定という形で出る
- 確認方法: 対象 repo で `grep -l LC_TIME .claude/settings.json .codex/config.toml`。両方出なければ未適用
- 適用状況: `2607_tu_carsharing` は 2026-09-01 に適用済み。他の生成先は未確認
- 波及時の注意: 既存の図に日付軸があるプロジェクトでは、`LC_TIME` を `C` に固定するとラベルが変わり得る。`%b` / `%B` を **parse** に使っている（`as.Date(x, format = "%B")` 等）プロジェクトでは `C` ではなくその文字列のロケールに固定する
