# SETUP — テンプレートから新規プロジェクトを生成する

> このファイルはテンプレート専用。**生成したプロジェクトでは最後にこのファイルと example 一式を削除する**（手順 8）。

## 0. 前提ツール

[README.md](README.md)「前提ツール」の表を参照し、各確認コマンドが通ることを確かめる。

## 1. テンプレートを複製（`.git` を含めない）

`cp -r` はテンプレートの `.git/` を巻き込み、生成先の履歴と衝突するため**使わない**。次のいずれかを使う。

```bash
# 方法 A: rsync（推奨。.git と生成物を除外）
rsync -a \
  --exclude='.git' --exclude='renv' --exclude='renv.lock' \
  --exclude='_targets' --exclude='.quarto' \
  research-project-template/ {{PROJECT_SLUG}}/

# 方法 B: git archive（コミット済みツリーのみを展開）
git -C research-project-template archive HEAD | tar -x -C {{PROJECT_SLUG}}/

# 方法 C: GitHub の "Use this template"（履歴を引き継がない新規 repo）
```

## 2. プレースホルダを置換

以下のプレースホルダを全ファイルで置換する。

| プレースホルダ | 意味 |
|---|---|
| `{{PROJECT_NAME}}` | 人間可読のプロジェクト名 |
| `{{PROJECT_SLUG}}` | ディレクトリ / repo 名 |
| `{{PROJECT_DESCRIPTION}}` | 1–2 行の概要 |
| `{{GITHUB_REPO}}` | `owner/repo` |
| `{{CONTACT_EMAIL}}` | 連絡先メール |
| `{{DATE}}` | 作成日（JST、`TZ=Asia/Tokyo date '+%Y-%m-%d'`） |

置換対象ファイル: `CLAUDE.md`, `README.md`, `TODO.md`, `Renviron.example`, `memory/*.md`, `notes/example-note.qmd`。

`Renviron.example` は先頭ドットなしで同梱している。手順 5 の前に `cp Renviron.example .Renviron` でコピーし、実値を記入する（`.Renviron` は gitignore 済み）。

置換後、残存がないか確認する（`SETUP.md` 自身はプレースホルダの説明を含むため除外。手順 8 で削除する）:

```bash
rg '\{\{[A-Z_]+\}\}' --glob '!SETUP.md' || echo "no placeholders remaining"
```

## 3. プロジェクト固有の記入

- `CLAUDE.md`: データソース表・コミット scope 表を記入。不要なら Appendix（Author-local workflow）を削除
- `TODO.md`: Go/No-go ゲートの `Threshold` ほか固定欄、Phase 表を記入

## 4. renv の初期化

```bash
# コード走査（renv::dependencies()）で library() / pkg::fun() から依存を解決
Rscript -e 'renv::init()'
# 追加パッケージを入れたら
Rscript -e 'renv::snapshot()'
```

依存マニフェスト（`DESCRIPTION`）は使わない。名前空間プレフィックス規約（`dplyr::filter()` 等）に従っていれば依存は自動検出される。詳細は `CLAUDE.md`「R パッケージ管理（renv）」を参照。

## 5. バージョン管理の初期化

```bash
git init
git add -A
git commit -m "chore: initialize project from research-project-template"
# 必要なら jj colocated 化: jj git init --colocate
```

## 6. CI の有効化

`.github/workflows/R-check.yaml` はコード走査（`renv::dependencies()`）で依存を解決するため lockfile が無くても動く。パッケージのインストールは `pak` が担い、システム要件（例: `igraph`→GLPK、`sf`→GDAL）も自動で apt 導入する。GitHub に push すると起動する。`renv.lock` を採用したら renv 系 action に切り替えてもよい（ファイル冒頭コメント参照）。

## 7. 動作確認

```bash
Rscript -e 'targets::tar_validate()'
Rscript -e 'targets::tar_make()'   # Quarto ターゲットは Quarto CLI がある場合のみ実行される
Rscript tests/testthat.R
```

## 8. example とこのファイルを削除

テンプレート同梱の動作確認用 example を削除・置換する:

```bash
git rm -r data-raw/example notes/example-note.qmd tests/testthat/test-example.R
# R/example_functions.R は自分の関数に置き換える
git rm SETUP.md
```

`R/example_functions.R` は自プロジェクトの関数に置き換え、`_targets.R` の example ターゲットを実タスクに差し替える。

残すもの・書き換えるもの:

- `R/data_provenance.R`（`verify_provenance()`）は汎用ヘルパー。**残す**。凍結データを使わないプロジェクトでは削除してよい
- `data-raw/PROVENANCE.md` は example 行を削除し、自分の生データの manifest を記入する
- `tests/testthat/test-data-provenance.R` はヘルパーを残すなら残す
