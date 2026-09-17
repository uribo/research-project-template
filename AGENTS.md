# {{PROJECT_NAME}}

> {{PROJECT_DESCRIPTION}}

R / tidyverse による研究分析プロジェクトのテンプレート。`targets` + `renv` + Quarto + AI エージェント統合を前提とする。**本ファイルが全エージェント共通の正典**で、セッション開始時に全文が読み込まれる。規約の編集は常にこちらへ行う。

> **テンプレート利用者へ**: 初回セットアップ手順は [SETUP.md](SETUP.md) を参照。プレースホルダ（`{{…}}` 形式）をすべて置換し、本ファイルの scope 表・データソース表・ゲート閾値を記入したら、この注記行は削除する。

> **テンプレート保守者へ**: このリポジトリ自身の開発状態（次に行う作業・検証記録・捨てた方法）は `memory/` ではなく **GitHub Issue に記録する**。`memory/*.md` は生成先へ配る雛形（SETUP.md 手順 2 のプレースホルダ置換対象）であり、ここに書いた内容は生成される全プロジェクトの初期状態になる。したがってテンプレート repo では `memory-updater` を起動せず、グローバル規約が要求する HANDOFF 更新の代わりに Issue へ追記する。**生成先ではこの注記行も削除する**（生成先では `memory/project-status.md` にそのプロジェクト自身の状態を書くのが正しい運用）。

## 指示ファイルの構成

| ファイル | 誰が読むか | 役割 |
|---|---|---|
| `AGENTS.md`（本ファイル） | Codex はネイティブに、Claude Code は `CLAUDE.md` の import 経由で全文 | 規約の正典 |
| `CLAUDE.md` | Claude Code のみ | 1 行目の `@AGENTS.md` と、Claude Code 固有の機構（skill・サブエージェント・hook） |
| `docs/*.md` | 必要になった時点で**読む指示**として | 常時は要らない詳細（ロケール固定の 3 層、gittargets の手順、データ来歴） |

**本ファイルは 32 KiB（32,768 バイト）を超えてはならない。** Codex はプロジェクト側の指示ファイルをこの上限で**警告なく途中で打ち切る**（`project_doc_max_bytes` の既定値。2026-09-17 に `codex debug prompt-input` で実測）。日本語は約 3 バイト/字なので実効上限はおよそ 10,900 字。超過は `.githooks/pre-commit` と `.claude/settings.json` の hook が検出する（手動確認は `sh tools/check-instructions-size.sh`）。増えてきたら詳細を `docs/` へ移し、本文にはポインタ 1 行を残す。

**`@` 記法で分割しない。** Claude Code の `@path` import は Codex に存在せず、Codex 側だけが静かに内容を失う。両方に届く遅延読み込みは skill だけで、`docs/` へのリンクは「読め」という軟らかい指示として働く。

## プロジェクト概要

{{PROJECT_DESCRIPTION}}

- **GitHub リポジトリ**: `{{GITHUB_REPO}}`
- **全体の TODO・マイルストーン・Go/No-go ゲート**: [TODO.md](TODO.md)
- **作成日**: {{DATE}}

## ディレクトリ構成

`_targets.R` がパイプラインを宣言的に定義し、`R/` の関数を `tar_source()` で読み込む。空ディレクトリを先行して量産せず、実装の進行に応じて作る。

```
{{PROJECT_SLUG}}/
├── AGENTS.md          # プロジェクト知識・規約（本ファイル。全エージェント共通の正典）
├── CLAUDE.md          # @AGENTS.md + Claude Code 固有の記述
├── docs/              # 常時読み込まない詳細（ロケール固定・gittargets 運用）
├── .codex/config.toml # Codex の sandbox・環境変数ポリシー
├── .vscode/           # ワークフロー設定のみ。意図的に git 追跡（理由は .gitignore のコメント）
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
├── prompts/           # Codex への委任ブリーフ（通常作業のログは置かない）
└── tests/             # testthat
```

## 作業時の注意

### Delegation Brief Rule（`prompts/`）

- `prompts/` は **Claude → Codex の委任ブリーフ専用**。通常作業のプロンプト原文・終了時刻・気づきを保存する義務は**無い**（2026-08-28 に廃止）。`prompts/*.md` は gitignored なので、fresh checkout で読める記録にはならない
- ブリーフは `prompts/YYYYMMDD-HHMM-<topic>.md`（JST: `TZ=Asia/Tokyo date '+%Y%m%d-%H%M'`）。元の依頼、スコープと除外、受け入れ条件、既知の制約、「検証すべき主張」としての既存判断、参照 URL、要求する検証手順を含める。**HANDOFF にブリーフの正確なパスを書く**（Codex が自動で読むのは本ファイル・HANDOFF・`git status`・`git diff` だけ）
- 外部 URL は、それを根拠とする判断のそば（Issue / `TODO.md` / `data-raw/PROVENANCE.md` / ブリーフ）に書く。URL を参照しただけでファイルは作らない

### GitHub Issue 操作

- **Issue 作成前に必ず既存 Issue を確認する**（`gh issue list --state all`）。重複 Issue を作らない
- Issue 番号は連番で不可逆なため、誤作成で欠番が生じないよう慎重に操作する

### Git ブランチ操作

- **ブランチの作成・切り替えは必ずユーザーに確認を求めてから実行する**。勝手にブランチを作成しない

### 破壊的操作の原則

- GitHub 上の操作（issue 作成・クローズ、PR 作成、push 等）は取り消しが困難。`renv::restore()` や `targets::tar_destroy()` などローカル状態を破壊しうる操作も含め、実行前にユーザーへ確認する
- 認証情報・ライセンスデータをコミットしない（後述「セキュリティ」）

## 言語の使い分け

- **R**（tidyverse, renv, targets）が主要解析言語。**Python** はテキスト処理・ML タスクで必要になったときだけ `uv` で環境を作り、`pyproject.toml` の追加を本ファイルに追記する
- コード識別子・コメント・コミットメッセージ・ドキュメント: **英語**。原稿本文: **US English**（UK スペリングと混在させない）。エージェントとのチャット: 日本語

## R コード記述

### スタイル

- [tidyverse スタイル](https://style.tidyverse.org/)を [air](https://posit-dev.github.io/air/) でフォーマット（編集時に hook で自動実行）
- [jarl](https://jarl.etiennebacher.com/) で lint（同じ hook で air の後に実行、CI の `lint` job でも検査）。**整形は air、lint は jarl** と役割が分かれており、jarl は整形ルールを持たないので両者は競合しない。設定は `jarl.toml`、エディタ拡張は `etiennebacher.jarl-vscode`。ローカルと CI で同じ版を使う（現在 0.6.0）
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
# Bad: 隠れた依存 + 副作用（source / tar_load / saveRDS を関数内でやる）
process_data <- function(year) { source("R/utils.R"); targets::tar_load(raw_data); saveRDS(result, "out.rds") }

# Good: 明示的な依存、純粋な戻り値
process_data <- function(raw_data, year) {
  raw_data |>
    dplyr::filter(observation_year == year)
}
```

### targets パイプライン

- 定義は `_targets.R`、関数は `R/`（`tar_source()` で自動読み込み）。`R/` には**関数定義のみ**を置き、スクリプト的な実行コードを含めない。ファイル構成・関数名はスケルトンなので、`_targets.R` と整合していれば分割・統合・リネームしてよい
- 全ターゲットに `description` 引数で日本語の処理概要を付与する
- 並列実行は `crew` + `mirai`（雛形は `_targets.R` のコメント）。重い再計算・再取得不能な外部データには `gittargets`（運用は下記 gittargets 節）
- **数値結果を直接左右するパッケージ（モデル推定・乱数・数値計算系）は版ピン留めターゲットで cue に載せる**。`tar_target(model_pkg_versions, sapply(c(...), \(p) as.character(packageVersion(p))))` を置き、結果に直結するターゲットだけ `{model_pkg_versions; fit_model(...)}` のブレース参照で依存させる（雛形は `_targets.R` のコメント）。整形系は載せない。**`tar_option_set(imports)` はこのテンプレートのスタイルでは機能しない**（理由と実測は [docs/reproducibility-ops.md](docs/reproducibility-ops.md)）
- **`tar_make()` の生存確認は 2 系統でやる。** `callr` 経由で `R --slave` が起動するため `pgrep "Rscript"` では検出できず、`_targets/meta/process` の pid レコードは**プロセスが死んでも残る**。`ps -p <pid>` と、進捗が実際に増えているか（ログの mtime、`_targets/objects/` のファイル数）を独立に見る。長いビルドは `nohup` で切り離す。Reason: 2026-09-01 に `pgrep` で見えないことを「殺された」と、2026-09-02 に残った pid を「実行中」と誤読した
- **全データフレームターゲットに `validate_*()` 関数を設ける**。検証項目はデータの意味的整合性（キーの一意性、値域、NA 許容範囲）に集中。モデルオブジェクト・図表出力は対象外
- データバリデーション（`pointblank`）は独立ターゲットにせず、処理関数内で `stop_on_fail()` によるアサーションとして組み込む
- **検証を「列の有無」で条件分岐させない**。`if ("dayflag" %in% names(data))` のような分岐は、水準が 1 つでも列自体は存在するため常に真になり、**検証が静かに無効化される**（検証があるのに何も検証していない状態は、検証が無いより危険）。分岐が必要なら列の存在ではなく**値の状態**（水準数・NA 率）で判定し、分岐したこと自体をログに出す
- **カテゴリ表の補集合で絞り込まない**。既知カテゴリの補集合を取ると**カテゴリ未設定の行が消える**。除外したい対象を明示的に列挙する

### R パッケージ管理（renv）

- `renv` によるパッケージ管理を使用。`renv.lock` でバージョンを固定（**各環境で `renv::init()` / `renv::snapshot()` により生成**。テンプレートには同梱しない）
- 依存マニフェスト（`DESCRIPTION` 等）は持たない。依存は `renv::dependencies()` の**コード走査**（`library()` 呼び出し・`pkg::fun()` 名前空間呼び出し）で暗黙的に検出される。名前空間プレフィックス規約（上記スタイル）がそのまま依存宣言を兼ねる
- **注意**: コード中に登場しないパッケージは検出されない。対話的にしか使わないツール（例: `gittargets`）は `_targets.R` 冒頭に `if (FALSE) { requireNamespace("gittargets") }` の明示参照を足してから `renv::install()` → `renv::snapshot()` で記録する。`renv::record()` は劣化レコード（依存フィールドが null）を書き、`renv::restore()` が成功表示のままロールバックし得るため使わない
- `if (FALSE)` による依存宣言を追加するときは、その直前の独立した行に `# jarl-ignore unreachable_code: Declare an optional dependency for renv.` を置く。`unreachable_code` は全体では有効に保ち、意図した宣言だけを抑制する（`return()` 後などの到達不能コードは検出対象）。このルールに自動修正機能はない。
- **YAML からしか参照されないパッケージは `_dependencies.R` に宣言する**。コード走査が読むのは R/Rmd/qmd の**コード**であって YAML メタデータではないため、`notes/_metadata.yml` の `dev: ragg_png` のような名前は検出されず、`auto.snapshot = TRUE` により次の snapshot で lockfile から静かに落ちる（別マシンや CI で無関係に見えるレンダーエラーとして現れる）。**`renv::record()` では直らない**（`renv::status()` が「使われていない」と報告し続け、次の snapshot で再び消える）ので、宣言は走査対象のファイルに置く。`_dependencies.R` は **source されない**ので `tar_source()` が読む `R/` には置かない。追加後に `renv::dependencies()` の Source 列と `renv::status()` を確認する
- 新しいパッケージは `renv::install()` で導入し（`install.packages()` ではなく）、使用コードを書いたら `renv::snapshot()` でロックファイルを更新する
- **明示的な必要性がない限り `renv.lock` にパッケージを追加しない**
- `renv.lock` を含むコミットはレビューゲートを通る: Claude 経由は `.claude/settings.json` の hook、ターミナルからは `.githooks/pre-commit`（有効化手順は SETUP.md 手順 5.1）。`renv.config.auto.snapshot = TRUE` による暗黙の lockfile 更新を見逃さないための仕組み

### 再現性

- 重い・再生成が遅い計算は `gittargets` または `targets` の branching で冗長な再計算を避ける
- 大容量の生データを git にコミットしない。`.gitignore` + `data-raw/`（gitignored）で運用
- ブートストラップ・順列検定・シミュレーションのシードは必ず設定する。グローバル `set.seed()` より `withr::with_seed()` を優先
- 実行環境の非決定要因を固定する: TZ は `.Rprofile`、ロケール（`LC_COLLATE` / `LC_TIME`）は後述の 3 層で固定する。成果物には環境記録を残す（`sessioninfo::session_info()` を `notes/`・`paper/` の QMD 末尾に）
- **R バージョンの固定**: 正典は `renv.lock` の `R.Version`。CI は両 workflow とも `renv.lock` があれば `r-version: "renv"` を使い、無い間だけテンプレート基準の R に落ちる（**手動での切り替えは不要**。以前の手書き運用では生成先 5 件中 3 件が lockfile と無関係な R を固定したままだった）。エディタ設定でのインタープリタ絶対パス指定はマシン固有になるため行わない
- **数値 reproducibility sentinel を置く**: `tar_validate()` は DAG 構造しか見ず、`renv` 更新は数値 drift を素通りさせる。主要導出値を許容誤差でピン留めした testthat テストを、commit 済みの小さな fixture に対して置く（雛形: `tests/testthat/test-reproducibility.R`）
- **lockfile 更新は再ビルドの契機**: renv-update PR の merge や `renv::update()` の後は `tar_make()` を回し直す。**何も outdated に見えないのは「整合している」ではなく「見えていない」**
- **原稿投稿後・査読中・出版アーカイブ後は `renv-update` workflow を凍結する**（`gh workflow disable renv-update`）

sentinel の限界（fixture の drift 検出であって完全再現の保証ではない）、再ビルドを怠ったときに何が起きるか、凍結の解除手順は [docs/reproducibility-ops.md](docs/reproducibility-ops.md) にある。

#### ロケール（`LC_COLLATE` / `LC_TIME`）の固定

`LC_COLLATE` は `factor()` の水準順を、`LC_TIME` は `format()` が返す月名・曜日名（ggplot2 の日付軸ラベルの既定値）を決める。どちらも放置するとエラーを出さないまま、マシンごとに違う成果物を作る（英文原稿の図に `1月 / 2月` が入る、水準順が凡例・contrast・`split()` に伝播する）。**両方を `C` に固定する**。

> [!WARNING]
> **`LC_ALL` で一括指定しない。** `LC_CTYPE` まで上書きされ、`area == "沖縄県"` のような比較が成立しなくなって**該当行がエラーも警告も無く結果から消える**（2026-08-28、Supplement 表から 3 行が脱落）。上の 2 カテゴリを個別に指定する。

固定は 3 層（`.Renviron` / エージェント設定 / `.Rprofile` 末尾）で行う。`.Rprofile` だけでは守れない理由・層ごとの適用範囲・確認コマンドは [docs/locale-pinning.md](docs/locale-pinning.md) にある。**新規クローン時と renv 更新後に一度は確認する**。

#### 外部データの再現性・来歴・入力ガード

- **取得の再現性は 3 段のハイアラーキで確保する**: (1) 版付き DOI / タグ付きリリース / CRAN 版＋SHA のような**正典に pin して都度再取得**（最優先）、(2) 移動 ref（`master` / `latest`）を commit SHA に固定、(3) **バイトの凍結は最終手段**（時間遡及不可の SPARQL、版の無い API 等）。どの段でも正典からの再導出スクリプトを残し、ライブ取得は fail-loud にする
- **凍結データは `data-raw/PROVENANCE.md` の manifest（`file` / `sha256` / source / retrieved / license / 再導出経路）に記録し、`verify_provenance()` を `format = "file"` ターゲットに挟んで読み込み前に sha256 を検証する**
- **「取れなかった」を「無かった」にしない**: 入力ディレクトリの不在（`list.files()` の `character(0)` → 0 行 0 列）と取得の失敗（ネットワークエラー）は、どちらも例外を出さずに「0 件」を残す。`R/input_guards.R` の `require_input_dir()` / `list_input_files()` / `new_fetch_result()` を境界に置く

3 段の詳細、`n = 0` が「存在しない証拠」に化ける経路、4 値 status の設計、検証器自体を両方向でテストする理由は [docs/data-integrity.md](docs/data-integrity.md) にある。

#### gittargets によるストアのスナップショット

`_targets/` は gitignored なので、意図しない再計算で上書きされたオブジェクトは復元できない。**時間遡及不可の外部ソース（版指定取得に対応しない API 等）を扱うプロジェクトでは gittargets を導入する**。これは再現性の担保ではなく**ローカルの復旧点**であり、恒久対処は上のハイアラーキ第 3 段（バイト凍結＋`PROVENANCE.md`）。

- **スナップショットは破壊的操作の「前」に取る**: 外部 API 由来サブツリーの再構築、`tar_destroy()`、ターゲット定義の大きな変更、ガードを外す作業、lockfile 更新に伴う再ビルド。事故の後では手遅れ
- **lockfile 更新時は前後 2 回・別コミット上で取る**。この順でないと「旧 lockfile ↔ 旧ストア」の対応が台帳に残らず、drift が発覚しても巻き戻し先を特定できない
- **fail-loud な abort が実質的なデータ保護として機能している場合がある**。外す前に `tar_outdated()` で影響を確認し、スナップショットを取ってから外す

初期化・既定値（`tar_git_init(git_lfs = FALSE)` / `tar_git_snapshot(status = FALSE)`）、クラウド同期フォルダを避ける理由、汚染オブジェクトの特定手順は [docs/gittargets.md](docs/gittargets.md)。

## データソース

| データ | ソース | 取得方法 | 注記 |
|---|---|---|---|
| （要記入） | （取得元） | （URL DL / API / 提供） | （ライセンス・再配布可否） |

各凍結ファイルの sha256・取得日・再導出経路は `data-raw/PROVENANCE.md` に記録する。

### 外部サービスの認証

- 認証情報（API key、サービスアカウント JSON）は `.Renviron` に置き、**コミットしない**
- Claude Code / Codex の通常セッションでは `R_ENVIRON_USER=/dev/null` とし、`.Renviron` を R に自動ロードさせない。Codex は `.codex/config.toml` で秘密らしい名前の環境変数も子プロセスへの継承対象から外す
- 認証が必要な処理では、対象の credential と利用範囲を説明してユーザー承認を得た後、セッション単位・コマンド単位で明示的に有効化する。値をチャット、ログ、コマンド出力へ表示しない
- ライセンスデータ（再配布不可）はリポジトリにコミットせず `data-raw/`（gitignored）で扱う。バイトは共有せず、**PROVENANCE.md のハッシュ・メタデータのみコミット**する

## Quarto

- 探索的分析ノート: `notes/`（`.qmd`）
- 原稿ドラフト: `paper/`（`.qmd`）
- 数値の引用は `tar_read()` / `tar_load()` 経由で動的に解決する（下記 Data Reference Policy）
- レンダーは Quarto CLI を前提とする。`notes/` の QMD は `tarchetypes::tar_quarto()` で組み込めるが、**CLI 未導入環境では当該ターゲットが DAG から外れる**（`_targets.R` が除外数とパスを `message()` で報告する。黙って外れると `tar_validate()` の緑が本番より狭い範囲しか意味しない）。CI は CLI を導入するのでこの分岐はローカル限定
- `notes/` の QMD を単体レンダーすると作業ディレクトリが `notes/` になり `tar_load()` が `notes/_targets/` を探して失敗する。`notes/_targets.yaml`（`store: ../_targets/`）でルートのストアに向けてあるので、setup チャンクは `store` 引数なしで書ける
- ノート間リンクは **ソースでは `.qmd`** で書く。`notes/qmd-links-to-html.lua`（`notes/_metadata.yml` の `filters:` に登録済み）が HTML レンダー時のみ `.html` へ書き換える（#anchor 保持・外部 URL は不変）

### Data Reference Policy

**CRITICAL**: Quarto 文書（Methods・Results・Discussion）の数値はすべて `targets::tar_load()` 経由で動的に参照する。本文に数値をハードコードしない。

```r
# .qmd のセットアップチャンク
targets::tar_load(c(example_summary))
n_obs <- example_summary$n_obs
```
本文では `` `r scales::comma(n_obs)` `` のように埋め込む。**禁止**: `3,847 observations` のようなハードコードされた数値を本文に書く。

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

例: `feat(data): add raw observation ingestion script` / `chore(renv): add sf, terra to lockfile`

- コミットメッセージは英語
- まとまった作業単位の後に `auto-committer` エージェントで自律的にコミットしてよい
- `Co-Authored-By:` フッターは付けない

## セキュリティ・データ取り扱い

- **認証情報をコミットしない**: API key、サービスアカウント JSON、`.Renviron`、`.env`。コミット前に `git status` で生成物・認証情報の混入を確認する
- **ライセンスデータをコミットしない**: 再配布不可のデータは `data-raw/`（gitignored）で扱い、**PROVENANCE.md のハッシュ・メタデータだけをコミット**する（詳細は上記「外部サービスの認証」）

## Memory

プロジェクト固有の知識を `memory/` に蓄積し、会話間で引き継ぐ。

### 規約

- インデックス: `memory/MEMORY.md`（会話開始時に自動ロード、200 行以内）
- 各メモリは個別の `.md` ファイル。frontmatter に `name` / `description` / `type`（`feedback` | `project` | `reference`）/ `updated` を書き、本文の feedback・project には **Why:** と **How to apply:** を含める（`user` はグローバル CLAUDE.md に集約）
- コード・git 履歴から導出可能な情報は書かない。新規作成前に既存メモリとの重複を確認し、更新で済むなら更新する

### 引き継ぎ（HANDOFF）欄の運用

- `memory/project-status.md` 先頭の HANDOFF 欄は**次のセッションが再開するための最小状態**。欄全体で 40 行以内（空行を除く）を保ち、先頭に「次に行う作業（1 つ）」を置く
- 恒久知識を HANDOFF に本文で持たない: 採用済みの設計・運用制約 → 本ファイルまたは `memory/<topic>.md`、検証・レビュー報告 → Issue コメント、数値結果 → `notes/` や protocol 文書。HANDOFF に残すのはパス・Issue 番号のポインタ 1 行
- 日付を冠した見出し（`## YYYY-MM-DD の追記` 等）で下へ堆積させず、上書きで更新する。削った内容は `git log -p memory/project-status.md` で復元できる
- 更新の契機: 方針を決めた時・試行を捨てた時・検証を実行した時・PR を作成した時・セッションを終える時（commit したこと自体は契機ではない）

## 共通コマンド

セットアップ・実行コマンドの一次ソースは [README.md](README.md)（「セットアップ」「実行」）。ここには README にない補助コマンドのみを置く。

```bash
# パイプライングラフ確認
Rscript -e 'targets::tar_visnetwork()'

# フォーマット（通常は編集時 hook で自動実行される）
air format .

# lint（同上。--fix は関数本体を書き換えるので、_targets の再計算を確認してから使う）
jarl check .
```

## エージェント固有の規約

### Codex

- **秘密情報を扱うファイルを読まない・出力しない**: `.Renviron`、`.env`、credential JSON、秘密鍵。安全なテンプレート（`Renviron.example`）はプレースホルダのみを含む前提で読み書きしてよい
- `.codex/config.toml` の環境変数フィルタや `R_ENVIRON_USER` の設定を、ユーザーの明示的な承認なしに迂回しない

> **Template maintainers only — 生成先ではこの注記を削除する。** このリポジトリ自身では `memory/*.md` は生成先へ配る雛形なので、HANDOFF 欄は `（要記入）` の骨組みのまま残す（開発状態は GitHub Issue に記録する）。下の規則はこのリポジトリでは「読む」側にだけ適用され、「書く」側には適用されない。生成先ではこの注記が無く、下の規則がそのまま適用される。

- **セッション開始時に `memory/project-status.md` 先頭の HANDOFF 欄を読み、続けて `git status` と `git diff` を確認する**。既存の変更を捨てない。記載済みの判断は「検証すべき主張」として扱い、コードとテスト結果で確認してから積み上げる
- 終了・中断時に HANDOFF 欄を更新する（現在の方針、次に行う作業 1 つ、捨てた方法、未検証の項目、最後に実行した検証コマンドと結果）

### Claude Code

- 固有の機構（skill・サブエージェント・hook・`.claude/rules/`）は `CLAUDE.md` の `@AGENTS.md` より下に書く。**そこに書いた内容は Codex に届かない**ので、両方に効かせたい規約は本ファイルへ書く

---

## Appendix: Author-local workflow（optional, machine-specific）

> 著者のマシン固有のワークフロー。**共同研究者の環境には存在しない**ので、採用しない場合はこの Appendix ごと削除する。

- 個人 vault（`~/Documents/personal/`、`~/Documents/wm_patch/`）の知識ノートを参照することがある
- 日次の作業ログは wm_patch vault の `2_Areas/diary/YYYY/YYYY-MM-DD.md` に `/obsidian-log` 経由で記録する（commit ではなくセッション横断の文脈を残すため）
