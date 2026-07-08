# {{PROJECT_NAME}}

> {{PROJECT_DESCRIPTION}}

R / tidyverse による研究分析プロジェクトのテンプレート。`targets` パイプライン + `renv` + Quarto + Claude Code 統合を前提とする。本ファイルはセッション開始時に読み込まれるプロジェクトの一次知識源。

> **テンプレート利用者へ**: 初回セットアップ手順は [SETUP.md](SETUP.md) を参照。プレースホルダ（`{{…}}` 形式）をすべて置換し、本ファイルの scope 表・データソース表・ゲート閾値を記入したら、この注記行は削除する。

## プロジェクト概要

{{PROJECT_DESCRIPTION}}

- **GitHub リポジトリ**: `{{GITHUB_REPO}}`
- **全体の TODO・マイルストーン・Go/No-go ゲート**: [TODO.md](TODO.md)
- **作成日**: {{DATE}}

## ディレクトリ構成

R 側のデータパイプラインは `targets` で管理する。`_targets.R` でパイプラインを宣言的に定義し、`R/` 以下の関数を `tar_source()` で自動読み込みする。空ディレクトリを先行して量産せず、実装の進行に応じて必要なものを生成する。

```
{{PROJECT_SLUG}}/
├── CLAUDE.md          # プロジェクト知識・規約（本ファイル）
├── README.md          # 概要・前提ツール・実行コマンド
├── TODO.md            # マイルストーン・Go/No-go ゲート・ブロッカー
├── _targets.R         # targets パイプライン定義
├── renv.lock          # renv::init/snapshot で生成（各環境で固定）
├── R/                 # 関数定義（tar_source() で自動読み込み、副作用なし）
├── data-raw/          # 不変の生データ（gitignore 対象）
├── data/              # 処理済み中間データ（gitignore 対象）
├── _targets/          # targets キャッシュ（自動生成、gitignore）
├── notes/             # 探索的分析（Quarto .qmd）
├── paper/             # 原稿（Quarto .qmd）
├── figures/           # 生成図
├── memory/            # プロジェクト固有知識（会話間引き継ぎ）
├── prompts/           # Claude Code 作業プロンプトログ
└── tests/             # testthat
```

## 作業時の注意

### Prompt Logging Rule

- すべての作業は、最初に使用したプロンプトを `prompts/YYYYMMDD-HHMM-task-name.md` に保存してから開始する
- 年月日時刻は日本標準時（JST）の現在時刻を使用する
    - `TZ=Asia/Tokyo date '+%Y%m%d-%H%M'`
- ウェブサイトや外部リソースを参照する場合は、あらかじめユーザーに確認を取り、参照した URL・タイトル・要約をプロンプトファイルに記録する
- 作業終了時に以下を実行する:
    - プロンプトファイル末尾に `作業終了: YYYY-MM-DD HH:MM` を記述する
    - 作業中に発覚した問題・課題・気づきを整理してユーザーに通知する
- このファイルが存在しない場合でも作業を開始してよいが、会話の途中からでも遡って作成する

### GitHub Issue 操作

- **Issue 作成前に必ず既存 Issue を確認する**（`gh issue list --state all`）。重複 Issue を作らない
- Issue 番号は連番で不可逆なため、誤作成で欠番が生じないよう慎重に操作する

### Git ブランチ操作

- **ブランチの作成・切り替えは必ずユーザーに確認を求めてから実行する**。勝手にブランチを作成しない

### 破壊的操作の原則

- GitHub 上の操作（issue 作成・クローズ、PR 作成、push 等）は取り消しが困難。実行前にユーザーへ確認する
- `renv::restore()` や `targets::tar_destroy()` など、ローカル状態を破壊しうる操作も事前確認する
- 認証情報・ライセンスデータをコミットしない（後述「セキュリティ」）

## 言語の使い分け

- **R**（tidyverse, renv, targets）: 主要解析言語。データ取得・前処理・可視化・統計推定・原稿作成
- **Python**（必要時のみ）: テキスト処理・ML タスク。本テンプレートは R 専用構成。Python が必要になった場合は `uv` で環境を作り `pyproject.toml` を追加する（CLAUDE.md にその旨を追記する）
- コード識別子・コメント・コミットメッセージ・ドキュメント: **英語**
- 原稿本文: **US English**（UK スペリングと混在させない）
- Claude Code とのチャット: 日本語

## R コード記述

### スタイル

- [tidyverse スタイル](https://style.tidyverse.org/)を [air](https://posit-dev.github.io/air/) でフォーマット（編集時に hook で自動実行）
- ネイティブパイプ `|>` のみを使用（`%>%` は不可）
- モダン tidyverse パターン: `.by` 引数、`join_by()`、`purrr::map() |> list_rbind()` 等
- 関数にはパッケージ名前空間プレフィックスを付ける: `dplyr::filter()`、`readr::read_csv()`（例外: `library(ggplot2)` をトップで読む場合の `ggplot2` 関数）
- superseded パターンを避ける: `summarise(.groups = "drop")`、`do.call()`、データフレームの `rbind()` 等
- 変数名は英語のみ。コメントは英語

### 関数設計の原則

**副作用を関数に持ち込まない**: 関数内部で `source()`、`targets::tar_load()`、`library()`、`require()`、ファイル I/O を行わない。

1. **ライブラリ読み込みを関数内で行わない** — `library(dplyr)` ではなく `dplyr::filter()` 名前空間を使う
2. **関数内でファイル I/O を行わない** — オブジェクトを返し、永続化は `_targets.R` に委ねる
3. **隠れた依存を持たない** — `source()` や `tar_load()` ではなく、必要なデータを明示的な引数として渡す

```r
# Bad: 隠れた依存 + 副作用
process_data <- function(year) {
  source("R/utils.R")
  targets::tar_load(raw_data)
  result <- ...
  saveRDS(result, "out.rds")
  result
}

# Good: 明示的な依存、純粋な戻り値
process_data <- function(raw_data, year) {
  raw_data |>
    dplyr::filter(observation_year == year)
}
```

### targets パイプライン

- パイプライン定義: `_targets.R`（プロジェクトルート）
- 関数定義: `R/` 以下に配置。`tar_source()` で自動読み込み
- `R/` 内のファイルは**関数定義のみ**を記述し、スクリプト的な実行コードを含めない
- `R/` のファイル構成・関数名はスケルトンであり、実装時に分割・統合・リネームしてよい。`_targets.R` のターゲット定義と整合が取れていれば問題ない
- 全ターゲットに `description` 引数で日本語の処理概要を付与する
- 並列実行: `crew` + `mirai`（`tar_option_set(controller = crew::crew_controller_local(...))`）。`_targets.R` にコメントで雛形を用意
- 重い再計算には `gittargets` を利用してデータバージョニングする
- **全データフレームターゲットに `validate_*()` 関数を設ける**。検証項目はデータの意味的整合性（キーの一意性、値域、NA 許容範囲）に集中。モデルオブジェクト・図表出力は対象外
- データバリデーション（`pointblank`）は独立ターゲットにせず、処理関数内で `stop_on_fail()` によるアサーションとして組み込む

### R パッケージ管理（renv）

- `renv` によるパッケージ管理を使用。`renv.lock` でバージョンを固定（**各環境で `renv::init()` / `renv::snapshot()` により生成**。テンプレートには同梱しない）
- 依存マニフェスト（`DESCRIPTION` 等）は持たない。依存は `renv::dependencies()` の**コード走査**（`library()` 呼び出し・`pkg::fun()` 名前空間呼び出し）で暗黙的に検出される。名前空間プレフィックス規約（上記スタイル）がそのまま依存宣言を兼ねる
- **注意**: コード中に登場しないパッケージは検出されない。対話的にしか使わないツール（例: `gittargets`）やコメントアウト中の雛形（`crew`/`mirai`）は、実際にコードで使い始めた時点で lockfile に入る
- 新しいパッケージは `renv::install()` で導入し（`install.packages()` ではなく）、使用コードを書いたら `renv::snapshot()` でロックファイルを更新する
- **明示的な必要性がない限り `renv.lock` にパッケージを追加しない**

### 再現性

- 重い・再生成が遅い計算は `gittargets` または `targets` の branching で冗長な再計算を避ける
- 大容量の生データを git にコミットしない。`.gitignore` + `data-raw/`（gitignored）で運用
- ブートストラップ・順列検定・シミュレーションのシードは必ず設定する。グローバル `set.seed()` より `withr::with_seed()` を優先
- 実行環境の非決定要因を固定する: TZ・照合順序（`LC_COLLATE`）は `.Rprofile` で明示（下記）。成果物には環境記録を残す（`sessioninfo::session_info()` を `notes/`・`paper/` の QMD 末尾に）

#### 外部データソースの再現性ハイアラーキ

ライブな外部ソース（API、SPARQL、移動 ref、版が動くパッケージ）に依存する取得は、次の優先順で再現性を確保する。**バイトの凍結コピーは最終手段**。

1. **正典に pin して都度再取得**（最優先）: 版付き DOI/Zenodo、タグ付きリリース、CRAN の版＋SHA。re-derivable かつ再現可能
2. **移動 ref を不変識別子に固定**: `master`/`latest` → commit SHA。上流は正典のまま状態だけ固定
3. **バイトを凍結**（最終手段）: 上流が再現可能なハンドルを持たないときのみ（時間遡及不可の SPARQL、版の無い API、force-push される ref）

- どの段でも**正典からの再導出スクリプト（provenance）を必ず残す**。ライブ取得は retry＋fail-loud（`purrr::safely()` で握り潰さない）
- 凍結・pin したら下流を再ビルドし、論文時の値とバイト一致を検証する（`pointblank::row_count_match()` 等でドリフトを fail-loud 化）

#### 凍結データの provenance 検証

`data-raw/` に凍結した不変データは、`data-raw/PROVENANCE.md` の manifest（`file` / `sha256` / source / retrieved / license / 再導出経路）に記録する。パイプラインでは `R/data_provenance.R` の `verify_provenance(path, sha256)` を `format = "file"` ターゲットに挟み、読み込み前に sha256 を fail-loud 検証する（例: `_targets.R` の `example_raw_file`）。共同研究者が別コピーを持っていても、ここで停止する。

## データソース

| データ | ソース | 取得方法 | 注記 |
|---|---|---|---|
| （要記入） | （取得元） | （URL DL / API / 提供） | （ライセンス・再配布可否） |

各凍結ファイルの sha256・取得日・再導出経路は `data-raw/PROVENANCE.md` に記録する。

### 外部サービスの認証

- 認証情報（API key、サービスアカウント JSON）は `.Renviron` に置き、**コミットしない**
- ライセンスデータ（再配布不可）はリポジトリにコミットせず `data-raw/`（gitignored）で扱う。バイトは共有せず、**PROVENANCE.md のハッシュ・メタデータのみコミット**する

## Quarto

- 探索的分析ノート: `notes/`（`.qmd`）
- 原稿ドラフト: `paper/`（`.qmd`）
- 数値の引用は `tar_read()` / `tar_load()` 経由で動的に解決する（下記 Data Reference Policy）
- Quarto のレンダーは Quarto CLI を前提とする。`notes/` の QMD は `tarchetypes::tar_quarto()` でパイプラインに組み込めるが、CLI 未導入環境では当該ターゲットが落ちる点に留意

### Data Reference Policy

**CRITICAL**: Quarto 文書（Methods・Results・Discussion）の数値はすべて `targets::tar_load()` 経由で動的に参照する。本文に数値をハードコードしない。

```r
# .qmd のセットアップチャンク
targets::tar_load(c(example_summary))
n_obs <- example_summary$n_obs
```

```markdown
We analyzed `r scales::comma(n_obs)` observations...
```

**禁止**: 本文中に `3,847 observations` のようなハードコードされた数値を書く。

## コミット規約

**Conventional Commits v1.0.0** に準拠する。

### scope 定義（プロジェクトに合わせて要カスタマイズ）

| scope | 対象 |
|---|---|
| `data` | データ取得・前処理（`data-raw/` スクリプト） |
| `targets` | パイプライン（`_targets.R`） |
| `renv` | パッケージ管理（`renv.lock`） |
| `notes` | 分析ノート（`notes/`） |
| `paper` | 原稿（`paper/`） |
| `（モジュール名）` | `R/` の機能モジュール（例: `clean`, `model`, `viz`） |

### 例

```
feat(data): add raw observation ingestion script
fix(model): correct grouping variable in summary
docs(paper): draft introduction section
chore(renv): add sf, terra to lockfile
```

- コミットメッセージは英語
- まとまった作業単位の後に `auto-committer` エージェントで自律的にコミットしてよい
- `Co-Authored-By:` フッターは付けない

## セキュリティ・データ取り扱い

- **認証情報をコミットしない**: API key、サービスアカウント JSON、`.Renviron`、`.env`
- **ライセンスデータをコミットしない**: 再配布不可のデータは `data-raw/`（gitignored）で扱う
- コミット前に `git status` で意図しないファイル（生成物・認証情報）が含まれていないか確認する

## Memory

プロジェクト固有の知識を `memory/` に蓄積し、会話間で引き継ぐ。

### 規約

- インデックス: `memory/MEMORY.md`（会話開始時に自動ロード、200 行以内）
- 各メモリは個別の `.md` ファイルとして保存。フロントマターに `name`, `description`, `type`, `updated` を記載
- type: `feedback` | `project` | `reference`（`user` はグローバル CLAUDE.md に集約）
- コード・git 履歴から導出可能な情報は書かない
- 新規作成前に既存メモリとの重複を確認し、更新で済む場合は更新する

### メモリファイルのテンプレート

```markdown
---
name: （メモリ名）
description: （一行の説明 — 将来の会話で関連性を判断するために使う）
type: （feedback | project | reference）
updated: （YYYY-MM-DD）
---

（内容。feedback/project は **Why:** と **How to apply:** を含める）
```

### いつ保存するか

- ユーザーが明示的に「覚えておいて」と指示したとき → 即座に保存
- フィードバックや修正を受けたとき → feedback メモリとして保存
- プロジェクトの進捗・状態が変化したとき → project メモリを更新

## 共通コマンド

セットアップ・実行コマンドの一次ソースは [README.md](README.md)（「セットアップ」「実行」）。ここには README にない補助コマンドのみを置く。

```bash
# パイプライングラフ確認
Rscript -e 'targets::tar_visnetwork()'

# フォーマット（通常は編集時 hook で自動実行される）
air format .
```

## Skills（Claude Code 向け）

R コード記述・レビュー時、原稿作成時、文献検索時などにスキルを活用する。プロジェクトで利用するものをここに列挙する（例）:

- `/r-modern-tidyverse`: R コード記述時。superseded パターンの回避を徹底
- `/r-rlang-programming`: tidyverse 関数をラップする関数を書く際
- `/sciwrite`: 英語原稿・Abstract・rebuttal の作成・レビュー
- `/openalex`: DOI・著者・キーワードから書誌情報を取得
- `/commit-msg`: Conventional Commits 形式のコミットメッセージ起案

### エージェント

- `auto-committer`: 作業単位の完了時に自律的にコミット（Conventional Commits 準拠）

---

## Appendix: Author-local workflow（optional, machine-specific）

> 以下は著者個人の環境に依存するワークフロー。**共同研究者の環境には存在しない**ため、テンプレートを共有する場合は無視してよい。プロジェクトで採用しない場合はこの Appendix ごと削除する。

- **個人 vault パス**: `~/Documents/personal/`（Obsidian vault）および `~/Documents/wm_patch/`（AI 知識拡張 vault）の知識ノートを参照することがある。これらはこのマシン固有のパス
- **日次ログ**: 日次の作業ログは wm_patch vault の `2_Areas/diary/YYYY/YYYY-MM-DD.md` に `/obsidian-log` スキル経由で記録する（commit ではなくセッション横断の文脈を残すため）
- **obsidian 系スキル**: `/obsidian:obsidian-cli`, `/obsidian:obsidian-markdown`, `/obsidian-log` 等を vault 連携に使用
