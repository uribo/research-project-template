# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

R / tidyverse + `targets` + `renv` + Quarto による研究分析プロジェクト。Claude Code との協働を前提とした構成。

- プロジェクト知識・規約: [CLAUDE.md](CLAUDE.md)
- マイルストーン・Go/No-go ゲート: [TODO.md](TODO.md)

> このリポジトリは [research-project-template](https://github.com/uribo/research-project-template) テンプレートから生成された。初回セットアップが未了の場合は [SETUP.md](SETUP.md) を参照。

## 前提ツール

| ツール | 用途 | 確認コマンド |
|---|---|---|
| R (≥ 4.5) | 解析本体 | `Rscript --version` |
| [renv](https://rstudio.github.io/renv/) | パッケージ管理 | `Rscript -e 'packageVersion("renv")'` |
| [air](https://posit-dev.github.io/air/) | R フォーマッタ | `air --version` |
| [Quarto CLI](https://quarto.org/) | ノート・原稿レンダー | `quarto --version` |

## セットアップ

```bash
# 依存パッケージを復元（renv.lock がある場合）
Rscript -e 'renv::restore()'

# 初回（renv 未初期化の場合）
Rscript -e 'renv::init()'
```

## 実行

```bash
# パイプライン全体
Rscript -e 'targets::tar_make()'

# 定義の検証
Rscript -e 'targets::tar_validate()'

# テスト
Rscript tests/testthat.R

# ノート・原稿のレンダー（Quarto CLI が必要）
quarto render notes/
```

## ディレクトリ

| パス | 内容 |
|---|---|
| `_targets.R` | パイプライン定義 |
| `R/` | 関数定義（副作用なし） |
| `data-raw/` | 不変の生データ（gitignore） |
| `data/` | 中間処理データ（gitignore） |
| `notes/` | 探索的分析ノート（Quarto） |
| `paper/` | 原稿（Quarto） |
| `tests/` | testthat |
| `memory/` | Claude Code 会話間引き継ぎ知識 |
| `prompts/` | Claude Code 作業ログ |
