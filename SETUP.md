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

Claude Code と Codex の通常セッションでは `.Renviron` を自動ロードしない。Claude Code は `.claude/settings.json`、Codex は `.codex/config.toml` で `R_ENVIRON_USER=/dev/null` を設定し、Codex はさらに秘密らしい名前の環境変数を子プロセスへ継承しない。認証が必要な取得処理は、必要な変数を確認したうえでセッション単位・コマンド単位に明示的に有効化する。

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

### 5.1 git hooks の有効化（renv.lock レビューゲート）

git hooks はクローンで配布されないため、**クローン（メンバー）ごとに一度**有効化する:

```bash
git config core.hooksPath .githooks
```

有効化すると、`renv.lock` を含むコミットの直前に `.githooks/pre-commit` がパッケージ単位の差分（追加・削除・版変更）を表示し、`y/N` の確認を求める。`.Rprofile` の `renv.config.auto.snapshot = TRUE` により lockfile は明示的な `renv::snapshot()` なしに変化しうるため、意図しない依存変更のコミット混入をここで検知する。

- 中断した場合は renv.lock を unstage するか、意図的な変更なら再コミットで `y` を選ぶ
- 一度だけ迂回する明示的な逃げ道: `git commit --no-verify`
- TTY が無い環境（CI・一部 GUI クライアント）では差分表示のみで通過する（ハングさせない）
- **二層構成**: Claude Code 経由のコミットは `.claude/settings.json` の PreToolUse hook が承認ダイアログで同じ差分レビューを課す。この git hook はターミナルからの人間のコミットを対象とする補完層

## 6. CI の有効化

`.github/workflows/R-check.yaml` はコード走査（`renv::dependencies()`）で依存を解決するため lockfile が無くても動く。パッケージのインストールは `pak` が担い、システム要件（例: `igraph`→GLPK、`sf`→GDAL）も自動で apt 導入する。GitHub に push すると起動する。

`renv.lock` を採用したら `r-lib/actions/setup-renv@v2` に切り替えてもよい（ファイル冒頭コメント参照）。その際 renv の pak バックエンド（`RENV_CONFIG_PAK_ENABLED=TRUE`）を有効化すると、R パッケージの pin（renv）とシステム要件（pak）が単一の `renv::restore()` に統合され、現行の手動 pak ステップを置き換えられる。**テンプレート自体はこれを採用せず、利用側の判断に委ねる**。

`.github/workflows/renv-update.yaml` は日次（JST 早朝）に起動するが、`gate` ジョブがリポジトリ名のハッシュから割り当てた **週 1 回の曜日にのみ**更新を実行する（手動 `workflow_dispatch` は常に実行）。これにより、このテンプレートから作成した複数プロジェクトの renv-update PR が同じ曜日に一斉発火せず、レビュー負荷が週内に分散する。下流プロジェクトがまだ `renv.lock` を採用していない場合は何もせず終了し、更新差分がある場合だけ `automation/renv-update` ブランチを作成・更新して PR を開く。`renv` 自身の更新で `renv/activate.R` が変わる場合も同じ PR に含める。`renv::snapshot()` は下流プロジェクトの `snapshot.type` に従うため、PR ではパッケージ削除も含めて確認する。`_targets.R` や `tests/testthat.R` が無いプロジェクトでは該当 validation を skip する。PR 作成には GitHub Actions の `GITHUB_TOKEN` を使うため、リポジトリ設定で workflow permissions の read/write と "Allow GitHub Actions to create and approve pull requests" を有効化する。なお `GITHUB_TOKEN` が作成・更新した PR は、通常の push や PAT 由来の PR と異なり別 workflow を追加起動しない点に注意する。

## 7. 動作確認

```bash
Rscript -e 'targets::tar_validate()'
Rscript -e 'targets::tar_make()'   # Quarto ターゲットは Quarto CLI がある場合のみ実行される
Rscript tests/testthat.R
```

## 8. example とこのファイルを削除

テンプレート同梱の動作確認用 example を削除・置換する:

```bash
git rm -r data-raw/example notes/example-note.qmd tests/testthat/test-example.R \
  tests/testthat/test-reproducibility.R
# R/example_functions.R は自分の関数に置き換える
git rm SETUP.md
```

`R/example_functions.R` は自プロジェクトの関数に置き換え、`_targets.R` の example ターゲットを実タスクに差し替える。

残すもの・書き換えるもの:

- `R/data_provenance.R`（`verify_provenance()`）は汎用ヘルパー。**残す**。凍結データを使わないプロジェクトでは削除してよい
- `data-raw/PROVENANCE.md` は example 行を削除し、自分の生データの manifest を記入する
- `tests/testthat/test-data-provenance.R` はヘルパーを残すなら残す
- `tests/testthat/test-reproducibility.R` は example 専用なので削除し、**自プロジェクト版の数値 sentinel に置き換える**。パイプラインの主要導出値（サンプルサイズ・係数・要約統計）を許容誤差でピン留めし、commit 済みの小さな fixture（本番データが gitignored / 再配布不可なら合成データ）に対して検証する。この sentinel は `tests/testthat.R` 経由で renv-update workflow の tests ステップでも走り、パッケージ更新による数値 drift を fail-loud で捕捉する（`tar_validate()` は DAG 構造しか見ず、targets はパッケージ版を cue に含めないため、この層が再現性検証の実体になる）
